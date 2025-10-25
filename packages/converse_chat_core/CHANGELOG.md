## 1.0.0

- Initial release of **Converse Chat Core** 🎉
- Introduced domain entities (`Message`, `Chat`, `User`)
- Added value objects (`MessageId`, `UserId`, `ChatId`, `Timestamp`)
- Implemented use cases (`SendMessage`, `FetchMessages`, `MarkRead`)
- Added plugin system and registry (`ChatPlugin`, `PluginRegistry`)
- Included base repository interfaces for chat, user, and presence
- Added typed failure and error handling using fpdart
