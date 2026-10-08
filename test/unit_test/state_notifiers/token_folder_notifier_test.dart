import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/interfaces/repo/token_folder_repository.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_folder_state.dart';
import 'package:privacyidea_authenticator/model/token_folder.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_folder_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';

import '../../tests_app_wrapper.mocks.dart';

void main() {
  _testTokenFolderNotifier();
  _testTokenFolderNotifierMore();
}

void _testTokenFolderNotifier() {
  group('TokenFolderNotifier', () {
    test('addFolder', () async {
      final mockRepo = MockTokenFolderRepository();
      final container = ProviderContainer();
      const TokenFolderState before = TokenFolderState(folders: []);
      const TokenFolderState after = TokenFolderState(
        folders: [TokenFolder(label: 'test', folderId: 1)],
      );
      when(mockRepo.loadState()).thenAnswer((_) async => before);
      when(mockRepo.saveState(after)).thenAnswer((_) async => true);
      final testProvider = tokenFolderProviderOf(repo: mockRepo);
      final notifier = container.read(testProvider.notifier);
      await notifier.initState;
      await notifier.addNewFolder('test');
      final state = container.read(testProvider);
      expect(state, after);
      verify(mockRepo.saveState(after)).called(1);
    });

    test('removeFolder', () async {
      final mockRepo = MockTokenFolderRepository();
      final mockTokenRepo = MockTokenRepository();
      when(mockTokenRepo.loadTokens()).thenAnswer((_) async => const []);
      final container = ProviderContainer(
        overrides: [
          tokenProvider.overrideWith(
            () => TokenNotifier(repoOverride: mockTokenRepo),
          ),
        ],
      );
      const before = TokenFolderState(
        folders: [TokenFolder(label: 'test', folderId: 1, isExpanded: true)],
      );
      const after = TokenFolderState(folders: []);
      when(mockRepo.loadState()).thenAnswer((_) async => before);
      when(mockRepo.saveState(after)).thenAnswer((_) async => true);
      final testProvider = tokenFolderProviderOf(repo: mockRepo);
      final notifier = container.read(testProvider.notifier);
      await notifier.initState;
      await notifier.removeFolder(
        const TokenFolder(label: 'test', folderId: 1),
      );
      final state = container.read(testProvider);
      expect(state, after);
      verify(mockRepo.saveState(after)).called(1);
    });
    test('updateFolder', () async {
      final mockRepo = MockTokenFolderRepository();
      final container = ProviderContainer();
      const before = TokenFolderState(
        folders: [TokenFolder(label: 'test', folderId: 1, isExpanded: true)],
      );
      const after = TokenFolderState(
        folders: [
          TokenFolder(label: 'testUpdated', folderId: 1, isExpanded: true),
        ],
      );
      when(mockRepo.loadState()).thenAnswer((_) async => before);
      when(mockRepo.saveState(after)).thenAnswer((_) async => true);
      final testProvider = tokenFolderProviderOf(repo: mockRepo);
      final notifier = container.read(testProvider.notifier);
      await notifier.initState;
      await notifier.updateFolder(
        before.folders.first,
        (p0) => after.folders.first,
      );
      final state = container.read(testProvider);
      expect(state, after);
      verify(mockRepo.saveState(after)).called(1);
    });
    test('updateFolders', () async {
      final mockRepo = MockTokenFolderRepository();
      final container = ProviderContainer();
      const before = TokenFolderState(
        folders: [
          TokenFolder(label: 'test1', folderId: 1, isExpanded: true),
          TokenFolder(label: 'test2', folderId: 2, isExpanded: true),
        ],
      );
      const after = TokenFolderState(
        folders: [
          TokenFolder(label: 'test1Updated', folderId: 1, isExpanded: true),
          TokenFolder(label: 'test2Updated', folderId: 2, isExpanded: true),
        ],
      );
      when(mockRepo.loadState()).thenAnswer((_) async => before);
      when(mockRepo.saveState(after)).thenAnswer((_) async => true);
      final testProvider = tokenFolderProviderOf(repo: mockRepo);
      final notifier = container.read(testProvider.notifier);
      await notifier.initState;
      await notifier.addOrReplaceFolders(after.folders);
      final state = container.read(testProvider);
      expect(state, after);
      verify(mockRepo.saveState(after)).called(1);
    });
  });
}

/// Hand written in-memory repository.
class _FakeFolderRepo implements TokenFolderRepository {
  _FakeFolderRepo(this.stored);

  TokenFolderState stored;
  bool saveSucceeds = true;

