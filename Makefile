JSON_CI_VENV ?= venv
JSON_CI_USE_VENV ?= true

.ONESHELL:
.SHELLFLAGS: -e

VENV_DEP =
ifeq ($(JSON_CI_USE_VENV),true)
	VENV_DEP = .venv-stamp
endif

.PHONY: all
all: $(VENV_DEP)

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
