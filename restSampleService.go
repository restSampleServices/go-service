package main

import (
	"fmt"
  "github.com/restSampleServices/go-service/BuildInfo"
)
var test ="na"

func main() {
	fmt.Println("BuildInfo", test)

	fmt.Println("BuildInfo", BuildInfo.BuildTime, BuildInfo.Version, BuildInfo.Commit)
}
