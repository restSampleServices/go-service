# go-service
Golang Rest Service implementation


go run -ldflags "-X github.com/restSampleServices/go-service/BuildInfo.BuildTime=$VERSION -X github.com/restSampleServices/go-service/BuildInfo.BuildInfo.Commit=$GITHASH -X main.test=$GITHASH" restSampleService.go
