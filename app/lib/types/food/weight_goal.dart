enum WeightGoal {
  maintain,
  lose,
  gain,
  ;

  factory WeightGoal.fromIndex(int index) {
    for (WeightGoal value in WeightGoal.values) {
      if (value.index == index) {
        return value;
      }
    }
    return WeightGoal.maintain;
  }
}
