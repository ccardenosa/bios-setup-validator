# Makefile

all: install test

install: venv
	: # Activate venv and install somthing inside
	source .venv/bin/activate && python3 -m pip install --upgrade pip && pip install -r requirements.txt

devel: install
	: # Other commands here
	source .venv/bin/activate && (\
		ansible-galaxy collection install -r requirements.yaml -p ./playbooks/collections \
	)

venv:
	: # Create .venv if it doesn't exist
	: # test -d .venv || virtualenv -p python3 --no-site-packages .venv
	test -d .venv || python3 -m venv .venv

run:
	: # Run your app here, e.g
	source .venv/bin/activate && pip -V

	: # Exec multiple commands
	source .venv/bin/activate && (\
		python3 -c 'import sys; print(sys.prefix)'; \
		echo ; \
		pip3 -V ;\
		echo ; \
		ansible-playbook --version ; \
		echo ; \
		echo "ansible-builder Version: " ; \
		ansible-builder --version \
	)

test:
	: # Running Testing...
	source .venv/bin/activate && (\
		export PYTHONPATH=${PWD}:${PATH}; \
		pytest tests/ \
	)

clean:
	rm -rf .venv playbooks/collections context
	find . -type f -iname '*.pyc' -delete
