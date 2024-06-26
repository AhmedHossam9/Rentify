package com.android.application;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

public class MyFirebaseMessagingService extends FirebaseMessagingService {
    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {
        super.onMessageReceived(remoteMessage);
        // Handle FCM messages here.
        // If the application is in the foreground, handle both data and notification messages here.
        // Also if you intend on generating your own notifications as a result of a received FCM message,
        // here is where that should be initiated. See sendNotification method below.
    }

    @Override
    public void onNewToken(String token) {
        super.onNewToken(token);
        // Handle token refresh
        // You can save the token in your database for future use
    }
}
