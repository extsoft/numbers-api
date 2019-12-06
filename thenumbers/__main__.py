from flask import Flask
from thenumbers.even import value as even_value
from thenumbers.random import value as random_value

if __name__ == "__main__":
    app = Flask("the numbers")
    app.add_url_rule("/even", "even_value", even_value)
    app.add_url_rule("/random", "random_value", random_value)
    app.run(host="0.0.0.0", debug=True)
