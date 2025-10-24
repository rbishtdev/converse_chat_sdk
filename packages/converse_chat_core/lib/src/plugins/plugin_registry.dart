import 'chat_plugin.dart';
import '../domain/entities/message.dart';

/// Manages the lifecycle and execution of all registered [ChatPlugin]s.
///
/// This allows the SDK to be extended dynamically at runtime — developers
/// can register multiple plugins to intercept message send/receive flows.
class PluginRegistry {
  final List<ChatPlugin> _plugins = [];

  /// Registers a [ChatPlugin] to the pipeline.
  void register(ChatPlugin plugin) {
    _plugins.add(plugin);
    plugin.onInit();
  }

  /// Unregisters all plugins and disposes their resources.
  Future<void> dispose() async {
    for (final plugin in _plugins) {
      await plugin.onDispose();
    }
    _plugins.clear();
  }

  /// Runs all [onSend] hooks sequentially before sending a message.
  ///
  /// Each plugin receives the output of the previous one.
  Future<Message> runOnSend(Message message) async {
    var processed = message;
    for (final plugin in _plugins) {
      processed = await plugin.onSend(processed);
    }
    return processed;
  }

  /// Runs all [onReceive] hooks sequentially after receiving a message.
  Future<Message> runOnReceive(Message message) async {
    var processed = message;
    for (final plugin in _plugins) {
      processed = await plugin.onReceive(processed);
    }
    return processed;
  }
}
