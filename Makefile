.DEFAULT_GOAL := help
DIRECTORIES = $$(find -wholename ./src -o -wholename ./incolumepy -o -wholename ./tests)
PKGNAME = 'incolumepy'
REPORT_DIR = 'coverage_report'
PYTHON_VERSION := 3.8
URLCOMPARE := 'https://github.com/incolumepy/incolumepy.infosaj/compare'
CHANGELOGFILE := 'CHANGELOG.md'

.PHONY: black
black:   ##Apply code style black format
	@poetry run black $(DIRECTORIES) && git commit -m "style: Applied Code style Black format automaticly at `date +"%F %T"`" . || echo
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
	@rm -fv cov.xml
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

.PHONY: check-black
check-black: ## black checking
	@echo "Black checking .."
	@poetry run black --check $(DIRECTORIES)

.PHONY: check-flake8
check-flake8: ## flake8 checking
	@echo "flake8 checking .."
	@poetry run flake8 --config pyproject.toml $(DIRECTORIES)

.PHONY: check-isort
check-isort:  ## check isort
	@echo "isort checking .."
	@poetry run isort --check --atomic --py all $(DIRECTORIES)

.PHONY: check-mypy
check-mypy: ## mypy checking
	@echo "mypy checking .."
	@poetry run mypy $(DIRECTORIES)

.PHONY: check-pylint
check-pylint: ## pylint checking
	@echo "pylint checking .."
	@poetry run pylint $(DIRECTORIES)

.PHONY: check-pydocstyle
check-pydocstyle: ## docstring checking
	@echo "pydocstyle checking .."
	@poetry run pydocstyle $(DIRECTORIES)

.PHONY: changelog
changelog:   ## Update changelog file
	@poetry run python -c "from incolumepy.utils import update_changelog; \
	update_changelog($(CHANGELOGFILE), urlcompare=$(URLCOMPARE))"
	@echo 'Atualização de CHANGESLOG realizada com sucesso.'

.PHONY: docsgen
docsgen: clean changelog    ## Generate documentation
	@ cd docs; make html; cd -
	@ git config core.hooksPath None
	@ git commit -m "docs: Updated documentation (`date +%F@%T`)" docs/ CHANGELOG.md
	@ git config core.hooksPath .git-hooks

.PHONY: format
format: isort black   ## Formate project code with code style (isort, black)

.PHONY: help
help:  ## Show this instructions
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHOMY: install
install: setup  ## Install this package using poetry and all dependences
	@poetry install
#	@poetry add $(PKGNAME)

.PHONY: isort
isort:  ## isort apply
	@poetry run isort --atomic --py all $(DIRECTORIES) && git commit -m "style: Applied Code style isort format automaticly at `date +%F@%T`" . || echo
	@echo ">>>  Checked code style isort format automaticly  <<<"

.PHONY: lint
lint:  ## Run all linters (check-isort, check-black, flake8, pylint, mypy, pydocstyle)
lint: check-mypy check-pylint check-flake8 check-pydocstyle check-isort check-black

.PHONY: premajor
premajor:   ## Generate new premajor commit version default semver
	@ git config core.hooksPath None
	@v=$$(poetry version premajor); poetry run pytest tests/ && git commit -m "$$v" pyproject.toml $$(find -name version.txt)  #sem tag
	@ git config core.hooksPath .git-hooks

.PHONY: premajor-force
premajor-force:    ## Generate new premajor commit version default semver and your tag forcing merge into main branch
	@ git config core.hooksPath None
	@msg=$$(poetry version premajor); poetry run pytest tests/; \
git commit -m "$$msg" pyproject.toml $$(find -name version.txt) \
&& git tag -f $$(poetry version -s) -m "$$msg"; \
git checkout main; git merge --no-ff dev -m "$$msg" \
&& git tag -f $$(poetry version -s) -m "$$msg" \
&& git checkout dev    #com tag
	@ git config core.hooksPath .git-hooks

.PHONY: preminor
preminor:  ## Generate new preminor commit version default semver
	@ git config core.hooksPath None
	@v=$$(poetry version preminor); poetry run pytest -m "not slow" tests/ && git commit -m "$$v" pyproject.toml $$(find -name version.txt)  #sem tag
	@ git config core.hooksPath .git-hooks

.PHONY: preminor-force
preminor-force:    ## Generate new preminor commit version default semver and your tag forcing merge into main branch
	@ git config core.hooksPath None
	@msg=$$(poetry version preminor); poetry run pytest tests/; \
git commit -m "$$msg" pyproject.toml $$(find -name version.txt) \
&& git tag -f $$(poetry version -s) -m "$$msg"; \
git checkout main; git merge --no-ff dev -m "$$msg" \
&& git tag -f $$(poetry version -s) -m "$$msg" \
&& git checkout dev    #com tag
	@ git config core.hooksPath .git-hooks

.PHONY: prepatch
prepatch:  ## Generate new prepatch commit version default semver
	@ git config core.hooksPath None
	@v=$$(poetry version prepatch); poetry run pytest -m "not slow" tests/ && git commit -m "$$v" pyproject.toml $$(find -name version.txt)  #sem tag
	@ git config core.hooksPath .git-hooks

.PHONY: prerelease
prerelease:   ## Generate new prerelease commit version default semver
	@ git config core.hooksPath None
	@v=$$(poetry version prerelease); poetry run pytest tests && git commit -m "$$v" pyproject.toml $$(find -name version.txt)  #sem tag
	@ git config core.hooksPath .git-hooks

.PHONY: prerelease-force
prerelease-force:   ## Generate new prerelease commit version default semver and your tag forcing merge into main branch
	@ git config core.hooksPath None
	@msg=$$(poetry version prerelease); poetry run pytest tests/; \
git commit -m "$$msg" pyproject.toml $$(find -name version.txt) \
&& git tag -f $$(poetry version -s) -m "$$msg"; \
git checkout main; git merge --no-ff dev -m "$$msg" \
&& git tag -f $$(poetry version -s) -m "$$msg" \
&& git checkout dev    #com tag
	@ git config core.hooksPath .git-hooks

.PHONY: publish-testing
publish-testing: ## Publish on test.pypi.org
	@poetry publish -r testpypi --build

.PHONY: release
release:    ## Generate new release commit with version/tag default semver
	@ git config core.hooksPath None
	@msg=$$(poetry version patch); poetry run pytest tests/; \
git commit -m "$$msg" pyproject.toml $$(find -name version.txt) \
&& git tag -f $$(poetry version -s) -m "$$msg"; \
git checkout main; git merge --no-ff dev -m "$$msg" \
&& git tag -f $$(poetry version -s) -m "$$msg" \
&& git checkout dev    #com tag
	@ git config core.hooksPath .git-hooks

.PHONY: retrocompatibility
retrocompatibility: ## Run tox and check retrompatibility betwen python versions
	@poetry run tox -e py36,py37,py38,py39,py310

.PHONY: safety
safety:  ## Check safety of packages into project.
	@poetry run safety check --full-report

.PHOMY: setup
setup: ## setup environment python with poetry
	@poetry env use $(PYTHON_VERSION)
	@git config core.hooksPath .git-hooks
#	@poetry shell

.PHONY: stats
stats: ## Run all tests avaliable and generate html coverage
	@poetry run pytest -sxv --cov=$(PKGNAME) --cov-report html:$(REPORT_DIR)/html --cov-report xml:$(REPORT_DIR)/cov.xml --cov-report annotate:$(REPORT_DIR)/annotate --cov-report term-missing:skip-covered tests/

.PHONY: test
test:   ## Tun all tests on venv
	@poetry run pytest tests/
