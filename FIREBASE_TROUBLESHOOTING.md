# 🔧 Firebase Connection Troubleshooting Guide

## Common Issues and Solutions

### 1. **Google Client ID Mismatch**
The most common issue is a mismatch between the Google Client ID in your code and the one configured in the Firebase Console.

#### Solution:
1. Go to your Firebase Console → Project Settings → General tab
2. Under "Your apps" section, find your Web app configuration
3. Copy the Web client ID (should end with `.apps.googleusercontent.com`)
4. Update both files with the correct ID:
   - `lib/providers/auth_provider.dart` (line ~30)
   - `web/index.html` (line ~27 in meta tag)

### 2. **Firebase Configuration Values**
Ensure all Firebase configuration values match exactly with your Firebase Console.

#### Solution:
1. In Firebase Console → Project Settings → General tab
2. Copy the entire Firebase SDK snippet
3. Update `lib/firebase_options.dart` with the correct values
4. Update `web/index.html` Firebase config script with the correct values

### 3. **Authorized Domains**
Firebase requires explicit domain authorization for web authentication.

#### Solution:
1. In Firebase Console → Authentication → Settings tab
2. Add `localhost` and `localhost:3000` to authorized domains
3. If deploying, add your production domain as well

### 4. **API Key Restrictions**
If your API key has restrictions, it might block requests.

#### Solution:
1. In Google Cloud Console → APIs & Services → Credentials
2. Find your API key and check its restrictions
3. Either remove restrictions for development or add proper HTTP referrers

## Testing Steps

1. Run `flutter clean`
2. Run `flutter pub get`
3. Run `flutter run -d web-server --web-port=3000`
4. Check browser console for any error messages
5. Try signing in with email/password first (simpler than Google Sign-In)

## Error Reference

### "API key not valid"
- Check that your API key matches exactly with Firebase Console
- Ensure no extra characters or spaces

### "Google Sign-In fails"
- Verify the Web client ID is correct
- Check that the domain is authorized in Firebase Console

### "Firestore permission denied"
- Make sure you're in test mode or have proper security rules
- Check Firestore security rules in Firebase Console

## Emergency Fallback

If you continue to have issues, temporarily use the demo account:
- Email: `demo.google@example.com`
- Password: `GoogleDemo123!`

This is built into the app as a fallback for Google Sign-In issues.