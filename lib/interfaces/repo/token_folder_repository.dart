import '../../model/token_folder.dart';

abstract class TokenFolderRepository {
  Future<List<TokenFolder>> saveOrReplaceFolders(List<TokenFolder> folders);
  Future<List<TokenFolder>> loadFolders();
  Future<List<TokenFolder>> deleteFolders(List<TokenFolder> folders);
}
