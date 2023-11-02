extension ListFilter<T> on Stream<List<T>>{
  Stream<List<T>> filter(bool Function(T) where) => 
    map((items) => items.where(where).toList());
}

extension IterableFilter<T> on Stream<Iterable<T>>{
  Stream<Iterable<T>> filter(bool Function(T) where) => 
    map((items) => items.where(where).toList());
}