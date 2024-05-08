extension IntToListOfInt on int {
  List<int> toList() => [for (var i = 1; i <= this; i++) i];

  Iterable<({int nTry, T Function() action})> getActionIndexed<T>(T Function() action) {
    return toList()
        .map((i) => (nTry: i, action: action));
  }
}