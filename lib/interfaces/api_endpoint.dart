import '../model/tokens/container_credentials.dart';

abstract class ApiEndpioint<Data, Ref> {
  ContainerCredential get credential;
  Future<Data> fetch();
  Future<void> sync(Data data);
}
