JSON_CI_VENV ?= venv
JSON_CI_USE_VENV ?= true

.ONESHELL:
.SHELLFLAGS: -e

ALL_DEPS = update
ifeq ($(JSON_CI_USE_VENV),true)
		ALL_DEPS = install_venv update
endif

.PHONY: all
all: $(ALL_DEPS)

# update all
.PHONY: update
update: update_docker update_workflows

# update Dockerfiles
.PHONY: update_docker
update_docker:
	@[ "x$(JSON_CI_USE_VENV)" == "xtrue" ] && . $(JSON_CI_VENV)/bin/activate
	./generate_dockerfiles.py

# update GitHub workflows
.PHONY: update_workflows
update_workflows:
	@[ "x$(JSON_CI_USE_VENV)" == "xtrue" ] && . $(JSON_CI_VENV)/bin/activate
	./generate_workflows.py

# install a Python virtual environment
.PHONY: install_venv
install_venv: .venv-stamp
	python3 -mvenv $(JSON_CI_VENV)
	$(JSON_CI_VENV)/bin/pip install --upgrade pip
	$(JSON_CI_VENV)/bin/pip install wheel
	$(JSON_CI_VENV)/bin/pip install -r requirements.txt

.venv-stamp: requirements.txt
	@touch $@

# uninstall the virtual environment
uninstall_venv:
	rm -fr $(JSON_CI_VENV) .venv-stamp
