/* Firebase Cloud Messaging service worker (web push).
 * Only used when PushService.webVapidKey is set in lib/core/services/push_service.dart.
 * Config mirrors lib/firebase_options.dart (web app). */
importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyDps9LGSI97xxq051fgRYqHJ9ZoYyy1tT4',
  authDomain: 'green-energy-fb652.firebaseapp.com',
  projectId: 'green-energy-fb652',
  storageBucket: 'green-energy-fb652.firebasestorage.app',
  messagingSenderId: '983072556271',
  appId: '1:983072556271:web:16d158ec53538e9924071a',
});

const messaging = firebase.messaging();
messaging.onBackgroundMessage((payload) => {
  const n = payload.notification || {};
  self.registration.showNotification(n.title || 'LiFE Mitra', {
    body: n.body || '',
    icon: '/icons/Icon-192.png',
    data: payload.data || {},
  });
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  const route = (event.notification.data && event.notification.data.route) || '/';
  event.waitUntil(clients.openWindow('/#' + route));
});
