# Numbers API
The project provides 2 HTTP endpoints
- `/even` that returns an even number sequentially from 0
- `/random` that returns a random positive number

## Used tools
**Production tools**
- Python 3.7
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
