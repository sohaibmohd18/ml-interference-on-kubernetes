from pydantic import BaseModel, Field, conlist
from typing import Annotated, List


class PredictRequest(BaseModel):
    # 4 numeric features required by Iris dataset
    features: Annotated[List[float], Field(min_length=4, max_length=4, example=[5.1, 3.5, 1.4, 0.2])]

class PredictResponse(BaseModel):
    species: str