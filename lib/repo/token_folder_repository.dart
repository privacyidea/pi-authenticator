import '../model/token_folder.dart';

abstract class TokenFolderRepositoy {
  Future<bool> saveFolders(List<TokenFolder> folders);
  Future<List<TokenFolder>> loadFolders();
}
