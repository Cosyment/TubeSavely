class Pair<K, V> {
  final K? first;
  final V? second;

  const Pair(this.first, this.second);

  @override
  String toString() => '($first, $second)';
}
