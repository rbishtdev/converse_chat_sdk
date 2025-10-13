/// Defines a contract for encrypting and decrypting message content.
///
/// This enables the SDK to support multiple encryption mechanisms:
/// - No-op (default)
/// - AES symmetric encryption
/// - Public/private key encryption
/// - External encryption service
abstract class IEncryptionStrategy {
  /// Encrypts the given plaintext message.
  ///
  /// Should return the ciphertext or encoded representation.
  Future<String> encrypt(String plaintext);

  /// Decrypts the given ciphertext message.
  ///
  /// Should return the original plaintext.
  Future<String> decrypt(String ciphertext);
}

/// Default no-op encryption strategy (does nothing).
///
/// Used when encryption is not enabled in the SDK configuration.
class NoEncryptionStrategy implements IEncryptionStrategy {
  @override
  Future<String> encrypt(String plaintext) async => plaintext;

  @override
  Future<String> decrypt(String ciphertext) async => ciphertext;
}
