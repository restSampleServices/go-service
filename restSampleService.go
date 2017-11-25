package main

import (
	"fmt"
  "github.com/restSampleServices/go-service/BuildInfo"
	"github.com/restSampleServices/go-service/rest"
)
var test ="na"

func main() {
	//fmt.Println("BuildInfo", test)

	fmt.Println("Version", BuildInfo.Version)
	fmt.Println("Buildtime", BuildInfo.BuildTime)
	fmt.Println("Commit", BuildInfo.Commit)
	rest.StartService(8080)

}
