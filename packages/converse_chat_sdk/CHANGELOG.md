# Changelog

All notable changes to the **Converse Chat SDK** package will be documented in this file.  
This project adheres to [Semantic Versioning](https://semver.org/).

---

## [1.0.0] - 2025-10-26 - Initial Public Alpha Release

### ✨ Core Features

- Real-time messaging powered by Firestore and Realtime Database
- Presence tracking (online/offline) and last seen support
- Typing indicators with fine-grained user-level updates
- Message pipeline with encryption hooks and plugin extension support
- Offline-first architecture with local cache fallbacks
- Dependency Injection friendly — bring your own adapter or backend

### 🧩 Architecture Highlights

- Layered clean architecture:
    - `converse_chat_core` — pure Dart domain logic and value objects
    - `converse_chat_adapters` — Firebase adapters (Firestore, Storage, Realtime DB)
    - `flutter_chat_sdk` — Flutter integration and SDK-level orchestration
- Introduced `MessagePipeline`, `PluginRegistry`, and `IRepository` contracts for full extensibility

### 💬 Developer Experience

- Added **`ConverseChatClient.initialize()`** for quick setup with Firebase
- Introduced **streams** for messages, presence, and typing indicators
- Added error handling with `Either<ChatFailure, T>` using `fpdart`
- Built-in **plugin registry** for encryption, analytics, and moderation

### 🧱 Package Ecosystem

| Package | Type | Purpose |
|---------|------|---------|
| `converse_chat_core` | Pure Dart | Entities, Repositories, Use Cases |
| `converse_chat_adapters` | Flutter + Firebase | Backend integrations |
| `flutter_chat_sdk` | Flutter | Entry point & orchestration |
| `flutter_chat_ui` | Flutter (coming soon) | Customizable UI widgets |

### 🧪 Example Apps

- **Core Example (CLI):** Runs the core logic without Firebase or UI
- **Adapter Example (Flutter):** Uses Firebase adapter directly for backend tests
- **SDK Example:** End-to-end chat demo with presence, typing, and message flow

### 🔐 Stability

- Version 1.0.0 is feature-complete and considered *alpha-stable*
- API may evolve slightly before 1.1.0, but major interfaces are now stable

### 🧩 Foundation Setup

- Created project structure with **Melos** workspace and modular packages
- Implemented domain models: `Message`, `User`, `Attachment`, `MessageStatus`
- Defined repository contracts: `IChatRepository`, `IUserRepository`, `IAttachmentRepository`, `IPresenceRepository`
- Added `MessagePipeline` and `EncryptionStrategy` abstractions
- Introduced unified error handling (`ChatFailure`, `ErrorMapper`)
- Basic in-memory repositories for early testing

### 🚀 Roadmap / Planned Features

- [ ] Add **group chat** and participants management
- [ ] Add **attachment support** for 1:1 and group chat
- [ ] Add **message reactions** and **reply threading**
- [ ] Add **read receipts** and message analytics hooks
- [ ] Add **Supabase & REST adapters**
- [ ] Launch **`flutter_chat_ui`** package with full theming support  
