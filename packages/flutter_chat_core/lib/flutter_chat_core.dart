/// Flutter Chat Core SDK
///
/// This package provides a clean, backend-agnostic chat architecture
/// built on Clean Architecture principles. It includes:
/// - Domain entities
/// - Use cases
/// - Repositories (ports)
/// - Services (pipelines, encryption, plugin system)
/// - Chat controller
///
/// The `flutter_chat_core` package does **not** depend on Flutter widgets.
/// You can use it for pure Dart or backend logic as well.
///
/// Example usage:
///
/// ```dart
/// final sdk = await ChatSDK.initialize(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
///
/// sdk.controller.sendText(
///   chatId: 'chat_123',
///   senderId: 'user_456',
///   text: 'Hello there!',
/// );
/// ```
library flutter_chat_core;

// -----------------------------------------------------------------------------
// DOMAIN LAYER
// -----------------------------------------------------------------------------

export 'src/domain/entities/message.dart';
export 'src/domain/entities/attachment.dart';
export 'src/domain/entities/chat.dart';
export 'src/domain/entities/user.dart';

export 'src/domain/value_objects/chat_id.dart';
export 'src/domain/value_objects/message_id.dart';
export 'src/domain/value_objects/user_id.dart';
export 'src/domain/value_objects/timestamp.dart';
export 'src/domain/entities/message_status.dart';

// -----------------------------------------------------------------------------
// PORTS (INTERFACES)
// -----------------------------------------------------------------------------

export 'src/ports/i_chat_repository.dart';
export 'src/ports/i_user_repository.dart';
export 'src/ports/i_attachment_repository.dart';
export 'src/ports/i_presence_repository.dart';

// -----------------------------------------------------------------------------
// USE CASES
// -----------------------------------------------------------------------------

export 'src/usecases/send_message.dart';
export 'src/usecases/fetch_messages.dart';
export 'src/usecases/mark_read.dart';

// -----------------------------------------------------------------------------
// SERVICES
// -----------------------------------------------------------------------------

export 'src/services/message_pipeline.dart';
export 'src/services/encryption_strategy.dart';

// -----------------------------------------------------------------------------
// PLUGINS SYSTEM
// -----------------------------------------------------------------------------

export 'src/plugins/chat_plugin.dart';
export 'src/plugins/plugin_registry.dart';

// -----------------------------------------------------------------------------
// CONTROLLER
// -----------------------------------------------------------------------------

export 'src/controller/chat_controller.dart';

// -----------------------------------------------------------------------------
// ERRORS
// -----------------------------------------------------------------------------

export 'src/errors/core_errors.dart';

// -----------------------------------------------------------------------------
// SDK ENTRYPOINT
// -----------------------------------------------------------------------------

export 'src/api/chat_sdk.dart';

// -----------------------------------------------------------------------------
// CHAT ID GENERATORS
// -----------------------------------------------------------------------------

export 'src/utils/chat_id_generator.dart';
