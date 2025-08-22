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

<img width="330" height="841" alt="image" src="https://github.com/user-attachments/assets/319cff74-2006-4b30-8908-585b68e0ae20" />

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