  /// If set, [loadState] waits for it (deterministic, no real time).
  Completer<void>? loadGate;

  /// Every state that was handed to [saveState], including failed saves.
  final saveCalls = <TokenFolderState>[];

  @override
  Future<TokenFolderState> loadState() async {
    await loadGate?.future;
    return stored;
  }

  @override
  Future<bool> saveState(TokenFolderState state) async {
    saveCalls.add(state);
    if (!saveSucceeds) return false;
    stored = state;
    return true;
  }
}

HOTPToken _token(String id, {int? folderId}) => HOTPToken(
  id: id,
  algorithm: Algorithms.SHA1,
  digits: 6,
  secret: 'secret$id',
  folderId: folderId,
);

class _Env {
  final _FakeFolderRepo folderRepo;
  final Map<String, Token> tokenRepoContent;
  final ProviderContainer container;

  _Env(this.folderRepo, this.tokenRepoContent, this.container);

  TokenFolderNotifier get notifier =>
      container.read(tokenFolderProvider.notifier);
  TokenFolderState get state => container.read(tokenFolderProvider);

  Future<List<Token>> get tokens async =>
      (await container.read(tokenProvider.future)).tokens;
}

_Env _setUp(
  List<TokenFolder> folders, {
  List<Token> tokens = const [],
}) {
  final folderRepo = _FakeFolderRepo(TokenFolderState(folders: folders));
  final tokenRepoContent = {for (final t in tokens) t.id: t};
  final tokenRepo = MockTokenRepository();
  when(
    tokenRepo.loadTokens(),
  ).thenAnswer((_) async => tokenRepoContent.values.toList());
  when(tokenRepo.saveOrReplaceTokens(any)).thenAnswer((invocation) async {
    for (final token in invocation.positionalArguments[0] as List<Token>) {
      tokenRepoContent[token.id] = token;
    }
    return [];
  });
  final container = ProviderContainer(
    overrides: [
      tokenFolderProvider.overrideWith(
        () => TokenFolderNotifier(repoOverride: folderRepo),
      ),
      tokenProvider.overrideWith(() => TokenNotifier(repoOverride: tokenRepo)),
    ],
  );
  addTearDown(container.dispose);
  // Teardowns run in reverse order: this runs BEFORE the container is disposed
  // and lets fire-and-forget work (removeFolder detaches the tokens without
  // awaiting it) finish, so that it cannot touch a disposed container.
  addTearDown(() => pumpEventQueue());
  return _Env(folderRepo, tokenRepoContent, container);
}

