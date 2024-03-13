# Project Overview

- [Project Overview](#project-overview)
  - [Problem Statement](#problem-statement)
  - [System Overview](#system-overview)
    - [Data Sources](#data-sources)
      - [Personal Model Data Sources:](#personal-model-data-sources)
      - [Context Data Sources:](#context-data-sources)
    - [Food Recommendations](#food-recommendations)
    - [Exercise Recommendations](#exercise-recommendations)
    - [Sleep Recommendations](#sleep-recommendations)
  - [System Architecture \& API](#system-architecture--api)


## Problem Statement

Many students at UCI are living on their own for the first time. Many feel intimidated and struggle to keep up with taking care of themselves. In contrast, others simply neglect regular physical activity, a well-balanced diet they enjoy, and a consistent quality sleep schedule. Focusing on these things helps students effectively study for their exams and eventually build a career and family. A better quality of life has been shown to improve mental and physical well-being.

Unfortunately, prioritizing personal health as a student is easier said than done. Not everyone has the motivation to develop habits and a consistent schedule, let alone log what they do. It would be great to have a student-focused app that not only tracks these details but provides advice and encourages actionable goals.


## System Overview

We have built a recommendation system that provides users with food, exercise, and sleep recommendations. Specifically, we recommend users things to eat that we think they’d like, exercise activities based on the user’s context and weather, and sleep times that improve their sleep schedule based on existing habits and requirements. More on that later.

### Data Sources

To drive our recommendations, we use 4 data sources to build the user’s personal model and 4 to provide context for the user.

#### Personal Model Data Sources:
1. Initial survey on account registration, creating a user profile with their preferences
1. Daily step counts from Apple HealthKit
1. Daily sleep/wake time from Apple HealthKit
1. Food log with calorie count (from the user-maintained log)

#### Context Data Sources:
1. Menu and nutritional information from Anteatery food data (crawled)
1. Location from smartphone GPS, updated as often as possible
1. Weather Information from OpenMeteo API

Our application involves a server, which communicates with the iOS app via a REST API through the internet. This API sends live data from the app to the server and returns recommendations to be displayed in the mobile app. Data points, locations, and logs are sorted, aggregated, and organized by date on the server’s persistent storage disk.

### Food Recommendations

Our food recommendations suggest foods from Anteatery (655 items). We prefilter these items by context (dietary preferences and caloric needs from height/weight/gender/activity level), then match them to their preferences using a neural network trained on the user’s food log. The feature vector of each item includes the item name/description, ingredients list (bag-of-words), and nutrition fact information. The user sees up to 3 recommended items.

We use the user’s caloric needs and food log to make sure the user is eating enough, according to their height/weight/gender and their weight goal (which they specified).

<img src="https://github.com/tristanphan/cs125/assets/10486660/3a16e97b-9b44-444d-bb1d-a5fc13e38cf0" height=400px />

### Exercise Recommendations

Our exercise recommendations give weather-sensitive cardio suggestions and encouragement, which are accessible in the app and through recurring local notifications. Depending on the user’s progress (from HealthKit) towards their step goal (which they selected) and their current weather, we suggest users either an exercise or advice. Some examples of recommendations are to go outside on a sunny day, go to the gym on a rainy day, encouragement if they’re close, and congratulations if they met their goal.

<img src="https://github.com/tristanphan/cs125/assets/10486660/8917b084-3eed-428f-a35b-30ce86512845" height=400px />

### Sleep Recommendations

Our sleep recommendations suggest users a set time that they should go to sleep. This recommendation tries to find a block of time that (1) is close to NIOSH recommendation for sleep to ensure quality, (2) is close to the user’s normal sleep/wake times (from HealthKit sleep data) to suit their circadian rhythm best, and (3) doesn’t interfere with their designated busy hours. (Adaptive push notifications at bedtime were planned but not feasible due to Apple’s constraints).

These recommendations are updated daily with their sleep log, so we implicitly consider how the user reacts to our recommendation (whether they accepted it or not).

<img src="https://github.com/tristanphan/cs125/assets/10486660/02b8badb-d30b-4fc8-b696-b3f134fa5013" height=400px />

## System Architecture & API

Our app and server communicate through an API, which is defined here:

- [API Reference](API.md)

Here is the context in which the APIs are called:

<img src="https://github.com/tristanphan/cs125/assets/10486660/49805a43-2270-4abe-99b4-42eeb9018b81" height=400px />


