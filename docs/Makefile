BUILD_DIR = ./_build

all: docs

docs:
	jupyter-book build -W -n --keep-going .

.PHONY: clean

clean:
	jupyter-book clean .
