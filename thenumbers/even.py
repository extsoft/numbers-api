import sys

__evens = iter(range(0, sys.maxsize, 2))


def value() -> str:
    return str(next(__evens))
