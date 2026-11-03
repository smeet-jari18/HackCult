import { initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { FieldValue, getFirestore, Timestamp } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { auth } from "firebase-functions/v1";
import { setGlobalOptions } from "firebase-functions/v2";
import {
  onDocumentWritten,
  onDocumentCreated,
} from "firebase-functions/v2/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { onSchedule } from "firebase-functions/v2/scheduler";

initializeApp();
setGlobalOptions({ region: "asia-south1" });

const db = getFirestore();

// ---------------------------------------------------------------------------
// Gamification rules (mirror of lib/core/logic/calculators.dart + mock_data)
// ---------------------------------------------------------------------------

/** taskId → [points, verification] */
const TASK_POINTS: Record<string, [number, "self" | "photo" | "bill"]> = {
  ac_24: [20, "photo"],
  load_shift_wm: [15, "self"],
  led_swap: [30, "photo"],
  standby_off: [5, "self"],
  geyser_timer: [25, "self"],
  midday_heavy_load: [10, "self"],
  bucket_bath: [5, "self"],
  cloth_bag: [5, "photo"],
  local_seasonal_meal: [5, "self"],
  waste_segregate: [10, "photo"],
  walk_short_trip: [15, "self"],
  ewaste_drop: [30, "photo"],
  upload_bill: [50, "bill"],
  solar_assessment: [20, "self"],
  diwali_led_lights: [10, "photo"],
};
const DAILY_SELF_CAP = 150;
const POINTS_PER_UNIT_SAVED = 2;
const BILL_UPLOAD_POINTS = 50;

const LEVELS: [string, number][] = [
  ["Seedling", 0],
  ["Sapling", 200],
  ["Tree", 600],
  ["Grove", 1500],
  ["Forest", 4000],
  ["Champion", 10000],
];
const levelFor = (points: number) =>
  [...LEVELS].reverse().find(([, min]) => points >= min)?.[0] ?? "Seedling";

const dayKey = (d: Date) =>
  `${d.getUTCFullYear()}-${String(d.getUTCMonth() + 1).padStart(2, "0")}-${String(
    d.getUTCDate(),
  ).padStart(2, "0")}`;

// ---------------------------------------------------------------------------
// Auth → profile bootstrap
// ---------------------------------------------------------------------------

export const createUserProfile = auth.user().onCreate(async (user) => {
  const profile = db.collection("users").doc(user.uid);
  const existing = await profile.get();
  if (existing.exists) return;

  await profile.create({
    uid: user.uid,
    email: user.email ?? "",
    displayName: user.displayName ?? user.email?.split("@")[0] ?? "Citizen",
    role: "citizen",
    authProvider: user.providerData.some(
      (provider) => provider.providerId === "google.com",
    )
      ? "google"
      : "password",
    onboardingComplete: false,
    points: 0,
    weeklyPoints: 0,
    streak: 0,
    longestStreak: 0,
    freezeTokens: 1,
    badges: [],
    createdAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  });
});

export const setUserRole = onCall(async (request) => {
  if (request.auth?.token.admin !== true) {
    throw new HttpsError("permission-denied", "Administrator access required.");
  }

  const uid = request.data?.uid;
  const role = request.data?.role;
  if (
    typeof uid !== "string" ||
    !uid ||
    !["citizen", "captain", "admin"].includes(role)
  ) {
    throw new HttpsError("invalid-argument", "A valid user ID and role are required.");
  }

  const authUser = await getAuth().getUser(uid);
  const claims = { ...(authUser.customClaims ?? {}) };
  if (role === "admin") claims.admin = true;
  else delete claims.admin;
  if (role === "captain") claims.captain = true;
  else delete claims.captain;
  await getAuth().setCustomUserClaims(uid, claims);
  await db.collection("users").doc(uid).set(
    { role, updatedAt: FieldValue.serverTimestamp() },
    { merge: true },
  );
  return { uid, role };
});

// ---------------------------------------------------------------------------
// Points: task completion  (users/{uid}/taskLogs/{logId})
// ---------------------------------------------------------------------------

export const awardTaskPoints = onDocumentWritten(
  "users/{uid}/taskLogs/{logId}",
  async (event) => {
    const after = event.data?.after;
    if (!after?.exists) return;
    const log = after.data() as {
      taskId?: string;
      status?: string;
      date?: Timestamp;
      pointsAwarded?: number;
    };
    if (log.status !== "done" || log.pointsAwarded) return; // idempotent
    const rule = TASK_POINTS[log.taskId ?? ""];
    if (!rule) return;
    const [basePoints, verification] = rule;
    const uid = event.params.uid;
    const userRef = db.collection("users").doc(uid);
    const date = log.date?.toDate() ?? new Date();
    const key = dayKey(date);

    await db.runTransaction(async (tx) => {
      const userSnap = await tx.get(userRef);
      if (!userSnap.exists) return;
      const u = userSnap.data() ?? {};
      const daily = (u.dailyPoints ?? {}) as { day?: string; self?: number; tasks?: number };
      const sameDay = daily.day === key;
      const selfToday = sameDay ? daily.self ?? 0 : 0;
      const tasksToday = sameDay ? daily.tasks ?? 0 : 0;

      let points = basePoints;
      let capped = false;
      if (verification === "self") {
        const remaining = Math.max(0, DAILY_SELF_CAP - selfToday);
        if (points > remaining) {
          points = remaining;
          capped = true;
        }
      }

      // Streak: first task of the day extends it (or resets after a gap).
      const lastDay = u.lastTaskDay as string | undefined;
      let streak = u.streak ?? 0;
      let longest = u.longestStreak ?? 0;
      if (tasksToday === 0) {
        const yesterday = dayKey(new Date(date.getTime() - 86400000));
        streak = lastDay === yesterday ? streak + 1 : lastDay === key ? streak : 1;
        longest = Math.max(longest, streak);
      }

      const badges = new Set<string>(u.badges ?? []);
      const totalTasks = (u.totalTasksDone ?? 0) + 1;
      if (totalTasks === 1) badges.add("first_step");
      if (log.taskId === "load_shift_wm") badges.add("peak_shifter");
      if (log.taskId === "led_swap") badges.add("led_legend");
      if (streak >= 7) badges.add("streak_7");
      if (streak >= 30) badges.add("streak_30");

      const prevLevel = levelFor(u.points ?? 0);
      const newPoints = (u.points ?? 0) + points;
      const newLevel = levelFor(newPoints);

      tx.update(userRef, {
        points: newPoints,
        weeklyPoints: (u.weeklyPoints ?? 0) + points,
        streak,
        longestStreak: longest,
        lastTaskDay: key,
        totalTasksDone: totalTasks,
        badges: [...badges],
        dailyPoints: {
          day: key,
          self: selfToday + (verification === "self" ? points : 0),
          tasks: tasksToday + 1,
        },
        updatedAt: FieldValue.serverTimestamp(),
      });
      tx.update(after.ref, { pointsAwarded: points, capped });
      tx.set(userRef.collection("pointsLedger").doc(), {
        delta: points,
        reason: `Task · ${log.taskId}`,
        taskId: log.taskId,
        createdAt: FieldValue.serverTimestamp(),
      });
      if (newLevel !== prevLevel) {
        tx.set(userRef.collection("events").doc(), {
          type: "level_up",
          level: newLevel,
          createdAt: FieldValue.serverTimestamp(),
        });
      }
    });
  },
);

// ---------------------------------------------------------------------------
// Points: monthly bill / footprint entry
// ---------------------------------------------------------------------------

export const awardFootprintPoints = onDocumentCreated(
  "users/{uid}/footprints/{entryId}",
  async (event) => {
    const snap = event.data;
    if (!snap) return;
    const f = snap.data() as {
      isBaseline?: boolean;
      unitsSaved?: number;
      source?: string;
      pointsAwarded?: number;
    };
    if (f.isBaseline || f.pointsAwarded) return;
    const uid = event.params.uid;
    const userRef = db.collection("users").doc(uid);
    const points =
      Math.round((f.unitsSaved ?? 0) * POINTS_PER_UNIT_SAVED) +
      (f.source === "bill" ? BILL_UPLOAD_POINTS : 0);
    if (points <= 0) return;

    await db.runTransaction(async (tx) => {
      const userSnap = await tx.get(userRef);
      if (!userSnap.exists) return;
      const u = userSnap.data() ?? {};
      const badges = new Set<string>(u.badges ?? []);
      if (f.source === "bill") badges.add("bill_verified");
      tx.update(userRef, {
        points: (u.points ?? 0) + points,
        weeklyPoints: (u.weeklyPoints ?? 0) + points,
        badges: [...badges],
        updatedAt: FieldValue.serverTimestamp(),
      });
      tx.update(snap.ref, { pointsAwarded: points });
      tx.set(userRef.collection("pointsLedger").doc(), {
        delta: points,
        reason: "Monthly bill · units saved",
        createdAt: FieldValue.serverTimestamp(),
      });
    });
  },
);

// ---------------------------------------------------------------------------
// Public leaderboard projection  (users/{uid} → leaderboard/{uid})
// Only non-sensitive fields; readable by any signed-in citizen.
// ---------------------------------------------------------------------------

export const syncLeaderboard = onDocumentWritten("users/{uid}", async (event) => {
  const uid = event.params.uid;
  const ref = db.collection("leaderboard").doc(uid);
  const after = event.data?.after;
  if (!after?.exists) {
    await ref.delete().catch(() => undefined);
    return;
  }
  const u = after.data() ?? {};
  if (u.role === "admin") return;
  const projected = {
    displayName: u.displayName ?? "Citizen",
    district: u.district ?? "",
    communityId: u.communityId ?? null,
    points: u.points ?? 0,
    weeklyPoints: u.weeklyPoints ?? 0,
    streak: u.streak ?? 0,
    level: levelFor(u.points ?? 0),
    updatedAt: FieldValue.serverTimestamp(),
  };
  const before = event.data?.before?.data() ?? {};
  const unchanged = ["displayName", "district", "communityId", "points", "weeklyPoints", "streak"]
    .every((k) => (before as Record<string, unknown>)[k] === (u as Record<string, unknown>)[k]);
  if (unchanged && event.data?.before?.exists) return;
  await ref.set(projected, { merge: true });
});

/** Monday 00:05 IST — reset weekly points for the challenge board. */
export const resetWeeklyPoints = onSchedule(
  { schedule: "5 0 * * 1", timeZone: "Asia/Kolkata" },
  async () => {
    const snap = await db.collection("users").where("weeklyPoints", ">", 0).get();
    const batches = [];
    let batch = db.batch();
    let n = 0;
    for (const doc of snap.docs) {
      batch.update(doc.ref, { weeklyPoints: 0, updatedAt: FieldValue.serverTimestamp() });
      if (++n % 400 === 0) {
        batches.push(batch.commit());
        batch = db.batch();
      }
    }
    batches.push(batch.commit());
    await Promise.all(batches);
  },
);

// ---------------------------------------------------------------------------
// Push campaigns (admin only)  — topics: all_citizens | district_<x> | community_<id>
// ---------------------------------------------------------------------------

export const sendCampaign = onCall(async (request) => {
  if (request.auth?.token.admin !== true) {
    throw new HttpsError("permission-denied", "Administrator access required.");
  }
  const { title, body, topic, route, testUid } = (request.data ?? {}) as {
    title?: string;
    body?: string;
    topic?: string;
    route?: string;
    testUid?: string;
  };
  if (!title || !body || title.length > 80 || body.length > 240) {
    throw new HttpsError("invalid-argument", "Title (≤80) and body (≤240) are required.");
  }
  const safeTopic = (topic ?? "all_citizens").replace(/[^a-zA-Z0-9_\-]/g, "_");
  const message = {
    notification: { title, body },
    data: { route: route ?? "/home", campaign: "1" },
    android: {
      priority: "high" as const,
      notification: { channelId: "life_alerts", icon: "ic_launcher" },
    },
    apns: { payload: { aps: { sound: "default" } } },
  };

  // "Send test to me": deliver only to the admin's own device token.
  if (testUid) {
    const snap = await db.collection("users").doc(testUid).get();
    const token = snap.get("fcmToken") as string | undefined;
    if (!token) throw new HttpsError("failed-precondition", "No device token for this user.");
    const id = await getMessaging().send({ ...message, token });
    return { ok: true, messageId: id, test: true };
  }

  const id = await getMessaging().send({ ...message, topic: safeTopic });
  const log = await db.collection("campaigns").add({
    title,
    body,
    topic: safeTopic,
    route: route ?? "/home",
    sentBy: request.auth?.uid,
    messageId: id,
    createdAt: FieldValue.serverTimestamp(),
  });
  return { ok: true, messageId: id, campaignId: log.id };
});

/** Daily 17:30 IST peak-hour broadcast (server-side fallback for devices
 *  where local reminders were denied). Opted-out users unsubscribe from the
 *  `peak_nudge` topic client-side. */
export const dailyPeakNudge = onSchedule(
  { schedule: "30 17 * * *", timeZone: "Asia/Kolkata" },
  async () => {
    await getMessaging().send({
      topic: "peak_nudge",
      notification: {
        title: "Peak hours start at 6 pm ⚡",
        body: "Run the washing machine & geyser now or after 11 pm — save ~₹6 and 0.4 kg CO₂.",
      },
      data: { route: "/home" },
      android: { notification: { channelId: "life_nudges" } },
    });
  },
);
