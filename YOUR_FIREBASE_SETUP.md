# Your Firebase Setup Guide

This guide will help you set up Firebase for your E-Commerce Flutter app using your specific Firebase project details.

## Your Firebase Project Details

- **Project ID**: youssef-5228c
- **Project Number**: 293546416514
- **Project Name**: youssef

## Step 1: Get Your Firebase Configuration

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Select your project "youssef" (youssef-5228c)
3. Click on the gear icon (Project Settings) next to "Project Overview"
4. In the "General" tab, under "Your apps" section, you'll see a web app (or you may need to create one)

### If you need to create a web app:

1. Click on the web icon (</>) to register your web app
2. Enter a nickname (e.g., "E-Commerce Web App")
3. **Don't** check "Also set up Firebase Hosting"
4. Click "Register app"
5. Firebase will show you the configuration code - copy these values:
   - apiKey
   - authDomain
   - projectId (should be "youssef-5228c")
   - storageBucket
   - messagingSenderId (should be "293546416514")
   - appId
   - measurementId (for web only)

## Step 2: Update Firebase Configuration

1. Open [lib/firebase_options.dart](file:///c:/Users/HP/Desktop/E-commerce/E-commerce/E-commerce/ecommerce_app/lib/firebase_options.dart) in your project
2. Replace the placeholder values in the `web` configuration with your actual values:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_ACTUAL_API_KEY',
  appId: 'YOUR_ACTUAL_APP_ID',
  messagingSenderId: '293546416514',
  projectId: 'youssef-5228c',
  authDomain: 'youssef-5228c.firebaseapp.com',
  storageBucket: 'youssef-5228c.appspot.com',
  measurementId: 'YOUR_ACTUAL_MEASUREMENT_ID',
);
```

## Step 3: Enable Authentication Methods

1. In the Firebase Console, go to "Authentication" → "Sign-in method"
2. Enable the following sign-in providers:
   - Email/Password (click the pencil icon to enable)
   - Google (click the pencil icon to enable)

### For Google Sign-In Configuration:

1. After enabling Google sign-in, scroll down to the "Web SDK configuration" section
2. Copy the "Web client ID" value (it looks like a long string ending with .apps.googleusercontent.com)
3. Open [lib/providers/auth_provider.dart](file:///c:/Users/HP/Desktop/E-commerce/E-commerce/E-commerce/ecommerce_app/lib/providers/auth_provider.dart)
4. Replace the placeholder client ID with your actual Web client ID:

```dart
_googleSignIn = GoogleSignIn(
  clientId: 'YOUR_ACTUAL_WEB_CLIENT_ID_FROM_FIREBASE_CONSOLE',
  scopes: ['email', 'profile'],
);
```

## Step 4: Test Your Configuration

1. Save all your changes
2. Run your app:
   ```bash
   flutter run -d chrome
   ```
3. Try to register or sign in - you should now be using real Firebase authentication

## Troubleshooting

### If you still see demo mode or errors:

1. **Check the debug console** for specific error messages
2. **Verify all configuration values** match exactly with your Firebase Console
3. **Make sure you've enabled authentication providers** in Firebase Console
4. **Ensure you have a stable internet connection**

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