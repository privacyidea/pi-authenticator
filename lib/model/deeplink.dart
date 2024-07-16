class DeepLink {
  final Uri uri;
  final bool fromInit;
  const DeepLink(this.uri, {this.fromInit = false});

  @override
  bool operator ==(Object other) => other is DeepLink && other.uri == uri && other.fromInit == fromInit;

  @override
  int get hashCode => Object.hash(uri, fromInit);

  @override
  String toString() => 'DeepLink(uri: $uri, fromInit: $fromInit)';
}
