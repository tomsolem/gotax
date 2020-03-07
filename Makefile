IMPORT_PATH := github.com/tomsolem/gotax/cmd

OUTPUT := main
# V := 1 # When V is set, print commands and build progress.

# Space separated patterns of packages to skip in list, test, format.
IGNORED_PACKAGES := /vendor/

export GO111MODULE=on

PROTOC_GO_GEN := $(which protoc-gen-go)
ifndef PROTOC_GO_GEN
  # $(info *** Appending Go tools to path)
  PATH := $(PATH):$(HOME)/go/bin
endif

.PHONY: all
all: build

.PHONY: build
build:
	$Q CGO_ENABLED=0 GOOS=linux go build -a --installsuffix dist -o $(OUTPUT) $(if $V,-v) $(VERSION_FLAGS) $(IMPORT_PATH)/service

### Code not in the repository root? Another binary? Add to the path like this.
# .PHONY: otherbin
# otherbin: .ok
#       $Q go install $(if $V,-v) $(VERSION_FLAGS) $(IMPORT_PATH)/cmd/otherbin

##### ^^^^^^ EDIT ABOVE ^^^^^^ #####

##### =====> Utility targets <===== #####

.PHONY: clean test list cover format

clean:
	-rm $(OUTPUT)
	$Q rm -rf .cover

test:
	mkdir -p .cover
	echo "mode: count" > .cover/coverage-all.out
	$(foreach pkg,$(allpackages), \
			go test -p=1 -cover -covermode=count -coverprofile=.cover/coverage.out ${pkg}; \
			tail -n +2 .cover/coverage.out >> .cover/coverage-all.out;)

cover: test
	mkdir -p .cover
	go tool cover -html=.cover/coverage-all.out

list:
	@echo $(allpackages)

format:
	$Q find . -iname \*.go | grep -v \
		-e "^$$" $(addprefix -e ,$(IGNORED_PACKAGES)) | xargs goimports -w

HAS_LINTER := $(shell which golangci-lint)

lint:
ifndef HAS_LINTER
ifdef CI
	curl -sfL https://install.goreleaser.com/github.com/golangci/golangci-lint.sh | sh -s -- -b $(go env GOPATH)/bin v1.13.2
else
	echo "Missing golangci-lint, please install it"
	exit 1
endif
endif

	$Q golangci-lint run ./...

##### =====> Internals <===== #####

Q := $(if $V,,@)

.ok:
	$Q mkdir -p .cover
	$Q touch $@

.PHONY: setup
setup: .ok
	go mod download

VERSION          := $(shell git describe --tags --always --dirty="-dev")
DATE             := $(shell date -u '+%Y-%m-%d-%H%M UTC')
VERSION_FLAGS    := -ldflags='-X "main.Version=$(VERSION)" -X "main.BuildTime=$(DATE)"'

_allpackages = $(shell ( cd $(CURDIR)/ && \
    go list ./... 2>&1 1>&3 | \
    grep -v -e "^$$" $(addprefix -e ,$(IGNORED_PACKAGES)) 1>&2 ) 3>&1 | \
    grep -v -e "^$$" $(addprefix -e ,$(IGNORED_PACKAGES)))

# memoize allpackages, so that it's executed only once and only if used
allpackages = $(if $(__allpackages),,$(eval __allpackages := $$(_allpackages)))$(__allpackages)

unexport GOBIN
