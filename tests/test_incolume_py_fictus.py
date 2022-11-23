import re
from incolume.py.fictus import __version__


def test_version():
    assert re.fullmatch(r'\d+(\.\d+){2}(-?\w+\.?\d+)?', __version__, re.I)
