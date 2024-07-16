abstract class ApiEndpioint<Data, Ref> {
  Future<Data> fetch(Ref ref);
  Future<void> save(Data data);
}