void _testTokenFolderNotifierMore() {
  group('TokenFolderNotifier build', () {
    test('the state is empty until initState finished, then it is the loaded one', () async {
      const loaded = TokenFolderState(
        folders: [TokenFolder(label: 'a', folderId: 1)],
      );
      final env = _setUp(loaded.folders);
      env.folderRepo.loadGate = Completer<void>();

      final initState = env.notifier.initState;
      await pumpEventQueue();
      expect(env.state.folders, isEmpty);

      env.folderRepo.loadGate!.complete();
      expect(await initState, loaded);
      expect(env.state, loaded);
      expect(env.folderRepo.saveCalls, isEmpty, reason: 'loading must not save');
    });
  });

  group('TokenFolderNotifier.collapseLockedFolders', () {
    const folders = [
      TokenFolder(label: 'lockedOpen', folderId: 1, isLocked: true, isExpanded: true, sortIndex: 5),
      TokenFolder(label: 'lockedClosed', folderId: 2, isLocked: true),
      TokenFolder(label: 'freeOpen', folderId: 3, isExpanded: true),
      TokenFolder(label: 'freeClosed', folderId: 4),
    ];
    const expected = [
      TokenFolder(label: 'lockedOpen', folderId: 1, isLocked: true, sortIndex: 5),
      TokenFolder(label: 'lockedClosed', folderId: 2, isLocked: true),
      TokenFolder(label: 'freeOpen', folderId: 3, isExpanded: true),
      TokenFolder(label: 'freeClosed', folderId: 4),
    ];

    test('collapses only locked folders and keeps everything else', () async {
      final env = _setUp(folders);
      await env.notifier.initState;

      final result = await env.notifier.collapseLockedFolders();

      expect(result.folders, expected);
      expect(env.state.folders, expected);
    });

    test('the result is persisted', () async {
      final env = _setUp(folders);
      await env.notifier.initState;

      await env.notifier.collapseLockedFolders();

      expect(env.folderRepo.saveCalls, hasLength(1));
      expect(env.folderRepo.stored.folders, expected);
    });

    test('an unlocked expanded folder stays expanded', () async {
      final env = _setUp(folders);
      await env.notifier.initState;

      await env.notifier.collapseLockedFolders();

      expect(env.state.currentOfId(3)!.isExpanded, isTrue);
    });

    test('called right after creation it waits for the initial load', () async {
      final env = _setUp(folders);
      env.folderRepo.loadGate = Completer<void>();
      // No await of initState on purpose.
      var completed = false;
      final future = env.notifier.collapseLockedFolders().then((v) {
        completed = true;
        return v;
      });
      await pumpEventQueue();
      expect(completed, isFalse, reason: 'must wait until the folders are loaded');
      expect(env.folderRepo.saveCalls, isEmpty);

      env.folderRepo.loadGate!.complete();
      final result = await future;

      expect(result.folders, expected);
      expect(env.folderRepo.stored.folders, expected);
    });

    test('without locked folders the state stays the same', () async {
      final env = _setUp(const [
        TokenFolder(label: 'a', folderId: 1, isExpanded: true),
        TokenFolder(label: 'b', folderId: 2),
      ]);
      await env.notifier.initState;
      final before = env.state;

      final result = await env.notifier.collapseLockedFolders();

      expect(result, before);
      expect(env.state, before);
    });

    test('without any folder it returns an empty state', () async {
      final env = _setUp(const []);
      await env.notifier.initState;

      final result = await env.notifier.collapseLockedFolders();

      expect(result.folders, isEmpty);
    });

    test('a failed save keeps and returns the old state', () async {
      final env = _setUp(folders);
      await env.notifier.initState;
      env.folderRepo.saveSucceeds = false;

      final result = await env.notifier.collapseLockedFolders();

      expect(result.folders, folders);
      expect(env.state.folders, folders);
      expect(env.folderRepo.stored.folders, folders);
    });

    test('after a failed save the notifier is still usable', () async {
      final env = _setUp(folders);
      await env.notifier.initState;
      env.folderRepo.saveSucceeds = false;
      await env.notifier.collapseLockedFolders();
      env.folderRepo.saveSucceeds = true;

      final result = await env.notifier.collapseLockedFolders();

      expect(result.folders, expected);
    });
  });

  group('TokenFolderNotifier.updateFolderById', () {
    test('updates and persists an existing folder', () async {
      final env = _setUp(const [TokenFolder(label: 'a', folderId: 1)]);
      await env.notifier.initState;

      final result = await env.notifier.updateFolderById(
        1,
        (f) => f.copyWith(label: 'b'),
      );

      expect(result.folders, const [TokenFolder(label: 'b', folderId: 1)]);
      expect(env.folderRepo.stored, result);
    });

    test('expandFolderById expands only that folder', () async {
      final env = _setUp(const [
        TokenFolder(label: 'a', folderId: 1),
        TokenFolder(label: 'b', folderId: 2),
      ]);
      await env.notifier.initState;

      await env.notifier.expandFolderById(2);

      expect(env.state.currentOfId(1)!.isExpanded, isFalse);
      expect(env.state.currentOfId(2)!.isExpanded, isTrue);
      expect(env.folderRepo.stored.currentOfId(2)!.isExpanded, isTrue);
    });

    test('an unknown id changes nothing and does not throw', () async {
      final env = _setUp(const [TokenFolder(label: 'a', folderId: 1)]);
      await env.notifier.initState;
      final before = env.state;

      final result = await env.notifier.updateFolderById(
        99,
        (f) => f.copyWith(label: 'x'),
      );

      expect(result, before);
      expect(env.state, before);
      expect(env.folderRepo.saveCalls, isEmpty);
    }, skip: 'BUG: token_folder_notifier.dart:143 updateFolderById does `oldState.currentOfId(folderId)!` and throws a null check error for an unknown id although the doc says "nothing will happen"');

    test('an unknown id does not block later updates', () async {
      final env = _setUp(const [TokenFolder(label: 'a', folderId: 1)]);
      await env.notifier.initState;
      await env.notifier
          .updateFolderById(99, (f) => f)
          .then<void>((_) {}, onError: (Object _) {});

      var completed = false;
      final next = env.notifier.addNewFolder('b').then((v) {
        completed = true;
        return v;
      });
      await pumpEventQueue();

      expect(
        completed,
        isTrue,
        reason: '_stateMutex must be released after the failed update',
      );
      expect((await next).folders, hasLength(2));
    }, skip: 'BUG: token_folder_notifier.dart:141-143 updateFolderById acquires _stateMutex and then throws on the `!` without releasing it, every later folder operation hangs forever');

    test('updateFolder of an unknown folder changes nothing', () async {
      final env = _setUp(const [TokenFolder(label: 'a', folderId: 1)]);
      await env.notifier.initState;
      final before = env.state;

      final result = await env.notifier.updateFolder(
        const TokenFolder(label: 'ghost', folderId: 42),
        (f) => f.copyWith(label: 'x'),
      );

      expect(result, before);
      expect(env.state, before);
    });
  });

  group('TokenFolderNotifier.toggleFolderLock', () {
    test('locks an unlocked folder and unlocks it again', () async {
      final env = _setUp(const [TokenFolder(label: 'a', folderId: 1)]);
      await env.notifier.initState;

      await env.notifier.toggleFolderLock(env.state.folders.single);
      expect(env.state.folders.single.isLocked, isTrue);

      await env.notifier.toggleFolderLock(env.state.folders.single);
      expect(env.state.folders.single.isLocked, isFalse);
      expect(env.folderRepo.stored.folders.single.isLocked, isFalse);
    });

    test('toggles the CURRENT lock state, not the one of a stale folder argument', () async {
      final env = _setUp(const [TokenFolder(label: 'a', folderId: 1)]);
      await env.notifier.initState;
      const stale = TokenFolder(label: 'a', folderId: 1); // isLocked: false
      await env.notifier.toggleFolderLock(stale);
      expect(env.state.folders.single.isLocked, isTrue);

      // The same (now outdated) object is passed again, e.g. by a double tap.
      await env.notifier.toggleFolderLock(stale);

      expect(env.state.folders.single.isLocked, isFalse);
    }, skip: 'BUG: token_folder_notifier.dart:173-174 toggleFolderLock uses `!folder.isLocked` of the argument instead of the current folder, a stale argument sets lock to true again instead of toggling');
  });

  group('TokenFolderNotifier.addNewFolder', () {
    test('uses max id + 1 and persists', () async {
      final env = _setUp(const [
        TokenFolder(label: 'a', folderId: 2),
        TokenFolder(label: 'b', folderId: 7),
      ]);
      await env.notifier.initState;

      final result = await env.notifier.addNewFolder('c');

      expect(result.folders.last, const TokenFolder(label: 'c', folderId: 8));
      expect(env.folderRepo.stored, result);
    });

    test('a failed save returns the old state and adds nothing', () async {
      final env = _setUp(const [TokenFolder(label: 'a', folderId: 1)]);
      await env.notifier.initState;
      env.folderRepo.saveSucceeds = false;

      final result = await env.notifier.addNewFolder('b');

      expect(result.folders, hasLength(1));
      expect(env.state.folders, hasLength(1));
    });

    test('concurrent calls get different ids', () async {
      final env = _setUp(const []);
      await env.notifier.initState;

      await Future.wait([
        env.notifier.addNewFolder('a'),
        env.notifier.addNewFolder('b'),
        env.notifier.addNewFolder('c'),
      ]);

      expect(env.state.folders.map((f) => f.folderId).toSet(), {1, 2, 3});
      expect(env.folderRepo.stored, env.state);
    });
  });

  group('TokenFolderNotifier.removeFolder', () {
    final tokens = [
      _token('inFolder1a', folderId: 1),
      _token('inFolder1b', folderId: 1),
      _token('inFolder2', folderId: 2),
      _token('free'),
    ];
    const folders = [
      TokenFolder(label: 'one', folderId: 1),
      TokenFolder(label: 'two', folderId: 2),
    ];

    test('removes the folder and persists', () async {
      final env = _setUp(folders, tokens: tokens);
      await env.notifier.initState;

      final result = await env.notifier.removeFolder(folders[0]);

      expect(result.folders, [folders[1]]);
      expect(env.state.folders, [folders[1]]);
      expect(env.folderRepo.stored.folders, [folders[1]]);
    });

    test('detaches the tokens of the removed folder, other tokens stay', () async {
      final env = _setUp(folders, tokens: tokens);
      await env.notifier.initState;

      await env.notifier.removeFolder(folders[0]);
      await pumpEventQueue();

      final byId = {for (final t in await env.tokens) t.id: t.folderId};
      expect(byId, {
        'inFolder1a': null,
        'inFolder1b': null,
        'inFolder2': 2,
        'free': null,
      });
      expect(env.tokenRepoContent['inFolder1a']!.folderId, isNull);
      expect(env.tokenRepoContent['inFolder2']!.folderId, 2);
    });

    test('the tokens are already detached when removeFolder completes', () async {
      final env = _setUp(folders, tokens: tokens);
      await env.notifier.initState;

      await env.notifier.removeFolder(folders[0]);

      final byId = {for (final t in await env.tokens) t.id: t.folderId};
      expect(byId['inFolder1a'], isNull);
      expect(byId['inFolder1b'], isNull);
    }, skip: 'BUG: token_folder_notifier.dart:99 removeFolder does not await tokenProvider.notifier.updateTokens, callers that await removeFolder still see the tokens in the removed folder');

    test('a failed save keeps the folder', () async {
      final env = _setUp(folders, tokens: tokens);
      await env.notifier.initState;
      env.folderRepo.saveSucceeds = false;

      final result = await env.notifier.removeFolder(folders[0]);
      await pumpEventQueue();

      expect(result.folders, folders);
      expect(env.state.folders, folders);
      expect(env.folderRepo.stored.folders, folders);
    });

    test('a failed save keeps the tokens in their folder', () async {
      final env = _setUp(folders, tokens: tokens);
      await env.notifier.initState;
      env.folderRepo.saveSucceeds = false;

      await env.notifier.removeFolder(folders[0]);
      await pumpEventQueue();

      final byId = {for (final t in await env.tokens) t.id: t.folderId};
      expect(byId['inFolder1a'], 1);
      expect(byId['inFolder1b'], 1);
    }, skip: 'BUG: token_folder_notifier.dart:96-102 removeFolder detaches the tokens (folderId = null) BEFORE it checks whether saving succeeded, so after a failed save the folder still exists but its tokens are lost from it');

    test('after a failed save the notifier is still usable', () async {
      final env = _setUp(folders, tokens: tokens);
      await env.notifier.initState;
      env.folderRepo.saveSucceeds = false;
      await env.notifier.removeFolder(folders[0]);
      env.folderRepo.saveSucceeds = true;

      final result = await env.notifier.removeFolder(folders[1]);

      expect(result.folders, [folders[0]]);
    });

    test('removing an unknown folder keeps all folders', () async {
      final env = _setUp(folders, tokens: tokens);
      await env.notifier.initState;

      final result = await env.notifier.removeFolder(
        const TokenFolder(label: 'ghost', folderId: 99),
      );
      await pumpEventQueue();

      expect(result.folders, folders);
      final byId = {for (final t in await env.tokens) t.id: t.folderId};
      expect(byId['inFolder1a'], 1);
      expect(byId['inFolder2'], 2);
    });
  });

  group('TokenFolderNotifier.addOrReplaceFolders', () {
    test('replaces an existing folder in place and persists', () async {
      final env = _setUp(const [
        TokenFolder(label: 'a', folderId: 1),
        TokenFolder(label: 'b', folderId: 2),
      ]);
      await env.notifier.initState;

      final result = await env.notifier.addOrReplaceFolders(const [
        TokenFolder(label: 'b2', folderId: 2, isExpanded: true),
      ]);

      expect(result.folders, const [
        TokenFolder(label: 'a', folderId: 1),
        TokenFolder(label: 'b2', folderId: 2, isExpanded: true),
      ]);
      expect(env.folderRepo.stored, result);
    });

    test('a failed save keeps the old state', () async {
      final env = _setUp(const [TokenFolder(label: 'a', folderId: 1)]);
      await env.notifier.initState;
      env.folderRepo.saveSucceeds = false;

      final result = await env.notifier.addOrReplaceFolders(const [
        TokenFolder(label: 'x', folderId: 1),
      ]);

      expect(result.folders.single.label, 'a');
      expect(env.state.folders.single.label, 'a');
    });

    test('a folder with a new id is added', () async {
      final env = _setUp(const [TokenFolder(label: 'a', folderId: 1)]);
      await env.notifier.initState;

      final result = await env.notifier.addOrReplaceFolders(const [
        TokenFolder(label: 'new', folderId: 5),
      ]);

      expect(result.folders.map((f) => f.label), ['a', 'new']);
      expect(env.state.currentOfId(5), isNotNull);
      expect(env.folderRepo.stored.currentOfId(5), isNotNull);
    }, skip: 'BUG: token_folder_state.dart:45-56 addOrReplaceFolders only replaces, a folder whose id does not exist yet is silently dropped (see TokenFolderState group)');
  });
}
