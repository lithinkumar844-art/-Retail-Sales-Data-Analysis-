const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.sendSpoilageAlert = functions.firestore
  .document('food_scans/{scanId}')
  .onCreate(async (snap) => {
    const data = snap.data();
    if (!data || data.status !== 'Rotten') return null;

    const message = {
      topic: 'food_alerts',
      notification: {
        title: 'Food Spoilage Alert',
        body: `${data.foodName} is Spoiled. Please discard or compost.`,
      },
      data: {
        foodName: String(data.foodName || ''),
      },
    };

    return admin.messaging().send(message);
  });
