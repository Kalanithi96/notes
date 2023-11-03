extension IterableFilter<T> on Stream<Iterable<T>>{
  Stream<Iterable<T>> filter(bool Function(T) where) => 
    map((items) => items.where(where).toList());
}