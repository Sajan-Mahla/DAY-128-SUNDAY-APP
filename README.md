# 🍎 HabitOne

A **minimal daily habit tracker** built with **SwiftUI + Combine**.  
Designed to keep your focus on consistency — one tap at a time.

---

## ✨ Features

- ✅ Add and track your daily habits  
- 🔁 Auto-reset every new day (Combine-powered timer)  
- 💾 Local data persistence using `UserDefaults`  
- 📊 Progress bar showing completion percentage  
- 🎨 Clean Apple-style interface with soft animations  

---

## 🧠 Tech Stack

- **SwiftUI** — declarative UI  
- **Combine** — timer publisher for daily reset  
- **@AppStorage / UserDefaults** — lightweight local storage  
- **MVVM Architecture** — clean and testable structure  

--

## 🚀 How It Works

1. Tap the **+ button** to add a new habit (with emoji).  
2. Tap the **circle** to mark it as complete for today.  
3. At midnight (or next app launch), habits automatically reset for a fresh start.  

---

## 🧩 Code Highlights

**Combine-powered auto-reset**
```swift
Timer.publish(every: 60, on: .main, in: .common)
    .autoconnect()
    .sink { _ in
        resetIfNewDay()
    }
```

**Habit model**
```swift
struct Habit: Identifiable, Codable {
    var id = UUID()
    var title: String
    var emoji: String
    var isCompleted: Bool
    var lastCompletedDate: Date?
}
```

---

## 🌅 Vision

> "Small habits. Big outcomes."

HabitOne isn't just a tracker — it's a daily reminder that consistency builds greatness.

Built as part of my **App-a-Week journey (Day 128)** toward my Apple Cupertino goal 🍏

---

## 🧑‍💻 Author

**Sajan Mahla**  
Driven by one mission — to build IN Apple.

---

## 📝 License

This project is open source and available under the [MIT License](LICENSE).

---

**⭐️ If you found this helpful, consider giving it a star!**
