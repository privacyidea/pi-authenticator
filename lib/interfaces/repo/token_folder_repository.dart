import '../../model/token_folder.dart';

abstract class TokenFolderRepository {
  /// Overwrite the current state with the new folders
  /// Returns true if the operation is successful, false otherwise
  Future<bool> saveReplaceList(List<TokenFolder> folders);
  Future<List<TokenFolder>> loadFolders();
}
