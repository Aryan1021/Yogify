# 🧘 Yogify

Yogify is a **Flutter-based guided yoga app** that helps users follow yoga sessions with **audio, images, and timed instructions**.  
Each yoga session is defined using a **JSON file** with metadata, scripts, audio, and image assets.  

## ✨ Features
- 📂 **Dynamic Sessions**: Load yoga sessions from JSON files.
- 🎧 **Audio Guidance**: Play pose instructions with synced voice guidance.
- 🖼️ **Image Support**: Display pose images while the session runs.
- ⏱️ **Progress Tracking**: Show timers and progress bars for each step.
- ⏯️ **Controls**: Pause, resume, and stop sessions anytime.
- 📑 **Preview Flow**: Preview session steps before starting.
- 🎬 **Hero Animation**: Smooth transition from session list to preview.

---

## 📂 Project Structure

lib/
│
├── main.dart # Entry point
│
├── models/
│ └── session.dart # Data models (YogaSession, Step, Script)
│
├── services/
│ └── pose_service.dart # Loads and parses session JSON
│
├── screens/
│ ├── session_list_screen.dart # List of all yoga sessions
│ ├── preview_screen.dart # Preview screen with flow overview
│ └── session_screen.dart # Actual session player with audio + images
│
assets/
├── sessions/ # JSON session definitions
│ ├── cat_cow.json
│ └── sun_salutation.json
│
├── audio/ # Session audio files
│ ├── pose1.mp3
│ ├── pose2.mp3
│ └── pose3.mp3
│
└── images/ # Pose images
├── pose1.png
├── pose2.png
└── pose3.png

---

## 🚀 Getting Started

### 1️⃣ Clone the repo
```bash
git clone https://github.com/your-username/yogify.git
cd yogify
```

### 2️⃣ Install dependencies
```bash
flutter pub get
```

### 3️⃣ Run the app
```bash
flutter run
```

---

### ⚙️ Configuration
- Make sure to add assets in pubspec.yaml:
```bash
flutter:
  assets:
    - assets/sessions/
    - assets/images/
    - assets/audio/
```

---

### 🛠️ Tech Stack
- Flutter (UI framework)
- audioplayers (Audio playback)
- JSON-driven session data

---

### 📌 To-Do / Future Improvements
- 🌙 Dark mode support
- 📱 Session progress saving
- 🔔 Notifications for daily yoga reminders
- 📊 Statistics dashboard (streaks, completed sessions)

---

### 🤝 Contributing
- Pull requests are welcome!
- If you’d like to add new yoga flows, just create a new JSON file inside assets/sessions/.

---

### 📜 License
This project is licensed under the MIT License.

## 👨‍💻 Author
Aryan Raj
