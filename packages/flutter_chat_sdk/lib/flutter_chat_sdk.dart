library flutter_chat_sdk;

// Export the SDK facade
export 'src/chat_sdk.dart';

// Re-export core functionality for advanced users
export 'package:flutter_chat_core/flutter_chat_core.dart';

// Re-export adapters so devs can swap Firebase for others later
export 'package:flutter_chat_adapters/flutter_chat_adapters.dart';

// (Optional) Export UI package when it’s ready
// export 'package:flutter_chat_ui/flutter_chat_ui.dart';
