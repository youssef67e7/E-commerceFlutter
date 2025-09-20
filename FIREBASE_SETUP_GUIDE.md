# Firebase & Google Sign-In Setup Guide

## Quick Setup (5 minutes)

### Step 1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter project name: `flutter-ecommerce-demo-2024`
4. Enable Google Analytics (optional)
5. Click "Create project"

### Step 2: Add Web App
1. In Firebase Console, click Web icon (</>) 
2. App nickname: `E-commerce Web App`
3. Check "Also set up Firebase Hosting"
4. Click "Register app"
5. Copy the `firebaseConfig` object

### Step 3: Update Configuration Files
Replace the configuration in these files with your Firebase config:

#### A. `lib/firebase_options.dart`
Update the `web` FirebaseOptions with your values:
```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_API_KEY',
  appId: 'YOUR_APP_ID', 
  messagingSenderId: 'YOUR_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
  storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  measurementId: 'YOUR_MEASUREMENT_ID',
);
```

#### B. `web/index.html`
Update the Firebase config object in the script tag:
```javascript
const firebaseConfig = {
  apiKey: "YOUR_API_KEY",
  authDomain: "YOUR_PROJECT_ID.firebaseapp.com", 
  projectId: "YOUR_PROJECT_ID",
  storageBucket: "YOUR_PROJECT_ID.appspot.com",
  messagingSenderId: "YOUR_SENDER_ID",
  appId: "YOUR_APP_ID",
  measurementId: "YOUR_MEASUREMENT_ID"
};
```

### Step 4: Enable Authentication
1. In Firebase Console, go to "Authentication"
2. Click "Get started"
3. Go to "Sign-in method" tab
4. Enable "Email/Password"
5. Enable "Google"
6. For Google Sign-In:
   - Add your project domain: `localhost:PORT`
   - Copy the Web client ID

#### Update Google Sign-In Config
Update in `web/index.html` and `lib/providers/auth_provider.dart`:
```html
<meta name="google-signin-client_id" content="YOUR_WEB_CLIENT_ID">
```

```dart
_googleSignIn = GoogleSignIn(
  clientId: 'YOUR_WEB_CLIENT_ID',
  scopes: ['email', 'profile'],
);
```

### Step 5: Enable Firestore
1. In Firebase Console, go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode"
4. Select location
5. Click "Done"

### Step 6: Run the App
```bash
flutter run -d chrome
```

## Test Authentication
1. **Email/Password**: Register new users or login with existing ones
2. **Google Sign-In**: Click the Google Sign-In button - should open Google auth popup

## Troubleshooting

### Google Sign-In Issues
- Make sure domain is added in Firebase Auth settings
- Check Web client ID is correct
- Ensure popup blocker is disabled

### Firebase Connection Issues  
- Verify API key is correct
- Check project ID matches
- Ensure Authentication and Firestore are enabled

### CORS Issues
- Add `localhost:PORT` to authorized domains in Firebase Auth settings

## Current Demo Configuration
The app currently uses demo Firebase credentials for testing. Replace them with your own Firebase project credentials for full functionality.

**Demo credentials are for development only and have limited functionality.**