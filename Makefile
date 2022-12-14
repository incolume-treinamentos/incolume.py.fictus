.DEFAULT_GOAL := help
DIRECTORIES = $$(find -wholename ./src -o -wholename ./incolumepy -o -wholename ./incolume/py -o -wholename ./tests)
PKGNAME = 'incolume.py'
REPORT_DIR = 'coverage_report'
PYTHON_VERSION := 3.10
URLCOMPARE := 'https://github.com/incolumepy/incolume.py.fictus/compare'
CHANGELOGFILE := 'CHANGELOG.md'

.PHONY: help
help:  ## Show this instructions
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: black
black:   ##Apply code style black format
	@poetry run black $(DIRECTORIES) && git commit -m "style(lint): Applied Code style black automaticly at `date +"%FT%T%z"`" . || echo
	@echo ">>>  Checked code style Black format automaticly  <<<"

.PHONY: clean
clean:   ## Shallow clean into environment (.pyc, .cache, .egg, .log, et all)
	@echo -n "Starting cleanning environment .."
	@find ./ -name '*.pyc' -exec rm -f {} \;
	@find ./ -name '*~' -exec rm -f {} \;
	@find ./ -name 'Thumbs.db' -exec rm -f {} \;
	@find ./ -name '*.log' -exec rm -f {} \;
	@find ./ -name '*.log.*' -exec rm -f {} \;
	@find ./ -name ".cache" -exec rm -fr {} \;
	@find ./ -name "*.egg-info" -exec rm -rf {} \;
	@find ./ -name "*.coverage" -exec rm -rf {} \;
	@find ./ -maxdepth 1 -type d -name "*cov*" -exec rm -rf {} \;
	@rm -fv cov.xml poetry.toml
	@rm -rf docs/_build
	@echo " finished!"

.PHONY: clean-all
clean-all: clean   ## Deep cleanning into environment (dist, build, htmlcov, .tox, *_cache, et all)
	@echo "Starting Deep cleanning .."
	@rm -rf dist
	@rm -rf build
	@rm -rf htmlcov
	@rm -rf coverage_report
	@rm -rf .tox
	@find ./ \( -name "*_cache" -o -name '*cache__' \) -exec rm -rf {} 2> /dev/null \;
	@#fuser -k 8000/tcp &> /dev/null
	@poetry env list|awk '{print $$1}'|while read a; do poetry env remove $${a} 2> /dev/null && echo "$${a} removed."|| echo "$${a} not removed."; done
	@echo "Deep cleaning finished!"

.PHONY: docsgen
docsgen: clean changelog    ## Generate documentation
	@ cd docs; make html; cd -
	@ git commit -m "docs: Updated documentation (`date +%FT%T%z`)" docs/ CHANGELOG.md

.PHONY: changelog
changelog:   ## Update changelog file
	@poetry run python -c "from incolumepy.utils import update_changelog; \
	update_changelog($(CHANGELOGFILE), urlcompare=$(URLCOMPARE))"
	@echo 'CHANGELOG file updated with success.'

.PHONY: isort
isort:   ##Apply code style isort format
	@poetry run isort $(DIRECTORIES) && git commit -m "style(lint): Applied Code style isort automaticly at `date +"%FT%T%z"`" . || echo
	@echo ">>>  Checked code style isort format automaticly  <<<"

.PHONY: patch
patch:   ## Generate a build, new patch commit version, default semver
	@v=$$(poetry version patch); poetry run pytest tests/ && make changelog && git commit -m "$$v" pyproject.toml CHANGELOG.md $$(find incolume* -name version.txt)  #sem tag

.PHONY: premajor
premajor:    ## Generate a prebuild, new premajor commit version, default semver
	@v=$$(poetry version premajor); poetry run pytest tests/ && make changelog && git commit -m "$$v" pyproject.toml CHANGELOG.md $$(find incolume* -name version.txt)  #sem tag

.PHONY: preminor
preminor:    ## Generate a prebuild, new preminor commit version, default semver
	@v=$$(poetry version preminor); poetry run pytest tests/ && make changelog && git commit -m "$$v" pyproject.toml CHANGELOG.md $$(find incolume* -name version.txt)  #sem tag

.PHONY: prerelease
prerelease:    ## Generate a prebuild, new prerelease commit version, default semver
	@v=$$(poetry version prerelease); poetry run pytest tests/ && make changelog && git commit -m "$$v" pyproject.toml CHANGELOG.md $$(find incolume* -name version.txt)  #sem tag

.PHOMY: setup
setup: ## setup environment python with poetry end install all dependences
	@poetry env use $(PYTHON_VERSION)
	@git config core.hooksPath .git-hooks
	@poetry install
