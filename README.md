# Numbers API
The project provides 2 HTTP endpoints
- `/even` that returns an even number sequentially from 0
- `/random` that returns a random positive number

[actions]: https://github.com/extsoft/numbers-api/actions?query=workflow%3A%22Quality+pipeline%22
[black]: https://github.com/psf/black
[wemake]: https://github.com/wemake-services/wemake-python-styleguide
[![Quality pipeline](https://github.com/extsoft/numbers-api/workflows/Quality%20pipeline/badge.svg)][actions]
[![black](https://img.shields.io/badge/code%20style-black-000000.svg)][black]
[![wemake](https://img.shields.io/badge/style-wemake-000000.svg)][wemake]

## Quick start
Run
```bash
docker run -i --rm --publish 5000:5000 docker.pkg.github.com/extsoft/numbers-api/app:latest
```
and open either <http://localhost:5000/even> or <http://localhost:5000/random> in a browser.

If you need some specific version of the Docker image, please go to <https://github.com/extsoft/numbers-api/packages>.

## Used tools
**Production tools**
- Python 3.8
- [Flask](https://flask.palletsprojects.com/en/1.1.x/)

**Development tools**
- [black](https://black.readthedocs.io/en/stable/)
- [wemake-python-styleguide](https://wemake-python-stylegui.de/en/latest/)
- [pytest](https://docs.pytest.org/en/latest/)
- [Mypy](https://mypy.readthedocs.io/)

## Development tips
Almost all development actions are implemented on [`workflows`](workflows) script. Run `./workflows help` to see
all commands. Some of them are:
- `./workflows install_all_packages` installs packages for development
- `./workflows style_code` formats the code
- `./workflows quality_pipeline` runs all assessments (aka CI workflow)
