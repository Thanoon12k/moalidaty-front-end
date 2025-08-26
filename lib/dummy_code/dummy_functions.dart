// ignore_for_file: non_constant_identifier_names


class DummyFunctions {
  ///  function to subtract two arrays from each other  example
  /// ```dart

  /// all=[1,2,3,4,5];
  /// part=[3,5];
  /// subb=SubtractArrays(all,part);
  /// print(subb); //--> [1,2,4]
  /// ```
  static List<dynamic> SubtractArrays(List<dynamic> all, List<dynamic> part) =>
      all.where((e) => !(part.contains(e))).toList();
}
