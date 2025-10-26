# ⚙️ Converse Chat Adapters

[![pub package](https://img.shields.io/pub/v/converse_chat_adapters.svg)](https://pub.dev/packages/converse_chat_adapters)
[![GitHub Repo](https://img.shields.io/badge/github-repo-blue)](https://github.com/rbishtdev/converse_chat_sdk)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

> **Converse Chat Adapters** form the **infrastructure layer** of the [Converse Chat SDK](https://pub.dev/packages/converse_chat_sdk).  
> They connect the clean domain layer from [`converse_chat_core`](https://pub.dev/packages/converse_chat_core) to real-world backends like **Firebase Firestore**, **Realtime Database**, and **Firebase Storage**.

---

## 🚀 Overview

This package provides **Firebase-based repository implementations** for the abstract interfaces defined in `converse_chat_core`.  
It handles message persistence, user management, presence tracking, and file uploads.

```
App / UI
   ↓
Converse Chat SDK
   ↓
Converse Chat Adapters (Firebase, REST)
   ↓
Converse Chat Core
   ↓
Firebase / REST / Custom backend
```

It includes:
- 🔥 **Firebase Chat Repository** — sending, receiving, and syncing messages
- 👤 **Firebase User Repository** — managing user metadata
- 🟢 **Firebase Presence Repository** — tracking online/offline users
- 📎 **Firebase Attachment Repository** — file and media uploads
- ⚙️ **Adapter Initializer** — handles Firebase setup before use
- 🧩 **Collection Helpers** — centralized Firestore path and collection naming

---

## 🧠 Architecture

Follows the **Clean Architecture** structure:

```
+------------------------------+
|  Presentation Layer (UI/SDK) | ← converse_chat_sdk
+------------------------------+
|  Domain Layer (Use Cases)    | ← converse_chat_core
+------------------------------+
|  Data Layer / Adapters       | ← converse_chat_adapters
+------------------------------+
|  Infrastructure (Firebase)   | ← External systems
+------------------------------+
```

This package provides the concrete implementations of:
- `IChatRepository`
- `IUserRepository`
- `IAttachmentRepository`
- `IPresenceRepository`

defined in the `core` domain layer.

---

## 🧩 Key Features

✅ **Implements all domain repositories** from `core`  
✅ **Firebase Realtime Database + Firestore** support  
✅ **Presence tracking** using `onDisconnect()` (mobile)  
✅ **Attachment uploads** via Firebase Storage  
✅ **Centralized Firestore collection management**  
✅ **Adapter initializer** for clean setup  
✅ **Easily replaceable adapters** for REST or Supabase backends

---

## 🧱 Folder Structure

```
lib/
├─ converse_chat_adapters.dart        # ✅ Public entrypoint (exports all implementations)
└─ src/
    ├─ repositories/
    │   ├─ firebase_chat_repository.dart        # Message send/receive/sync logic
    │   ├─ firebase_user_repository.dart        # User management
    │   ├─ firebase_presence_repository.dart    # Online/offline presence
    │   ├─ firebase_attachment_repository.dart  # File upload/download
    │   └─ ...                                 # (Future) additional integrations
    │
    ├─ firebase_chat_adapter.dart               # Combines all Firebase repositories
    ├─ firebase_collections.dart                # Defines Firestore collection names
    ├─ adapter_initializer.dart                 # Handles Firebase initialization
    └─ ...                                     # (Future) REST or WebSocket adapters
```

---

## ⚙️ Initialization Example

Although `converse_chat_sdk` initializes adapters automatically,  
you can use this package directly for testing or custom setups.

```dart
import 'package:converse_chat_adapters/converse_chat_adapters.dart';

Future<void> main() async {
  // Initialize Firebase and adapters
  await AdapterInitializer.initializeFirebase();

  // Create a chat repository instance
  final chatRepo = FirebaseChatRepository();

  // Send a message
  await chatRepo.sendMessage(
    chatId: 'chat_123',
    senderId: 'user_001',
    text: 'Hello world 👋',
  );
}
```

---

## 🧰 Installation

Typically, you don’t install this package directly.  
It’s automatically included when using [`converse_chat_sdk`](https://pub.dev/packages/converse_chat_sdk).

However, you can also add it manually for experimental setups:

```yaml
dependencies:
  converse_chat_adapters: ^1.0.0
```

Then import it:

```dart
import 'package:converse_chat_adapters/converse_chat_adapters.dart';
```

---

## 🔗 Related Packages

| Package | Description |
|----------|-------------|
| [converse_chat_core](https://pub.dev/packages/converse_chat_core) | Core domain models and use cases |
| [converse_chat_sdk](https://pub.dev/packages/converse_chat_sdk) | Main SDK — includes adapters and exposes developer-friendly API |

---

## 🧠 Topics

`firebase`, `chat`, `messaging`, `realtime`, `sdk`, `clean-architecture`, `flutter`, `presence`, `storage`, `core`

---

## 🪪 License

This project is licensed under the [MIT License](LICENSE).

---

## 👨‍💻 Author

**Rajendra Bisht**  
[GitHub @rbishtdev](https://github.com/rbishtdev)
