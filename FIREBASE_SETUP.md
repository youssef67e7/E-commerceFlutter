# Firebase Setup Guide

This guide will help you set up Firebase for your E-Commerce Flutter app to enable real authentication instead of demo mode.

## Prerequisites

1. A Google account
2. Flutter SDK installed
3. This E-Commerce app project

## Step 1: Create a Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter a project name (e.g., "E-Commerce App")
4. Accept the terms and conditions
5. Click "Create project"

## Step 2: Register Your App with Firebase

### For Web:

1. In the Firebase Console, click the web icon (</>) to register your web app
2. Enter your app's nickname (e.g., "E-Commerce Web App")
3. Click "Register app"
4. Firebase will provide configuration code that looks like this:
   ```javascript
   const firebaseConfig = {
     apiKey: "AIzaSyD...",
     authDomain: "your-app.firebaseapp.com",
     projectId: "your-project-id",
     storageBucket: "your-app.appspot.com",
     messagingSenderId: "123456789",
     appId: "1:123456789:web:..."
   };
   ```
5. Note down these values - you'll need them in Step 3

## Step 3: Update Firebase Configuration

1. Open [lib/firebase_options.dart](file:///c:/Users/HP/Desktop/E-commerce/E-commerce/E-commerce/ecommerce_app/lib/firebase_options.dart) in your project
2. Replace all the placeholder values with your actual Firebase configuration:
   ```dart
   static const FirebaseOptions web = FirebaseOptions(
     apiKey: 'YOUR_ACTUAL_API_KEY',
     appId: 'YOUR_ACTUAL_APP_ID',
     messagingSenderId: 'YOUR_ACTUAL_MESSAGING_SENDER_ID',
     projectId: 'YOUR_ACTUAL_PROJECT_ID',
     authDomain: 'YOUR_ACTUAL_AUTH_DOMAIN',
     storageBucket: 'YOUR_ACTUAL_STORAGE_BUCKET',
     measurementId: 'YOUR_ACTUAL_MEASUREMENT_ID', // Only for web
   );
   ```
3. Make sure to update all platform configurations (Android, iOS, etc.) if you plan to deploy to those platforms

## Step 4: Enable Authentication Methods

1. In the Firebase Console, go to "Authentication" → "Sign-in method"
2. Enable the following sign-in providers:
   - Email/Password
   - Google

### For Google Sign-In:

1. In the "Google" provider settings, you'll see a Web SDK configuration
2. Copy the "Web client ID" value
3. Open [lib/providers/auth_provider.dart](file:///c:/Users/HP/Desktop/E-commerce/E-commerce/E-commerce/ecommerce_app/lib/providers/auth_provider.dart)
4. Replace the placeholder client ID with your actual Web client ID:
   ```dart
   _googleSignIn = GoogleSignIn(
     clientId: 'YOUR_ACTUAL_WEB_CLIENT_ID_FROM_FIREBASE_CONSOLE',
     scopes: ['email', 'profile'],
   );
   ```

## Step 5: Test Your Configuration

1. Save all your changes
2. Run your app:
   ```bash
   flutter run -d chrome
   ```
3. Try to register or sign in - you should now be using real Firebase authentication instead of demo mode

## Troubleshooting

### If you still see demo mode:

1. Check that all Firebase configuration values are correct
2. Make sure you've enabled the authentication providers in Firebase Console
3. Check the debug console for any error messages
4. Ensure you have a stable internet connection

### Common Issues:

1. **API Key Not Valid**: Double-check that you've copied the correct API key from Firebase Console
2. **Google Sign-In Not Working**: Make sure you've added the correct Web client ID
3. **Permission Errors**: Ensure your Firebase project has the correct permissions set

## Need Help?

If you're still having issues:

1. Check the Flutter debug console for specific error messages
2. Verify all configuration values match exactly with your Firebase Console
3. Make sure you're using the correct Firebase project

For additional support, refer to the [Firebase Documentation](https://firebase.google.com/docs)