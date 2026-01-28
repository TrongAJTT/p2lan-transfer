<div align="center">
    <img style="width:30%;" src="./assets/app_icon.png"/>
    <h1>P2Lan Transfer</h1>
    <h3 >Make LAN transfers easy, no server needed</h3> 
</div>

A simple cross-platform file transfer application that enables direct peer-to-peer communication over local networks. Built with Flutter for Windows and Android platforms.

> Please note that this project is still in active development. Some features may be incomplete or unstable. Your feedback and contributions are welcome!

> A migration to Clean Architecture is planned for the next versions.

## 📸 Screenshot

<div align="center">
    <img style="width:90%;" src="./assets/preview/desktop1.png"/>
    <img style="width:90%;" src="./assets/preview/desktop2.png"/>
    <img style="width:90%;" src="./assets/preview/desktop3.png"/>
    <img style="width:90%;" src="./assets/preview/desktop4.png"/>
    <img style="width:30%;" src="./assets/preview/mobile1.jpg"/>
    <img style="width:30%;" src="./assets/preview/mobile2.jpg"/>
    <img style="width:30%;" src="./assets/preview/mobile3.jpg"/>
</div>

## ✨ Why I made this and what it does

It was a beautiful day when I returned from my lecture, having taken many photos of formulas in the classroom, and I wanted to review them on my laptop. However, I realized that:

- If I used a cable to transfer, it was fast, sure, but I had to go to the laptop, navigate to the correct photo folder, and then select the photos. Why couldn't I just select them directly on my phone for a more intuitive experience?
    
- If I chose to send photos via third-party apps like Telegram or WhatsApp, it would be troublesome to send a large number of files, and if I sent photos directly, the quality might be reduced due to compression.
    
- If I uploaded them to Google Drive or OneDrive, it was convenient and the quality was good, but then I had to spend time deleting them afterward, which was very annoying.

That's precisely why I created this app: to quickly transfer files and data between devices in situations like these.

<details>  
<summary>Allegorical Version</summary> 

---
Once upon a time, in a land where knowledge was likened to precious gems, there lived a scholar named John. John loved to learn, especially the intricate formulas of mathematics and physics. Whenever he attended lectures, John would carefully use his magic mirror (which people called a phone) to record these formulas, for they were as precious as mysterious incantations.

One afternoon, with the golden sun casting its glow, John returned home, eager to re-experience the charms he had just collected on his magical stone table (laptop). But alas, when he pulled out the silver thread (USB cable) to connect the two worlds – his magic mirror and the stone table – John noticed John inconvenience: to view the charms, he had to fumble through the labyrinthine library of the stone table, find the right shelf, and only then could he retrieve each gem. "Why can't I just select them directly from my magic mirror, for a more intuitive and quick process?" John sighed.

Then John thought of the swift messenger pigeons (third-party apps like Telegram, Zalo). They could indeed carry charms far, but if it was a huge collection of charms, these pigeons became slow and troublesome. Worse yet, sometimes the charms were compressed, losing their original luster.

John then tried sending the charms to the wondrous clouds (Google Drive, OneDrive). It was convenient, and the quality of the charms remained intact! But afterwards, John had to expend effort climbing onto the cloud to delete his traces. "How annoying!" John lamented.

In his contemplation, John idea flashed in An's mind like a bolt of lightning. He realized that what he needed was not silver threads, messenger pigeons, or wondrous clouds, but a **Mystical Gateway**. A gateway that would allow charms to travel instantly, intact, between his magic mirror and the magical stone table, without any troublesome intermediaries, and all directly controlled by John from his magic mirror.

And so, John toiled day and night, using his intellect and creativity to create **The App – The Mystical Gateway**. From then on, not only John but everyone in the land could easily exchange precious gems and charms between their worlds with unprecedented speed and convenience.

Fin.

---
</details>

P2Lan Transfer helps you share files and chat with devices on the same local network without requiring any central server or complex setup. Just run the app on both devices and they can find each other automatically. You can also chat and send media or file with other devices locally (no server needed) and sync clipboard with that chat.

## 🚀 Key Features

### 📁 File Transfer
- **Direct P2P sharing**: Send files directly between devices on the same network
- **Multiple file support**: Share multiple files at once
- **Resume capability**: Continue interrupted transfers where they left off
- **Transfer history**: Keep track of your recent file transfers

### 💬 Basic Chat
- **Simple messaging**: Send text messages between connected devices
- **Clipboard sync**: Automatically share clipboard content between devices
- **Media sharing**: Send images through chat with preview
- **Chat customization**: Configure clipboard sharing and auto-delete options

### 🔧 Advanced Settings
- **Security options**: Choose between no encryption, AES-GCM, or ChaCha20-Poly1305
- **Compression settings**: Reduce transfer time with configurable compression
- **Network configuration**: Customize network discovery and transfer settings
- **User interface**: Switch between normal and compact layout modes

### 🎨 User Experience
- **Responsive design**: Adapts to different screen sizes (mobile/desktop)
- **Theme support**: Light, dark, and system theme options
- **Multi-language**: Available in English and Vietnamese
- **Settings persistence**: Your preferences are saved automatically

## 💻 Platform Support

### 🖥️ Windows
- Windows 10 (1903) or newer
- 64-bit architecture support

### 📱 Android
- Android 7.0 (API 24) or newer
- ARM64/ARMv7 architecture support

## 🔧 Technology Stack

- **Flutter**: Cross-platform UI framework
- **Isar Database**: Local data storage for settings and chat history
- **Dart Isolates**: Background processing for file transfers
- **UDP/TCP**: Network communication protocols
- **Material Design 3**: Modern UI components

## 🛠️ Getting Started

### For Users
1. Download the appropriate version for your platform
2. Install and run the application
3. Make sure devices are on the same local network
4. Start sharing files and chatting!

### For Developers
```bash
# Clone the repository
git clone https://github.com/TrongAJTT/p2lan-transfer.git
cd p2lan-transfer

# Install dependencies
flutter pub get

# Generate required code
dart run build_runner build

# Run on your preferred platform
flutter run
```

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── controllers/                 # P2P and state management
├── models/                      # Data models and schemas
├── services/                    # Core services (P2P, settings, etc.)
├── screens/                     # App screens and UI
├── widgets/                     # Reusable UI components
├── layouts/                     # Layout components
├── utils/                       # Helper functions
└── l10n/                        # Localization files
```

## ❤️ Donate to this project

P2Lan Transfer helps you transfer data between devices on the same network more easily. If you find it useful, consider supporting me to maintain and improve it. Thank you very much!

You can donate either via [**Github Sponsor**](https://github.com/sponsors/TrongAJTT/) or **[Buy me a coffee](buymeacoffee.com/trongajtt)** (write your feelings about the application). More details about inside the app.

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Report bugs and issues
- Suggest new features
- Improve translation
- Improve documentation

## 📄 License

This project is licensed under the GPL-3.0 License.

## 🙏 Credits

Built with love using Flutter and the amazing open-source community libraries.

---

*P2Lan Transfer - Simple file sharing, no fuss.*