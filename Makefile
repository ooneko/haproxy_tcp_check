NAME = haproxy-tcp-check-wrapper
SPEC_FILE = haproxy-tcp-check-wrapper.spec
PWD = $(shell pwd)

TAG := $(shell git describe --tags --abbrev=0)
VERSION := $(shell echo $(TAG))
COMMIT := $(shell git rev-parse HEAD)
SHORTCOMMIT := $(shell echo $(COMMIT) | cut -c1-7)
RELEASE := $(shell git describe --tags)
ifeq ($(VERSION),$(RELEASE))
  RELEASE = 1
else
  RELEASE := $(shell echo $(RELEASE)| cut -d - -f 2- | sed 's/-/./')
endif

NVR := $(NAME)-$(VERSION)-$(RELEASE).el7


COMPILE_COMMAND = go build -o bin/haproxy-tcp-check-wrapper cmd/haproxy_tcp_check/main.go

BINARIES = $(wildcard bin/*)

INSTALL_DIR ?=/usr/bin

build:
	$(COMPILE_COMMAND)

install: build
	sudo install -Dm755 bin/haproxy_tcp_check $(INSTALL_DIR)/haproxy_tcp_check

build-all-binaries: clean
	GOOS=darwin    GOARCH=386      $(COMPILE_COMMAND) && mv ./bin/haproxy-tcp-check-wrapper ./bin/haproxy-tcp-check-wrapper-darwin-386
	GOOS=darwin    GOARCH=amd64    $(COMPILE_COMMAND) && mv ./bin/haproxy-tcp-check-wrapper ./bin/haproxy-tcp-check-wrapper-darwin-amd64
	GOOS=dragonfly GOARCH=amd64    $(COMPILE_COMMAND) && mv ./bin/haproxy-tcp-check-wrapper ./bin/haproxy-tcp-check-wrapper-dragonfly-amd64
	GOOS=freebsd   GOARCH=386      $(COMPILE_COMMAND) && mv ./bin/haproxy-tcp-check-wrapper ./bin/haproxy-tcp-check-wrapper-freebsd-386
	GOOS=freebsd   GOARCH=amd64    $(COMPILE_COMMAND) && mv ./bin/haproxy-tcp-check-wrapper ./bin/haproxy-tcp-check-wrapper-freebsd-amd64
	GOOS=freebsd   GOARCH=arm      $(COMPILE_COMMAND) && mv ./bin/haproxy-tcp-check-wrapper ./bin/haproxy-tcp-check-wrapper-freebsd-arm
	GOOS=linux     GOARCH=386      $(COMPILE_COMMAND) && mv ./bin/haproxy-tcp-check-wrapper ./bin/haproxy-tcp-check-wrapper-linux-386
	GOOS=linux     GOARCH=amd64    $(COMPILE_COMMAND) && mv ./bin/haproxy-tcp-check-wrapper ./bin/haproxy-tcp-check-wrapper-linux-amd64
	GOOS=linux     GOARCH=arm      $(COMPILE_COMMAND) && mv ./bin/haproxy-tcp-check-wrapper ./bin/haproxy-tcp-check-wrapper-linux-arm
	GOOS=linux     GOARCH=arm64    $(COMPILE_COMMAND) && mv ./bin/haproxy-tcp-check-wrapper ./bin/haproxy-tcp-check-wrapper-linux-arm64
	GOOS=linux     GOARCH=ppc64    $(COMPILE_COMMAND) && mv ./bin/haproxy-tcp-check-wrapper ./bin/haproxy-tcp-check-wrapper-linux-ppc64
	GOOS=linux     GOARCH=ppc64le  $(COMPILE_COMMAND) && mv ./bin/haproxy-tcp-check-wrapper ./bin/haproxy-tcp-check-wrapper-linux-ppc64le
	GOOS=linux     GOARCH=mips     $(COMPILE_COMMAND) && mv ./bin/haproxy-tcp-check-wrapper ./bin/haproxy-tcp-check-wrapper-linux-mips
	GOOS=linux     GOARCH=mipsle   $(COMPILE_COMMAND) && mv ./bin/haproxy-tcp-check-wrapper ./bin/haproxy-tcp-check-wrapper-linux-mipsle
	GOOS=linux     GOARCH=mips64   $(COMPILE_COMMAND) && mv ./bin/haproxy-tcp-check-wrapper ./bin/haproxy-tcp-check-wrapper-linux-mips64
	GOOS=linux     GOARCH=mips64le $(COMPILE_COMMAND) && mv ./bin/haproxy-tcp-check-wrapper ./bin/haproxy-tcp-check-wrapper-linux-mips64le
	GOOS=netbsd    GOARCH=386      $(COMPILE_COMMAND) && mv ./bin/haproxy-tcp-check-wrapper ./bin/haproxy-tcp-check-wrapper-netbsd-386
	GOOS=netbsd    GOARCH=amd64    $(COMPILE_COMMAND) && mv ./bin/haproxy-tcp-check-wrapper ./bin/haproxy-tcp-check-wrapper-netbsd-amd64
	GOOS=netbsd    GOARCH=arm      $(COMPILE_COMMAND) && mv ./bin/haproxy-tcp-check-wrapper ./bin/haproxy-tcp-check-wrapper-netbsd-arm
	GOOS=openbsd   GOARCH=386      $(COMPILE_COMMAND) && mv ./bin/haproxy-tcp-check-wrapper ./bin/haproxy-tcp-check-wrapper-openbsd-386
	GOOS=openbsd   GOARCH=amd64    $(COMPILE_COMMAND) && mv ./bin/haproxy-tcp-check-wrapper ./bin/haproxy-tcp-check-wrapper-openbsd-amd64
	GOOS=openbsd   GOARCH=arm      $(COMPILE_COMMAND) && mv ./bin/haproxy-tcp-check-wrapper ./bin/haproxy-tcp-check-wrapper-openbsd-arm
	GOOS=plan9     GOARCH=386      $(COMPILE_COMMAND) && mv ./bin/haproxy-tcp-check-wrapper ./bin/haproxy-tcp-check-wrapper-plan9-386
	GOOS=plan9     GOARCH=amd64    $(COMPILE_COMMAND) && mv ./bin/haproxy-tcp-check-wrapper ./bin/haproxy-tcp-check-wrapper-plan9-amd64
	GOOS=solaris   GOARCH=amd64    $(COMPILE_COMMAND) && mv ./bin/haproxy-tcp-check-wrapper ./bin/haproxy-tcp-check-wrapper-solaris-amd64
	GOOS=windows   GOARCH=386      $(COMPILE_COMMAND) && mv ./bin/haproxy-tcp-check-wrapper ./bin/haproxy-tcp-check-wrapper-windows-386
	GOOS=windows   GOARCH=amd64    $(COMPILE_COMMAND) && mv ./bin/haproxy-tcp-check-wrapper ./bin/haproxy-tcp-check-wrapper-windows-amd64

compress-all-binaries: build-all-binaries
	for f in $(BINARIES); do      \
        tar czf $$f.tar.gz $$f;    \
    done
	@rm $(BINARIES)

.PHONY: clean
clean:
	rm -Rf bin;

dist:
	git archive-all --extra .git $(NAME)-$(VERSION)-$(SHORTCOMMIT).tar.gz
