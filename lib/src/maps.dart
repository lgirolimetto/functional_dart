import 'package:basic_functional_dart/basic_functional_dart.dart';

extension FMap<K, V> on Map<K, V> {
  Option<V> getOptional(K key) => this[key] == null ? None<V>() : Some(this[key]!);
}