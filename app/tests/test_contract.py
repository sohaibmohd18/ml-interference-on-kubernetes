from app.src.schemas import PredictRequest
import pytest

def test_contract_requires_four_features():
    with pytest.raises(Exception):
        PredictRequest(features=[1,2,3])  # too few

def test_contract_accepts_valid():
    PredictRequest(features=[5.1, 3.5, 1.4, 0.2])