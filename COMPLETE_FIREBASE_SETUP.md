# Complete Firebase Setup Guide for Your E-Commerce App

This guide will help you complete the Firebase setup for your E-Commerce Flutter app using your specific Firebase project (youssef-5228c).

## Your Firebase Project Details

- **Project ID**: youssef-5228c
- **Project Number**: 293546416514
- **Project Name**: youssef

## Step 1: Get Your Firebase Configuration Values

### 1.1 Access Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Sign in with your Google account
3. Select your project "youssef" (youssef-5228c)

### 1.2 Get Web Configuration

1. In the Firebase Console, click on the gear icon (Project Settings) next to "Project Overview"
2. In the "General" tab, under "Your apps" section:
   - If you see a web app already, click on it
   - If not, click "Add app" and select the web icon (</>)
3. Register your app with a nickname like "E-Commerce Web App"
4. **Don't** check "Also set up Firebase Hosting"
5. Click "Register app"
6. Firebase will show you the configuration code - copy these values:
   - apiKey
   - authDomain (should be "youssef-5228c.firebaseapp.com")
   - projectId (should be "youssef-5228c")
   - storageBucket (should be "youssef-5228c.appspot.com")
   - messagingSenderId (should be "293546416514")
   - appId
   - measurementId (for web only)

### 1.3 Get Google Sign-In Web Client ID

1. In the Firebase Console, go to "Authentication" → "Sign-in method"
2. Click on "Google" provider and then click the pencil icon to edit
3. Scroll down to the "Web SDK configuration" section
4. Copy the "Web client ID" value (it looks like a long string ending with .apps.googleusercontent.com)

## Step 2: Update Your Configuration Files

We've already prepared the configuration files with placeholder values. You just need to replace them with your actual values.

### 2.1 Update Firebase Options

Open [lib/firebase_options.dart](file:///c:/Users/HP/Desktop/E-commerce/E-commerce/E-commerce/ecommerce_app/lib/firebase_options.dart) and replace all placeholder values with your actual values:

1. Replace `'AIzaSyDc5mJ8FqJ5_0gRQEPG7vZMbXl2dKjdXQk'` with your actual API key
2. Replace `'1:293546416514:web:abcdef1234567890'` with your actual app ID
3. Replace `'G-XXXXXXXXXX'` with your actual Measurement ID
4. Replace `'293546416514-abcdef1234567890.apps.googleusercontent.com'` with your actual client IDs

### 2.2 Update Google Sign-In Configuration

Open [lib/providers/auth_provider.dart](file:///c:/Users/HP/Desktop/E-commerce/E-commerce/E-commerce/ecommerce_app/lib/providers/auth_provider.dart) and replace the Google Sign-In client ID:

1. Find the line with `'293546416514-abcdef1234567890.apps.googleusercontent.com'`
2. Replace it with your actual Web client ID from step 1.3

## Step 3: Enable Authentication Methods

1. In the Firebase Console, go to "Authentication" → "Sign-in method"
2. Enable the following sign-in providers:
   - Email/Password (click the pencil icon to enable)
   - Google (click the pencil icon to enable)

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

## Example Configuration Values

Here's what your configuration should look like (with example values):

```dart
// In firebase_options.dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'AIzaSyB2BvKp1aB3cD4eF5gH6iJ7kL8mN9oP0qR', // Your actual API key
  appId: '1:293546416514:web:a1b2c3d4e5f6g7h8i9j0k1', // Your actual app ID
  messagingSenderId: '293546416514',
  projectId: 'youssef-5228c',
  authDomain: 'youssef-5228c.firebaseapp.com',
  storageBucket: 'youssef-5228c.appspot.com',
  measurementId: 'G-ABC123DEF45', // Your actual Measurement ID
);

// In auth_provider.dart
_googleSignIn = GoogleSignIn(
  clientId: '293546416514-a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6.apps.googleusercontent.com', // Your actual Web client ID
  scopes: ['email', 'profile'],
);
```

## Need Help?

If you're still having issues:

1. Check the Flutter debug console for specific error messages
2. Verify all configuration values match exactly with your Firebase Console
3. Make sure you're using the correct Firebase project

For additional support, refer to the [Firebase Documentation](https://firebase.google.com/docs)