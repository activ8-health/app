import "package:flutter/material.dart";

/// The server address use by default
const String defaultServerAddress = "127.0.0.1:8080";
const bool allowChangingServerAddress = true;

/// Border radius of large icons
final BorderRadius largeIconBorderRadius = BorderRadius.circular(28);

/// Border radius of home cards
final BorderRadius homeCardBorderRadius = BorderRadius.circular(28);

/// Retrieve health points from the last 90 days
const int healthHistoryLength = 90;

/// The number of food log entries to show in the preview
const int foodLogPreviewCount = 3;

/// The number of stars to default to when asking users for a rating
const int defaultRatingStars = 3;

/// How much over the calorie goal is should the gauge turn red
const int caloriesOverWarningThreshold = 400;
