import uuid
from datetime import datetime
from dataclasses import dataclass


@dataclass
class FoodLog:
    entry_id: uuid.UUID
    food_name: str
    date: datetime
    portion_eaten: float
    total_calories: float
    rating: int

    def __post_init__(self):
        try:
            self.entry_id = uuid.UUID(str(self.entry_id), version=4)
        except ValueError:
            raise ValueError("Invalid UUID")

        try:
            self.date = datetime.fromisoformat(self.date).isoformat()

        except TypeError:
            raise ValueError("Invalid date")

        self.portion_eaten = float(self.portion_eaten)
        if self.portion_eaten < 0:
            raise ValueError("Invalid portion eaten")
        else:
            self.total_calories = self.portion_eaten * self.total_calories

        rating = int(self.rating)
        if rating != self.rating and (rating < 1 or rating > 5):
            raise ValueError("Invalid rating")

    def to_dict(self):
        return {
            datetime.fromisoformat(self.date).strftime('%Y-%m-%d'): {
                str(self.entry_id): {
                    "food_name": self.food_name,
                    "portion_eaten": self.portion_eaten,
                    "date": self.date,
                    "total_calories": self.total_calories,
                    "rating": self.rating
                }
            }
        }
