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

## Run using source code
<http://localhost:5000/even> and <http://localhost:5000/random> are available after running the
following commands:
```bash
python -m pip install -r requirements.txt
python -m thenumbers
```

## Development tips
1. Run `./workflows install-all-tools` to download required Python packages
2. Run `./workflows format-code` prior to commit changes
3. Run `./workflows assess-code` prior to push changes
