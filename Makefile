
default: help
.PHONY: default

help:
	@echo 'Usage:'
	@echo '	$$ make [action]'
	@echo
	@echo 'Example:'
	@echo '	$$ make'
	@echo '	$$ make help'
	@echo
	@echo '	$$ make prepare'
	@echo '	$$ make build'
	@echo '	$$ make clean'
	@echo
.PHONY: help




prepare:
	@sudo ./do-build.sh prepare
.PHONY: prepare


build:
	@./build.sh
.PHONY: build


clean:
	@sudo ./do-build.sh clean
.PHONY: clean




test:
	@sudo ./do-build.sh test
.PHONY: test
