GO=go

OUTPUT=dist/service

BUILDTIME=`date +%FT%T%Z`
#GITHASH='git rev-parse HEAD'
VERSION=1.0.abc
LDFLAGS=-ldflags "-X main.test=$(GITHASH)"
LDFLAGSOFF=-ldflags "-X BuildInfo.BuildTime=$(VERSION) -X BuildInfo.Commit=$(GITHASH) -X main.test=$(GITHASH)"

GITVERSION ?=$(shell git describe --tags)
GITHASH ?=$(shell git rev-parse HEAD)

COMPILEFLAGS=-ldflags " \
-X github.com/restSampleServices/go-service/BuildInfo.BuildTime=$(BUILDTIME) \
-X github.com/restSampleServices/go-service/BuildInfo.Version=$(GITVERSION) \
-X github.com/restSampleServices/go-service/BuildInfo.Commit=$(GITHASH) \
-X main.test=$(GITHASH) \
"

#GITHASH := $(if $(and $(wildcard .git),$(shell which git)), \
    $(shell git rev-parse HEAD))

go-version:
	@$(GO) version
	@echo "make build|clean|test"
	@echo ${GITHASH}

clean:
	@echo "clean ..."
	@$go clean
	@if [ -d mocks ] ; then rm -rf mocks; fi
	@if [ -d build ] ; then rm -rf build fi
	@if [ -d vendor ] ; then rm -rf vendor; fi

test-mockgen: generate
	@echo "generating mocks ..."
	@if [ ! -d mocks ] ; then mkdir -p  mocks; fi
	@go generate ./...

generate:
	@echo "generating application infos ..."
	@if [ ! -d $(INFO_DIR) ] ; then mkdir -p  $(INFO_DIR); fi
	@sed -e "s/##VERSION##/${VERSION}/g" \
		-e "s/##BUILD_ID##/${CI_BUILD_ID}/g" \
		-e "s/##BUILD_TIME##/${BUILD_TIME}/g" \
		-e "s/##GIT_COMMIT##/${CI_COMMIT_TAG}/g" \
		application-info.go.template > info/application-info.go

build:
ifdef GITHASH
		@echo $(GITHASH)
		@echo $(GITVERSION)
else
		@echo "Git not installed or not in a git repository"
		#we can reference a environment variable from build pipeline here
		GITHASH = "n.a."
endif
	@echo "start building ..."
	go build -v $(COMPILEFLAGS) -o $(OUTPUT)

versioninfo:
	@echo $(GITHASH)
	@echo $(GITVERSION)
	@echo $(VERSION)
	@echo $(BUILDTIME)

run:
	@go run $(COMPILEFLAGS) restSampleService.go

test:
	@echo "test ..."
	@$(GOTEST) -cover ./...

checkstyle:
	@echo "stylecheck ..."
	@golint ./...

get-prerequisites:
	@echo "get packages ..."
	@$(GOGET) github.com/golang/mock/gomock
	@$(GOGET) github.com/golang/mock/mockgen
	@$(GOGET) github.com/golang/dep/cmd/dep
	@$(GOGET) github.com/golang/lint/golint

get-dependencies:
	@echo "get dependencies..."
	@dep ensure

install: get-prerequisites get-dependencies test-mockgen

ci: install test checkstyle build
