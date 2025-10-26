## 1.0.1

### 🧹 Improvements
- Renamed method `ensureChatExists` → `createOrJoinChat` for better readability and consistency across SDK layers.
- Aligned core naming with upcoming adapter and SDK packages.
- Updated internal docs and examples.

### ℹ️ Notes
This update refines API naming prior to public adoption.
No functional or breaking changes — safe to upgrade.


## 1.0.0

- Initial release of **Converse Chat Core** 🎉
- Introduced domain entities (`Message`, `Chat`, `User`)
- Added value objects (`MessageId`, `UserId`, `ChatId`, `Timestamp`)
- Implemented use cases (`SendMessage`, `FetchMessages`, `MarkRead`)
- Added plugin system and registry (`ChatPlugin`, `PluginRegistry`)
- Included base repository interfaces for chat, user, and presence
- Added typed failure and error handling using fpdart
