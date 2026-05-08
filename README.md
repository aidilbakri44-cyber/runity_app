# Runity - Multi-Sport Fitness Companion 🏃‍♂️🚴‍♂️🏊‍♂️

Runity is a premium, professional-grade fitness tracking application built with Flutter. It's designed to be your ultimate companion for various sports activities, providing real-time metrics, GPS visualization, and a secure user experience.

## ✨ Key Features

### 🛠️ Multi-Sport Support
Track different types of activities with tailored contexts:
- **Running** 🏃
- **Cycling** 🚴
- **Swimming** 🏊
- **Hiking** 🥾
- **Walking** 🚶

### 📍 Real-Time GPS Tracking
- Live map visualization using Google Maps.
- Precise tracking of distance, duration, and pace.
- Interactive polyline rute rendering.

### 🔐 Biometric Security (Security Lock)
Keep your fitness data private with integrated biometric authentication:
- **Fingerprint** support on Android.
- **FaceID / TouchID** support on iOS.
- Dynamic UI that adapts to your device's platform.

### 👤 Profile & Personalization
- **Local Photo Picker**: Update your profile picture directly from your device's gallery or camera (No URLs needed!).
- **Multi-Language Support**: Fully localized in **English** and **Bahasa Indonesia**.
- **Dark/Light Mode**: Sleek Cyber-Green dark theme and clean light theme.

### 📊 Activity History & Statistics
- Detailed log of all past activities.
- Summary cards for total distance and number of sessions.
- Glassmorphism UI design for a premium feel.

## 🚀 Technology Stack

- **Framework**: Flutter
- **State Management**: Riverpod (for reactive and predictable state)
- **Local Database**: Hive (for fast local persistence)
- **Maps**: Google Maps Flutter
- **Location**: Geolocator
- **Icons**: FontAwesome Flutter
- **Security**: Image Picker (for profile photos)

## 🛠️ Installation & Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/runity_app.git
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Setup Google Maps API Key**:
   - Get your API key from [Google Cloud Console](https://console.cloud.google.com/).
   - Add it to `AndroidManifest.xml` (Android) and `AppDelegate.swift` (iOS).

4. **Run the application**:
   ```bash
   flutter run
   ```

## 🎨 Design Philosophy
Runity follows a **Cyber-Green / Neon** aesthetic, utilizing:
- **Glassmorphism**: Translucent cards and panels for a modern look.
- **Micro-animations**: Smooth transitions and pulsing indicators for status.
- **Custom Theming**: Deep blacks with vibrant neon green accents.

---
Developed with ❤️ for fitness enthusiasts.
