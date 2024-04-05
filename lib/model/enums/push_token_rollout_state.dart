// Do not rename or remove values, they are used for serialization. Only add new values.
enum PushTokenRollOutState {
  rolloutNotStarted,
  generatingRSAKeyPair,
  generatingRSAKeyPairFailed,
  sendRSAPublicKey,
  sendRSAPublicKeyFailed,
  parsingResponse,
  parsingResponseFailed,
  rolloutComplete,
}
