# Biometric protection for Push keys

This design separates three independent Push enrollment requirements:

```text
app_force_unlock=biometric
app_biometric_level=strong
app_invalidate_on_biometric_change=true
```

The existing privacyIDEA policy action is `push_app_force_unlock`. The two new
server actions proposed by this design are `push_app_biometric_level` and
`push_app_invalidate_on_biometric_change`. The enrollment URL should use the
short `app_*` parameter names, consistent with the existing
`app_force_unlock` parameter. For compatibility with an initial server
implementation, the app also accepts the `push_app_*` names for the two new
parameters. If both forms are present, the more specific `push_app_*` value
wins.

## Defaults and policy combinations

When `app_force_unlock=biometric` is present and either new parameter is
missing, the app defaults to `strong` and `true`. This makes existing biometric
Push policies fail closed without requiring a simultaneous server upgrade.

| Biometric level | Invalidate on change | Client behavior |
| --- | --- | --- |
| `strong` | `true` | Strong biometric for every signature; key invalidated after enrollment change |
| `strong` | `false` | Strong biometric for every signature; key survives enrollment change |
| `any` | `true` | Treated as strong because enrollment-bound cryptographic access cannot safely use weak Android biometrics |
| `any` | `false` | Android `BIOMETRIC_WEAK` (which also accepts strong biometrics) before every use; widest device compatibility, but the private key cannot be bound to weak enrollment in Android Keystore and remains in encrypted app storage |

Device PIN, pattern, and password are never fallback authenticators when
`app_force_unlock=biometric`, including the `any` + `false` compatibility
mode.

The recommended policy set is:

```text
push_app_force_unlock=biometric
push_app_biometric_level=strong
push_app_invalidate_on_biometric_change=true
```

It requires class-3 biometrics on Android, never falls back to device
credentials, and makes a biometric enrollment change invalidate the existing
Push key.

## Key lifecycle

On Android, the app wraps the Push RSA private key with an Android Keystore AES
key. The key permits only `BIOMETRIC_STRONG`, requires authentication for every
cryptographic operation, and uses
`setInvalidatedByBiometricEnrollment(true)` when requested. Adding a biometric
or removing all biometrics invalidates an enrollment-bound key. Android does
not guarantee invalidation when only one of several enrolled biometrics is
removed.

On iOS, the app stores the Push RSA private key in a non-synchronizing Keychain
item protected by biometric-only access. `biometryCurrentSet` binds it to the
current Face ID/Touch ID enrollment when invalidation is requested;
`biometryAny` provides per-use biometric access without that binding. iOS does
not expose Android-style weak and strong biometric classes, so Face ID/Touch ID
is the platform equivalent used for `strong`.

New Push tokens are protected before their public key is sent to privacyIDEA.
An already deployed biometric Push token that has no native enrollment binding
is invalidated and must be enrolled again. Transparently binding such a legacy
token on first use would trust any biometric added after its original
enrollment, which cannot satisfy change detection. An interrupted enrollment
may be repaired only when the native protected key already exists. After
protection, the Dart token record contains no private key. Native protected
material is removed when the local token is deleted.

Migration state must be written to secure token storage before a signature is
sent over the network. If that write fails, rollout, polling, approval, or FCM
token update stops without sending the signed request. Startup reconciliation
repairs an interrupted migration before the token can be used.

Native operations are serialized per token. Periodic automatic polling skips
auth-per-use tokens so it cannot open a biometric prompt every few seconds;
the user can still poll those tokens manually, while normal FCM delivery does
not require use of the private key. Manual polling processes tokens
sequentially so multiple protected tokens cannot open competing biometric
prompts.

If the platform reports an enrollment-bound key as invalid, the token is
persisted as invalidated, Push approval is blocked, and the UI asks the user to
remove and enroll the token again. A temporary authentication failure or user
cancellation does not invalidate the token.

Once a key is protected natively, relaxing the policy does not export it back
to Dart. Any transition from `invalidate_on_biometric_change=false` to `true`
invalidates the local token. This also covers a policy response racing with
initial native protection: a key created without enrollment binding cannot be
retroactively bound to the earlier biometric set, so a new enrollment is
required.

Container synchronization rebases server-owned template fields onto the latest
local token under the token-state lock. It preserves native key state, rollout
state, Firebase registration, and UI placement; a response that arrives after
local deletion cannot recreate the token. Tightening the biometric enrollment
binding during container synchronization follows the same fail-closed
invalidation rule.

## Server notification

The currently supported Push protocol has no client-authenticated endpoint for
a token to revoke or disable itself. The administrative `/token/revoke` and
`/token/disable` operations must not be called from the app: embedding an admin
credential would be unsafe, and an unauthenticated variant would permit remote
denial of service.

If privacyIDEA later adds a signed token self-invalidation operation, the app
can report biometric key invalidation before removing any remaining native
material. The server must authenticate the request with the enrolled token,
make it idempotent, and define recovery when the signing key is already
unavailable.

## Validation before upstream submission

Test at least one supported Android device and one iOS device for enrollment,
approval, rejection, cancellation, app restart, token deletion, adding a new
biometric, and removing all biometrics. Also verify that devices without the
required biometric cannot activate a `strong` token. iOS changes require a
separate Xcode build and device test before an upstream pull request.
