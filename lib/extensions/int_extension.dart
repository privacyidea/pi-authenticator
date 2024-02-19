extension IntExtension on int {
  Iterable<int> get digits sync* {
    var number = this;
    do {
      yield number.remainder(10);
      number ~/= 10;
    } while (number != 0);
  }
}
