## 1.0.1

### 🧹 Improvements
- Renamed method `ensureChatExists` → `createOrJoinChat` for better readability and consistency across SDK layers.
- Aligned core naming with upcoming adapter and SDK packages.
- Updated internal docs and examples.

### ℹ️ Notes
This update refines API naming prior to public adoption.
No functional or breaking changes — safe to upgrade.


## 1.0.0

- Initial release of **Converse Chat Adapters** 🎉
- Added Firebase-based infrastructure layer for the Converse Chat SDK
- Implemented all core repository interfaces from `converse_chat_core`
    - `IChatRepository` → `FirebaseChatRepository`
    - `IUserRepository` → `FirebaseUserRepository`
    - `IPresenceRepository` → `FirebasePresenceRepository`
    - `IAttachmentRepository` → `FirebaseAttachmentRepository`
- Introduced `AdapterInitializer` for Firebase setup and configuration
- Added `FirebaseChatAdapter` to group repository implementations
- Centralized Firestore path definitions via `firebase_collections.dart`
- Integrated message, user, presence, and attachment syncing using Firebase
- Prepared for future support for REST and WebSocket adapters
