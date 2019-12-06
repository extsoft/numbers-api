from flask import Flask

from thenumbers.even import number as even_number
from thenumbers.random import number as random_number

if __name__ == "__main__":
    app = Flask("the numbers")
    app.add_url_rule("/even", "even_number", even_number)
    app.add_url_rule("/random", "random_number", random_number)
    app.run(host="0.0.0.0", debug=False)  # noqa: S104
