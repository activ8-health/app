# Activ8 - Backend

The backend for Activ8 is an HTTP API written in Python with the Flask microframework.

## Setting Up

### Install Requirements

These commands will set up a Python virtual environment:

```bash
# Create a virtual environment at `venv/`
python3 -m venv venv

# Activate venv: WINDOWS
venv\Scripts\activate

# Activate venv: LINUX/UNIX/MACOS
source venv/bin/activate

# Install Dependencies
pip3 install -r requirements.txt
```

### Set Runtime Mode

Find and set the `mode` variable in `app.py`:
```python
mode = "dev"
# OR
mode = "prod"
```

Running the server in developer mode will enable debug mode and hot reloading, but is limited to single-threading.

### Run Server

```bash
# Run the server
python3 app.py <port>
```

Kill the server at any time using `Ctrl+C`.

## Maintenance

### File Storage

The current state of the system is stored in `data/user_profile.json`, which stores all datapoints, food log entries, and details about every user, and `data/login_data.json`, which stores the login credentials of every user. Both files are read on startup and are kept up to date.

There are many improvement points that can be done here. The size of `data/user_profile.json` is expected to grow very quickly with the number of users, and this can be mitigated by separating data by users and type, or even shifting to a more scalable system like MongoDB.

The credentials in `data/login_data.json` should be encrypted and hashed for security. This is a major security flaw that will need to be addressed.

### Menu Data

The menu data is stored in `data/menu_data.json`. A feature matrix version of the menu data is stored in `data/menu_data2.csv`. Both files are read by the server on startup.

The feature vector is a scaled and imputated combination of each food item's nutritional information and ingredients. It is used to train and predict with the neural network.

### Neural Network

The neural network is trained and used in `apis/food.py` on the invocation of scikit-learn's `MLPClassifier`. The arguments to this object are hyperparameters that may be changed to improve the model's effectiveness. This may need more testing and tuning, which requires a larger dataset of food log entries and their ratings.
