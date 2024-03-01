import uuid
from datetime import datetime
from dataclasses import dataclass


@dataclass
class FoodLog:
    entry_id: uuid.UUID
    food_name: str
    date: datetime
    portion_eaten: float
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

        rating = int(self.rating)
        if rating != self.rating and (rating < 1 or rating > 5):
            raise ValueError("Invalid rating")

    def to_dict(self):
        return {
            str(self.entry_id): {
                "food_name": self.food_name,
                "date": self.date,
                "portion_eaten": self.portion_eaten,
                "rating": self.rating
            }
        }
