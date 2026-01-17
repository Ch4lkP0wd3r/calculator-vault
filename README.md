# 🔐 Calculator Vault - Stealth Safety App

A sophisticated Android safety application disguised as a calculator, designed to help victims of domestic violence and abuse in India. The app provides emergency SOS capabilities while maintaining complete stealth and generating legally-admissible evidence compliant with Section 65B of the Bharatiya Sakshya Adhiniyam (BSA).

## 🎯 Core Features

### 1. **Stealth Design**
- Fully functional calculator interface
- No suspicious app name or icon
- Hidden vault accessible only via secret codes
- Dummy vault option for additional safety

### 2. **Emergency Response System**
- **Instant SOS Code**: Direct panic trigger from calculator
- **Shake Detection**: Background monitoring with 5-second confirmation
- **Panic Button**: Manual emergency activation
- **Background Protection**: Works even when app is closed

### 3. **Forensic Evidence Generation** 🏛️
- **SHA-256 Hashing**: Cryptographic proof of file integrity
- **Section 65B Certificate**: Auto-generated PDF report with:
  - File hash and metadata
  - GPS coordinates and timestamp (UTC)
  - Device identification
  - Legal declaration text for Indian courts
- **Non-Repudiable Evidence**: Admissible in legal proceedings

### 4. **Safety Features**
- **Double-Blind Vault**: Decoy interface to protect victims
- **Zero-Trace Storage**: Files hidden from gallery and file managers
- **Local-Only Data**: No cloud storage or external servers
- **Encrypted Communications**: Secure data handling

### 5. **Institutional Integration**
- Direct link to National Cyber Crime Portal (I4C - 1930)
- Evidence package ready for law enforcement
- Compliance with Indian legal standards

## 🏗️ Technical Architecture

### Technology Stack
- **Framework**: Flutter (Android-native)
- **Language**: Dart
- **Storage**: SharedPreferences (local)
- **Permissions**: Location, Microphone, Foreground Service

### Key Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.3.4
  geolocator: ^13.0.4
  record: ^5.2.1
  share_plus: ^10.1.4
  permission_handler: ^11.4.0
  sensors_plus: ^6.2.0
  flutter_background_service: ^5.1.0
  flutter_local_notifications: ^19.5.0
  crypto: ^3.0.7
  pdf: ^3.11.3
  device_info_plus: ^12.3.0
  url_launcher: ^6.3.2
  intl: ^0.20.2
  math_expressions: ^2.7.0
```

### Project Structure
```
lib/
├── main.dart                          # App entry point
├── screens/
│   ├── setup_screen.dart             # First-time passcode setup
│   ├── calculator_screen.dart        # Main calculator UI
│   ├── vault_screen.dart             # Secret vault interface
│   └── dummy_vault_screen.dart       # Decoy photo gallery
└── services/
    ├── panic_service.dart            # Emergency response logic
    ├── forensic_service.dart         # Evidence generation
    └── background_service.dart       # Background monitoring
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (included in `../flutter_sdk/`)
- Android device or emulator (API 21+)
- Physical device recommended for shake detection

### Installation

1. **Clone the repository**
```bash
cd /home/ch4lkp0wd3r/cyber-sheild-india/calculator_vault
```

2. **Install dependencies**
```bash
../flutter_sdk/bin/flutter pub get
```

3. **Run the app**
```bash
../flutter_sdk/bin/flutter run
```

4. **Build APK**
```bash
../flutter_sdk/bin/flutter build apk --release
```

## 📱 User Guide

### First-Time Setup
1. Launch the app
2. Set a 4-digit **Vault Code** (e.g., `1234`)
3. Confirm the code
4. App opens to calculator interface

### Accessing the Vault
1. Open the calculator
2. Type your vault code: `1234`
3. Press `=`
4. Vault interface opens

### Setting Up Emergency Features

#### Instant SOS Code
1. Access the vault
2. Tap "Instant SOS Code"
3. Set a code (e.g., `999`)
4. Typing this code in calculator triggers immediate panic

#### Decoy Vault Code
1. Access the vault
2. Tap "Set Decoy Vault Code"
3. Set a fake code (e.g., `4321`)
4. This code opens a harmless photo gallery

#### Background Protection
1. Access the vault
2. Toggle "Background Protection" ON
3. Persistent notification appears
4. Shake phone anywhere to trigger SOS

### Emergency Activation Methods

#### Method 1: Instant SOS Code
- Type SOS code in calculator + `=`
- **No countdown** - immediate activation
- Records audio, gets location, generates evidence

#### Method 2: Shake Detection
- Shake phone vigorously
- 5-second countdown appears
- Tap "CANCEL" to abort
- Otherwise, automatic activation

#### Method 3: Panic Button
- Access vault
- Tap large "PANIC" button
- Same recording and evidence process

### Evidence Package
When panic is triggered, the app:
1. **Records** 10 seconds of audio
2. **Captures** GPS coordinates
3. **Generates** SHA-256 hash of audio file
4. **Creates** Section 65B PDF certificate with:
   - Audio file hash
   - GPS location
   - Device ID and model
   - UTC timestamp
   - Legal declaration
5. **Opens** share sheet with both files

### Sharing Evidence
- Select WhatsApp, Telegram, SMS, or Email
- Both audio and PDF are attached
- Pre-filled message includes location link
- Send to trusted contacts

## 🔒 Security & Privacy

### Data Storage
- All data stored locally in app sandbox
- No cloud uploads or external servers
- Files invisible to gallery and file managers
- Deleted when app is uninstalled

### Permissions Required
- **Location**: GPS coordinates for evidence
- **Microphone**: Audio recording
- **Foreground Service**: Background monitoring
- **Notifications**: Status updates

### Legal Compliance
- Section 65B (BSA) compliant evidence
- Cryptographic integrity verification
- Metadata preservation
- Chain of custody documentation

## 🎓 For Developers

### Code Quality
- Clean architecture with service layer
- Separation of concerns
- Reusable components
- Comprehensive error handling

### Testing
```bash
# Run on device
../flutter_sdk/bin/flutter run

# Test shake detection
# Use emulator controls or physical shake

# Test background service
# Enable background protection and close app
```

### Customization
- Modify `lib/screens/calculator_screen.dart` for UI changes
- Update `lib/services/forensic_service.dart` for PDF customization
- Adjust shake sensitivity in `background_service.dart`

## 📋 Permissions (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MICROPHONE"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
```

## 🤝 Contributing
This is a safety-critical application. Contributions should prioritize:
- User safety and privacy
- Legal compliance
- Stealth and discretion
- Evidence integrity

## ⚠️ Important Notes

### For Users
- **Test thoroughly** before relying on the app
- **Grant all permissions** for full functionality
- **Add trusted contacts** before emergency
- **Keep phone charged** for background monitoring
- **Understand limitations**: Requires network for sharing

### For Developers
- **Never log sensitive data**
- **Test on physical devices** for shake detection
- **Verify evidence integrity** after changes
- **Maintain legal compliance** with updates

## 🆘 Support Resources
- **National Cyber Crime Portal**: https://cybercrime.gov.in
- **Women Helpline**: 1091
- **National Commission for Women**: 7827-170-170

## 📄 License
This project is designed for safety and protection. Use responsibly and ethically.

## 🙏 Acknowledgments
Built to support victims of domestic violence and abuse in India, with compliance to Indian legal standards for electronic evidence.

---

**Remember**: This app is a tool for safety. Always prioritize your personal safety and seek help from authorities and support organizations.
