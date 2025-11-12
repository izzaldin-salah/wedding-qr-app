# Wedding QR Scanner App 💍📱

A Flutter mobile application for wedding guest verification using QR code scanning. This app allows wedding organizers to quickly verify guest attendance by scanning QR codes linked to guest IDs (001-805).

## ✨ Features

- **Fast QR Code Scanning**: Instant camera-based QR code detection
- **Guest Verification**: Real-time verification against Google Apps Script backend
- **Visual Feedback**: 
  - ✅ **Green** - Access Granted (first-time scan)
  - ⚠️ **Orange** - Already Used (duplicate scan)
  - ❌ **Red** - Invalid QR Code or Network Error
- **User-Friendly Interface**: Beautiful gradient backgrounds and intuitive controls
- **Continuous Scanning**: "Scan Next Guest" button for quick processing

## 🎯 How It Works

1. **Launch the app** → Camera opens automatically
2. **Scan QR code** → Align the QR code within the frame
3. **Verification** → App sends GET request to your Apps Script URL
4. **Result Display**:
   - "Access granted" → Shows ✅ with green background
   - "Already used" → Shows ⚠️ with orange background
   - Invalid/Error → Shows ❌ with red background
5. **Next Guest** → Press "Scan Next Guest" button to continue

## 🔧 Configuration

Update the `baseUrl` in `lib/main.dart` with your Google Apps Script URL:

```dart
final String baseUrl = "YOUR_APPS_SCRIPT_URL";
```

The app expects the backend to return HTML responses containing:
- `"access granted"` - for valid, first-time scans
- `"already used"` - for duplicate scans
- Any other response is treated as invalid

## 📦 Dependencies

- `flutter` - Flutter SDK
- `qr_code_scanner: ^1.0.1` - QR code scanning functionality
- `http: ^1.6.0` - HTTP requests to backend
- `cupertino_icons: ^1.0.8` - iOS-style icons

## 🚀 Getting Started

### Prerequisites
- Flutter SDK installed
- Android Studio or VS Code with Flutter extensions
- Android device or emulator

### Installation

1. Clone the repository:
```bash
git clone https://github.com/izzaldin-salah/wedding-qr-app.git
cd wedding-qr-app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Update the Apps Script URL in `lib/main.dart`

4. Run the app:
```bash
flutter run
```

### Build APK

To build a release APK:
```bash
flutter build apk --release
```

The APK will be located at: `build/app/outputs/flutter-apk/app-release.apk`

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🛠️ Technical Details

### ID Extraction
The app intelligently extracts guest IDs from:
- Raw numeric IDs (e.g., "001", "234", "805")
- URLs with ID parameters (e.g., "https://example.com?id=001")

### Error Handling
- Network errors are caught and displayed
- Invalid QR code formats are validated
- HTTP status codes are checked
- User-friendly error messages

## 📄 License

This project is open source and available under the MIT License.

## 👨‍💻 Author

**Izzeldin Salaheldin Bushra Ibraheem**
- GitHub: [@izzaldin-salah](https://github.com/izzaldin-salah)

## 🎉 Wedding Ready!

Perfect for:
- Wedding guest check-in
- Event attendance tracking
- Access control at venues
- Quick guest verification

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
