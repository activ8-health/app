enum DietaryRestriction {
  vegan("vegan", "Vegan"),
  vegetarian("vegetarian", "Vegetarian"),
  kosher("kosher", "Kosher"),
  halal("halal", "Halal"),
  pescetarian("pescetarian", "Pescetarian"),
  sesameFree("sesame_allergy", "Sesame Free"),
  soyFree("soy_allergy", "Soy Free"),
  glutenFree("gluten_sensitive", "Gluten Free"),
  lactoseIntolerance("lactose_intolerance", "Lactose Intolerant"),
  nutAllergy("nut_allergy", "Nut Allergy"),
  peanutAllergy("peanut_allergy", "Peanut Allergy"),
  shellfishAllergy("shellfish_allergy", "Shellfish Allergy"),
  wheatAllergy("wheat_allergy", "Wheat Allergy"),
  ;

  const DietaryRestriction(this.id, this.displayName);

  final String id;
  final String displayName;
}