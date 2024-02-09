import 'package:activ8/types/food/dietary_restrictions.dart';

extension DietaryRestrictionSerializer on Set<DietaryRestriction> {
  Map<String, dynamic> toJson() {
    Map<String, bool> values = {};
    for (DietaryRestriction restriction in DietaryRestriction.values) {
      values[restriction.id] = contains(restriction);
    }
    return values;
  }

  static Set<DietaryRestriction> fromJson(Map<String, dynamic> json) {
    Set<DietaryRestriction> restrictions = {};
    for (DietaryRestriction restriction in DietaryRestriction.values) {
      if (json[restriction.id] == true) {
        restrictions.add(restriction);
      }
    }
    return restrictions;
  }
}
