# initial hello world Flask app

import flask
import statsd

app = flask.Flask(__name__)
statsd_client = statsd.StatsClient('localhost', 9125)

@app.route("/")
def index():
    statsd_client.incr("another_hello_world")
    return "Hello, world!\n"


if __name__ == "__main__":
    app.run()
