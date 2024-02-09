enum Sex {
  male,
  female,
  indeterminate,
  ;

  factory Sex.fromIndex(int index) {
    for (Sex value in Sex.values) {
      if (value.index == index) {
        return value;
      }
    }
    return Sex.indeterminate;
  }
}
