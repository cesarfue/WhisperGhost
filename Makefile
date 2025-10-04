all: run

run:
	@if [ -f .env ]; then \
		export $$(cat .env | grep -v '^#' | xargs) && \
		swift run 2>&1 | grep -v "warning:"; \
	else \
		echo "Error: .env file not found"; \
		exit 1; \
	fi

build:
	@if [ -f .env ]; then \
		export $$(cat .env | grep -v '^#' | xargs) && swift build; \
	else \
		echo "Error: .env file not found"; \
		exit 1; \
	fi

clean:
	swift package clean

# Debug mode with all output
debug:
	@if [ -f .env ]; then \
		export $$(cat .env | grep -v '^#' | xargs) && swift run; \
	else \
		echo "Error: .env file not found"; \
		exit 1; \
	fi

.PHONY: run build clean debug
