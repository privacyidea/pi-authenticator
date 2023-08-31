import '../../model/token_folder.dart';

abstract class TokenFolderRepository {
  Future<bool> saveFolders(List<TokenFolder> folders);
  Future<List<TokenFolder>> loadFolders();
}
