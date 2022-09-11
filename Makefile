JSON_CI_VENV ?= venv
JSON_CI_USE_VENV ?= true

TOOLS_SRCS = $(shell find tools -type f -name '*.py' | sort)

.ONESHELL:
.SHELLFLAGS: -e

VENV_DEP =
ifeq ($(JSON_CI_USE_VENV),true)
	VENV_DEP = .venv-stamp
endif

.PHONY: all
all: update

# format source files
.PHONY: pretty
pretty: $(VENV_DEP)
	@[ "$(JSON_CI_USE_VENV)" == "true" ] && . $(JSON_CI_VENV)/bin/activate
	black $(TOOLS_SRCS)

# update all
.PHONY: update
update: update_docker update_workflows

# update Dockerfiles
.PHONY: update_docker
update_docker: $(VENV_DEP)
	@[ "$(JSON_CI_USE_VENV)" == "true" ] && . $(JSON_CI_VENV)/bin/activate
	@rm -fv Dockerfile.*
	./tools/generators/gen_dockerfiles.py

# update GitHub workflows
.PHONY: update_workflows
update_workflows: $(VENV_DEP)
	@[ "$(JSON_CI_USE_VENV)" == "true" ] && . $(JSON_CI_VENV)/bin/activate
	@rm -fv .github/workflows/*.yml
	./tools/generators/gen_workflows.py

# install a Python virtual environment
.PHONY: install_venv
install_venv: requirements.txt
	python3 -mvenv $(JSON_CI_VENV)
	$(JSON_CI_VENV)/bin/pip install --upgrade pip
	$(JSON_CI_VENV)/bin/pip install wheel
	$(JSON_CI_VENV)/bin/pip install -r requirements.txt

# empty target for virtual environment
.venv-stamp: requirements.txt
	$(MAKE) install_venv
	@touch $@

# uninstall the virtual environment
uninstall_venv:
	rm -fr $(JSON_CI_VENV) .venv-stamp
