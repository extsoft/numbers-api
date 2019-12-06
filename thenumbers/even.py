import sys

_evens = iter(range(0, sys.maxsize, 2))


def number() -> str:
    return str(next(_evens))
