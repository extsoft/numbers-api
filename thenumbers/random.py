import random
import sys


def value() -> str:
    return str(random.randint(0, sys.maxsize))
