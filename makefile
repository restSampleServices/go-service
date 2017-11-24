GO=go

OUTPUT=dist/service

BUILDTIME=`date +%FT%T%Z`
VERSION=1.0.abc

GITVERSION ?=$(if $(and $(wildcard .git),$(shell which git)),$(shell git describe --tags --abbrev=0))
GITHASH :=$(if $(and $(wildcard .git),$(shell which git)),$(shell git rev-parse HEAD))

COMPILEFLAGS=-ldflags " \
-X github.com/restSampleServices/go-service/BuildInfo.BuildTime=$(BUILDTIME) \
-X github.com/restSampleServices/go-service/BuildInfo.Version=$(GITVERSION) \
-X github.com/restSampleServices/go-service/BuildInfo.Commit=$(GITHASH) \
-X main.test=$(GITHASH) \
"

ensureBuildinfo:
ifdef GITHASH
		@echo Commit: $(GITHASH)
else
		@echo "Git not installed or not in a git repository"
		#we can reference a environment variable from build pipeline here
		GITHASH:=n.a.
endif

ifdef GITVERSION
		@echo Version: $(GITVERSION)
else
		@echo "Git not installed or not in a git repository or no Tag found"
		GITVERSION=0.0.0
endif

go-version:
	@$(GO) version
	@echo "make build|clean|test"
	@echo ${GITHASH}

prerequisites:
	@echo "install prerequisites ..."
	@$(GO) get github.com/golang/mock/gomock
	@$(GO) get github.com/golang/mock/mockgen
	@$(GO) get github.com/golang/dep/cmd/dep
	@$(GO) get github.com/golang/lint/golint

dependencies:
	@echo "install dependencies..."
	@dep ensure

clean:
	@echo "clean ..."
	@$go clean
	@if [ -d mocks ] ; then rm -rf mocks; fi
	@if [ -d build ] ; then rm -rf build fi
	@if [ -d vendor ] ; then rm -rf vendor; fi

test-mockgen: 
	@echo "generating mocks ..."
	@if [ ! -d mocks ] ; then mkdir -p  mocks; fi
	@go generate ./...

build: ensureBuildinfo
	@echo "start building ..."
	go build -v $(COMPILEFLAGS) -o $(OUTPUT)

versioninfo:
	@echo Commit $(GITHASH)
	@echo Git based Version $(GITVERSION)
	@echo Make based Version $(VERSION)
	@echo Build time $(BUILDTIME)

run: ensureBuildinfo
	@echo "start application ..."
	@go run $(COMPILEFLAGS) restSampleService.go

test:
	@echo "test ..."
	@$(GOTEST) -cover ./...

checkstyle:
	@echo "stylecheck ..."
	@golint ./...

install: prerequisites dependencies test-mockgen

ci: install test checkstyle build
