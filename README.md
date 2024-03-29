# Stubber for activ8

This allows you to simulate the backend by intercepting certain API calls and returning a predefined response.

## How To Use

1. Clone this branch to a separate directory from the main project
2. Write the predefined response in `outputs/<targetApi>.json`
3. Find and edit the corresponding line in `stubber.py` to indicate that the API should NOT be redirected:

```python
# "api" : ("method", should_redirect)
apis = {
    ...
# CHANGE FROM True TO False
"<targetApi>": ("<method>", False),
...
}
```

4. To allow untargeted APIs to continue to function as expected, run the normal server on port 8085 (by specifying it as a parameter)
5. Set up the virtual environment for the stubber (this branch)
6. Run the stubber on port 8080 from a different directory