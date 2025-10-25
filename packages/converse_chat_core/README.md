# 🗣️ Converse Chat Core

[![pub package](https://img.shields.io/pub/v/converse_chat_core.svg)](https://pub.dev/packages/converse_chat_core)
[![GitHub Repo](https://img.shields.io/badge/github-repo-blue)](https://github.com/rbishtdev/converse_chat_sdk)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

> **Converse Chat Core** provides the domain layer, entities, and clean architecture foundation for the [Converse Chat SDK](https://github.com/rbishtdev/converse_chat_sdk).  
> It is platform-agnostic and can be extended or integrated with any backend (Firebase, Supabase, custom servers, etc.).

---

## 🚀 Overview

Converse Chat Core defines the **fundamental data models, use cases, and plugin architecture** that power all other Converse packages:

```
App / SDK
   ↓
Converse Chat SDK
   ↓
Converse Chat Core
   ↓
Adapters (Firebase, REST, etc.)
```

It provides:
- 🧱 **Entities & Value Objects** — `User`, `Message`, `Chat`, `Attachment`
- ⚙️ **Use Cases** — `SendMessage`, `FetchMessages`, `MarkRead`
- 🔌 **Plugin System** — Extend chat behavior dynamically
- 🧩 **Repository Interfaces** — For persistence & network integration
- 🔐 **Error Handling** — Custom error and failure hierarchy

---

## 🧠 Architecture

This package follows **Clean Architecture** principles:

```
+------------------------+
|    Presentation Layer  |  ← (UI / SDK / Flutter widgets)
+------------------------+
|     Domain Layer       |  ← converse_chat_core
|  (Entities, UseCases)  |
+------------------------+
|  Data Layer / Adapters |  ← (Firebase, REST, etc.)
+------------------------+
```

You can think of `converse_chat_core` as the **heart** of your chat system —  
independent of any backend, UI, or storage mechanism.

---

## 🧩 Key Features

✅ **Pure Dart** — works with any backend  
✅ **Extendable plugin system**  
✅ **Typed entities** with strong immutability  
✅ **Error-safe functional approach** using [fpdart](https://pub.dev/packages/fpdart)  
✅ **Lightweight and testable**

---

## 🧰 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  converse_chat_core: ^1.0.0
```

Then import it:

```dart
import 'package:converse_chat_core/converse_chat_core.dart';
```

---

## 💬 Example Usage

```dart
import 'package:converse_chat_core/converse_chat_core.dart';

void main() {
  final user = User(id: UserId('alice'), name: 'Alice');
  final chat = Chat(id: ChatId('chat_1'), participants: [user]);

  final message = Message.create(
    id: MessageId.unique(),
    userId: user.id,
    text: 'Hey, this is a test!',
  );

  print('Message from ${user.name}: ${message.text}');
}
```

✅ Works fully offline  
✅ Easily extendable for Firebase or custom backends

---

## ⚙️ Extending with Plugins

You can register plugins to modify message flow dynamically.

```dart
final registry = PluginRegistry();
registry.register(MyEncryptionPlugin());

final processed = await registry.runOnSend(message);
```

See [plugin_registry.dart](lib/src/plugins/plugin_registry.dart) for details.

---

## 🧱 Folder Structure

```
lib/
├─ converse_chat_core.dart       # ✅ Public entrypoint (exports everything below)
└─ src/
    ├─ domain/
    │   ├─ entities/
    │   │   ├─ message.dart           # Defines Message entity (id, text, senderId, timestamp, status)
    │   │   ├─ chat.dart              # Defines Chat entity (id, participants, metadata)
    │   │   ├─ user.dart              # Defines User entity (id, name, avatar, presence)
    │   │   ├─ attachment.dart        # Defines Attachment entity (type, url, mime)
    │   │   └─ message_status.dart    # Enum for sent, delivered, read, failed
    │   │
    │   └─ value_objects/
    │       ├─ user_id.dart           # Value object for unique user identifiers
    │       ├─ message_id.dart        # Value object for message IDs
    │       ├─ chat_id.dart           # Value object for chat IDs
    │       └─ timestamp.dart         # Immutable value object for time metadata
    │
    ├─ usecases/
    │   ├─ send_message.dart          # Handles message send logic
    │   ├─ fetch_messages.dart        # Retrieves chat history
    │   └─ mark_read.dart             # Marks message as read
    │
    ├─ ports/
    │   ├─ i_chat_repository.dart     # Abstract repository for chat operations
    │   ├─ i_user_repository.dart     # Abstract user repository
    │   ├─ i_attachment_repository.dart # For media uploads/downloads
    │   └─ i_presence_repository.dart # For tracking online/offline state
    │
    ├─ services/
    │   ├─ message_pipeline.dart      # Message preprocessing & plugin chain
    │   ├─ encryption_strategy.dart   # Defines encrypt/decrypt strategy interface
    │   └─ ...                        # (Future) notification or caching services
    │
    ├─ plugins/
    │   ├─ chat_plugin.dart           # Abstract class for plugins (onSend/onReceive)
    │   └─ plugin_registry.dart       # Registers and runs plugins sequentially
    │
    ├─ controller/
    │   └─ chat_controller.dart       # Coordinates between use cases and SDK layer
    │
    └─ errors/
        ├─ core_errors.dart           # Common exceptions (e.g., NetworkError, InvalidEntity)
        ├─ chat_failure.dart          # Failure models for domain layer (used with fpdart Either)
        └─ error_mapper.dart          # Maps exceptions into Failures or Error types

```

---

## 🧪 Example Project

A minimal runnable example is available in the [example/](example/) directory:

```bash
dart run example/main.dart
```

---

## 📦 Related Packages

| Package | Description |
|----------|-------------|
| [`converse_chat_sdk`](https://pub.dev/packages/converse_chat_sdk) | High-level SDK with Firebase and adapters |
| [`converse_chat_ui`](https://pub.dev/packages/converse_chat_ui) | Flutter chat widgets and screens |
| [`converse_chat_adapters`](https://pub.dev/packages/converse_chat_adapters) | Infrastructure integrations (Firebase, REST, etc.) |

---

## 🧠 Topics

`chat`, `messaging`, `sdk`, `firebase`, `realtime`, `flutter`, `core`, `clean-architecture`

---

## 🪪 License

This project is licensed under the [MIT License](LICENSE).

---

## 👨‍💻 Author

**Rajendra Bisht**  
[GitHub @rbishtdev](https://github.com/rbishtdev)
