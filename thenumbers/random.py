import random
import sys


def number() -> str:
    return str(random.randint(0, sys.maxsize))  # noqa: S311
