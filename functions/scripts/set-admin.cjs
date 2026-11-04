const { initializeApp } = require("firebase-admin/app");
const { getAuth } = require("firebase-admin/auth");
const { FieldValue, getFirestore } = require("firebase-admin/firestore");

const userIdOrEmail = process.argv[2];
if (!userIdOrEmail) {
  console.error("Usage: npm run set-admin -- <firebase-auth-uid-or-email>");
  process.exitCode = 1;
} else {
  initializeApp({ projectId: "green-energy-fb652" });
  const auth = getAuth();
  const db = getFirestore();

  const getUser = userIdOrEmail.includes("@")
    ? auth.getUserByEmail(userIdOrEmail)
    : auth.getUser(userIdOrEmail);

  getUser
    .then(async (user) => {
      await auth.setCustomUserClaims(user.uid, {
        ...(user.customClaims ?? {}),
        admin: true,
      });
      await db.collection("users").doc(user.uid).set(
        { role: "admin", updatedAt: FieldValue.serverTimestamp() },
        { merge: true },
      );
      console.log(
        `Granted admin role to ${user.email ?? user.uid}. Ask the user to sign in again.`,
      );
    })
    .catch((error) => {
      console.error("Could not grant admin role:", error.message);
      process.exitCode = 1;
    });
}
