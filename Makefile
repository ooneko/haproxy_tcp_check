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
NVR := $(NAME)-$(VERSION)-$(RELEASE).el6

COMPILE_COMMAND = go build -o bin/haproxy-tcp-check-wrapper cmd/haproxy_tcp_check/main.go
BINARIES = $(wildcard bin/*)
INSTALL_DIR ?=/usr/bin

# Testing only
echo:
	echo COMMIT $(COMMIT)
	echo VERSION $(VERSION)
	echo RELEASE $(RELEASE)
	echo NVR $(NVR)

dist: build-all-binaries
	git archive-all --prefix=$(NAME)-$(VERSION) --extra .git --extra bin $(NAME)-$(VERSION)-$(SHORTCOMMIT).tar.gz

spec:
	sed $(SPEC_FILE).in \
	  -e 's/@COMMIT@/$(COMMIT)/' \
	  -e 's/@VERSION@/$(VERSION)/' \
	  -e 's/@RELEASE@/$(RELEASE)/' \
	  > $(SPEC_FILE)


srpm: dist spec
	rpmbuild -bs $(SPEC_FILE) \
	  --define "_topdir ." \
	  --define "_sourcedir ." \
	  --define "_srcrpmdir ." \
	  --define "dist .el6"

rpm: dist srpm
	mock -r epel-6-x86_64 rebuild $(NVR).src.rpm \
	  --resultdir=. \
	  --define "dist .el6" \
	  --enable-network


build:
	$(COMPILE_COMMAND)

install: build
	sudo install -Dm755 bin/haproxy_tcp_check $(INSTALL_DIR)/haproxy_tcp_check

build-all-binaries: clean
	GOOS=linux     GOARCH=386      $(COMPILE_COMMAND) && mv ./bin/haproxy-tcp-check-wrapper ./bin/haproxy-tcp-check-wrapper-linux-386
	GOOS=linux     GOARCH=amd64    $(COMPILE_COMMAND) && mv ./bin/haproxy-tcp-check-wrapper ./bin/haproxy-tcp-check-wrapper-linux-amd64

compress-all-binaries: build-all-binaries
	for f in $(BINARIES); do      \
        tar czf $$f.tar.gz $$f;    \
    done
	@rm $(BINARIES)

.PHONY: clean
clean:
	rm -Rf bin;
