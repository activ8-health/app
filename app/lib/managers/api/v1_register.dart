import 'package:activ8/extensions/time_of_day.dart';
import 'package:activ8/managers/api/api_auth.dart';
import 'package:activ8/managers/api/api_worker.dart';
import 'package:activ8/types/food/dietary_restrictions.dart';
import 'package:activ8/types/health_data.dart';
import 'package:activ8/types/user_preferences.dart';
import 'package:activ8/types/user_profile.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' show Response;

String _endpoint = "/v1/register";

Future<V1RegisterResponse> v1register(V1RegisterBody body, Auth auth) async {
  Response response = await ApiWorker.instance.post(_endpoint, body.toJson(), auth);
  V1RegisterStatus status =
      V1RegisterStatus.values.where((e) => e.statusCode == response.statusCode).firstOrNull ?? V1RegisterStatus.unknown;

  return V1RegisterResponse(status: status, errorMessage: response.body);
}

class V1RegisterBody {
  final UserProfile userProfile;
  final HealthData healthData;
  final UserPreferences userPreferences;
  final Position? location;

  V1RegisterBody({
    required this.userProfile,
    required this.healthData,
    required this.userPreferences,
    this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      "user_profile": userProfile.toJson(),
      "health_data": healthData.toJson(),
      "sleep_preferences": {
        "core_hours": userPreferences.coreHours.toJson(),
      },
      "food_preferences": {
        "weight_goal": userPreferences.weightGoal.index,
        "dietary": {
          "vegan": userPreferences.dietaryRestrictions.contains(DietaryRestriction.vegan),
          "vegetarian": userPreferences.dietaryRestrictions.contains(DietaryRestriction.vegetarian),
          "kosher": userPreferences.dietaryRestrictions.contains(DietaryRestriction.kosher),
          "halal": userPreferences.dietaryRestrictions.contains(DietaryRestriction.halal),
          "pescetarian": userPreferences.dietaryRestrictions.contains(DietaryRestriction.pescetarian),
          "sesame_free": userPreferences.dietaryRestrictions.contains(DietaryRestriction.sesameFree),
          "soy_free": userPreferences.dietaryRestrictions.contains(DietaryRestriction.soyFree),
          "gluten_free": userPreferences.dietaryRestrictions.contains(DietaryRestriction.glutenFree),
          "lactose_intolerance": userPreferences.dietaryRestrictions.contains(DietaryRestriction.lactoseIntolerance),
          "nut_allergy": userPreferences.dietaryRestrictions.contains(DietaryRestriction.nutAllergy),
          "peanut_allergy": userPreferences.dietaryRestrictions.contains(DietaryRestriction.peanutAllergy),
          "shellfish_allergy": userPreferences.dietaryRestrictions.contains(DietaryRestriction.shellfishAllergy),
          "wheat_allergy": userPreferences.dietaryRestrictions.contains(DietaryRestriction.wheatAllergy),
        },
      },
      "exercise_preferences": {
        "reminder_time": userPreferences.exerciseReminderTime.minutesSinceMidnight,
        "step_goal": userPreferences.stepGoal,
      },
      "location": (location == null) ? null : [location!.latitude, location!.longitude],
    };
  }
}

class V1RegisterResponse {
  final V1RegisterStatus status;
  final String? errorMessage;

  V1RegisterResponse({required this.status, this.errorMessage});
}

enum V1RegisterStatus {
  success(statusCode: 200),
  emailInUse(statusCode: 409),
  badRequest(statusCode: 400),
  unknown,
  ;

  const V1RegisterStatus({this.statusCode});

  final int? statusCode;
}
