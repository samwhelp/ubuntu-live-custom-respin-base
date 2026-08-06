
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
	@echo '	$$ make mount'
	@echo '	$$ make chroot'
	@echo '	$$ make unmount'
	@echo
	@echo '	$$ make create-full-system'
	@echo '	$$ make archive-system-to-iso'
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




mount:
	@sudo ./do-build.sh mount
.PHONY: mount


chroot:
	@sudo ./do-build.sh chroot
.PHONY: chroot


unmount:
	@sudo ./do-build.sh unmount
.PHONY: unmount




create-full-system:
	@sudo ./do-build.sh create_full_system
.PHONY: create-full-system


archive-system-to-iso:
	@sudo ./do-build.sh archive_system_to_iso
.PHONY: archive-system-to-iso




test:
	@sudo ./do-build.sh test
.PHONY: test
