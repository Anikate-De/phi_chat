![Logo](logo-banner.png)

A cross-platform chat application, made with Flutter, with a Firebase BaaS and 100% client-side code execution.

Talk to your friends and family just by using their email IDs. Communication in Phi Chat takes place via **`Conversations`**. Set a nice photo, a catchy name and add as many people as you want in a conversation. You can even have multiple conversations with the same person!

Invite people to your conversation in a hassle-free way, by letting them scan a QR Code or by sending them a super-secret code. 🤫

## 🌟 Features

- Email + Password Authentication & Verification
- Google OAuth Sign-in
- Responsive Layout
- Customisable User Profiles
- QR-Code enabled sharing
- Swipe-to-Reply
- Photo Uploads

## 📱 Screenshots
![Screenshots](screenshots/Screenshots-1.png "`Login` Screen, `Create User` Screen, `Conversations` Screen")

![Screenshots](screenshots/Screenshots-2.png "`Create Conversation` Screen, `Chat` Screen, `Share Conversation` Screen")

## ❓How to Use

### Pre-requisites

- **Flutter** is installed and added to `PATH`
- **Firebase Account**

### Steps to Follow

- Create a Firebase project for Phi-Chat in the [Firebase Console](https://console.firebase.google.com/)
  - Enable the desired platforms & follow initialisation instrux
  - Enable `Email/Password` in _Authentication > Sign-in method_
  - Enable `Google` (Optional)
- Initialise firebase
- For Android testing -

  - In your terminal, execute -

    ```
    cd android
    gradlew signingReport
    ```

    NOTE - In case your terminal doesn't recognise 'gradlew' as a valid command, run your flutter android app once by following the next bullet points. Then come back to this section and retry.

  - Add your debug **SHA-1** & **SHA-256** keys in your _Firebase Project Settings_
  - Download the latest **google-services.json** file and put it in the Firebase specified android subdirectory

- Get the packages, in your terminal, execute -
  ```
  flutter clean
  flutter pub get
  ```
- That's it, you can now run it!
  ```
  flutter run
  ```
- **Optional:** To ensure working of Google Sign In, follow the steps in their [Platform Integration Guide](https://pub.dev/packages/google_sign_in#platform-integration)

## 🤝 Contributing

Contributions are always welcome!

See the [Contribution Guide](contributing.md) for ways to get started.

## 🤩 Inspired By

This project was inspired by Angela Yu's `FlashChat` Flutter application, which was demonstrated in her course [The Complete 2021 Flutter Development Bootcamp with Dart](https://www.udemy.com/course/flutter-bootcamp-with-dart/) on Udemy.

## 📖Lessons Learned

Phi Chat has been and forever will be a great compilation of newly found information and learning. While creating this project, my motto was to teach myself about Flutter and BaaS Platforms as much as I could.

I learnt many things along the way, the most notable ones are mentioned below -

- Flutter Streams and Futures, asynchronous code
- Using multiple features of Firebase
- Adding OAuth Providers
- Building responsive UI
- Using community-built packages, accessing the Device Filesystem
- Gesture Detectors & conditional UI (for message bubbles)
- **and so much more...**

## 💡 Authors

- [@Anikate De](https://www.github.com/Anikate-De)

## 📝 License

Copyright © 2022-present, Anikate De

This project is licensed under [Apache License 2.0](LICENSE)