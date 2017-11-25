VERSION=1.0

#tools
GO=go
OUTPUT=dist/service

BUILDTIME=`date +%FT%T%Z`

#grab build infos
GITVERSION :=$(if $(and $(wildcard .git),$(shell which git)),$(shell git describe --tags --abbrev=0))
GITHASH :=$(if $(and $(wildcard .git),$(shell which git)),$(shell git rev-parse HEAD))

#application configuration
COMPILEFLAGS=-ldflags " \
-X github.com/restSampleServices/go-service/BuildInfo.BuildTime=$(BUILDTIME) \
-X github.com/restSampleServices/go-service/BuildInfo.Version=$(GITVERSION) \
-X github.com/restSampleServices/go-service/BuildInfo.Commit=$(GITHASH) \
-X main.test=$(GITHASH) \
"

go-version:
	@$(GO) version
	@echo "make devenv|run|build|clean|test"

ensureBuildinfo:
ifdef GITHASH
else
		@echo "Git not installed or not in a git repository"
		#we can reference a environment variable from build pipeline here
		$(eval GITHASH=n.a.)
endif

ifdef GITVERSION
else
		@echo "Git not installed or not in a git repository or no Tag found"
		$(eval GITVERSION=0.0.0)
endif

#used for debugging and in case of errors
versioninfo: ensureBuildinfo
	@echo Commit $(GITHASH)
	@echo Git based Version $(GITVERSION)
	@echo Make based Version $(VERSION)
	@echo Build time $(BUILDTIME)

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

run: ensureBuildinfo
	@echo "start application ..."
	@go run $(COMPILEFLAGS) restSampleService.go

test:
	@echo "test ..."
	@$(GOTEST) -cover ./...

checkstyle:
	@echo "stylecheck ..."
	@golint ./...

devenv: prerequisites dependencies test-mockgen

ci: devenv test checkstyle build
