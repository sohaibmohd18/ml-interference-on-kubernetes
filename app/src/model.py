# Loads a tiny pre-trained model (Iris) using scikit-learn
from sklearn.datasets import load_iris
from sklearn.linear_model import LogisticRegression
import numpy as np

class IrisModel:
    def __init__(self):
        iris = load_iris()
        X, y = iris.data, iris.target
        self.target_names = iris.target_names
        self.model = LogisticRegression(max_iter=200)
        self.model.fit(X, y)

    def predict(self, features: list[float]) -> str:
        arr = np.array(features).reshape(1, -1)
        idx = self.model.predict(arr)[0]
        return str(self.target_names[idx])

model = IrisModel()