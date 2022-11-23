"""
Principal Module.

Update metadata from version by semver
"""
from tomli import load
from pathlib import Path

configfile = Path(__file__).parents[3].joinpath("pyproject.toml")
versionfile = Path(__file__).parent.joinpath("version.txt")

with configfile.open('rb') as f:
    versionfile.write_text(
        f"{load(f)['tool']['poetry']['version']}\n"
    )

__version__ = versionfile.read_text().strip()

if __name__ == '__main__':
    print(__version__)
