import fcntl, os, pickle
import pandas as pd

def load_model(model_filename):
    with open(model_filename, 'rb') as f:
        fcntl.flock(f, fcntl.LOCK_SH)
        try:
            return pickle.load(f)
        finally:
            fcntl.flock(f, fcntl.LOCK_UN)

def save_model(model_filename, model):
    with open(model_filename, 'wb') as f:
        fcntl.flock(f, fcntl.LOCK_EX)
        try:
            pickle.dump(model, f)
        finally:
            fcntl.flock(f, fcntl.LOCK_UN)

def init_model():
    from sklearn.pipeline import Pipeline
    from sklearn.linear_model import SGDRegressor
    from sklearn.preprocessing import PolynomialFeatures, StandardScaler

    estimators = [
        ('scaler', StandardScaler()),
        ('poly', PolynomialFeatures(5)),
        ('regressor', SGDRegressor(loss='huber', penalty='elasticnet', warm_start=True)),
    ]
    model = Pipeline(estimators)
    return model

def load_or_init_model(model_filename):
    if os.path.isfile(model_filename):
        return load_model(model_filename)
    else:
        return init_model()

def partial_fit(model, X, y):
    n_1 = len(model.steps) - 1
    for i, step in enumerate(model.steps):
        name, est = step
        if hasattr(est, 'partial_fit'):
            est.partial_fit(X, y)
        else:
            est.fit(X, y)
        if i < n_1:
            X = est.transform(X)
    return model

def update_model(model_filename, data):
    model = load_or_init_model(model_filename)

    if not isinstance(data, pd.DataFrame):
        data = data.to_pandas()
    X = data['x'].to_numpy().reshape(-1, 1)
    y = data['y'].to_numpy()

    model = partial_fit(model, X, y)
    save_model(model_filename, model)
