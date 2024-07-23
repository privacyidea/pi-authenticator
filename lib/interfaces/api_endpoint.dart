abstract class ApiEndpioint<Data, Ref> {
  Ref get credentials;

  Future<Data> fetch();
  Future<void> sync(Data data);
}
