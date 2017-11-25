package rest

import (
	_ "encoding/json"
	"fmt"
	"github.com/gorilla/mux"
	"log"
	"net/http"
)

type ServiceLauncher interface {
	Start()
}

type Service struct{}

func (Service) Start() {
	router := mux.NewRouter()
	log.Fatal(http.ListenAndServe(":8000", router))
}

func StartService(port int) {
	router := mux.NewRouter()
	//log.Fatal(http.ListenAndServe(":8000", router))
	fmt.Println("starting service at localhost:8080")
	log.Fatal(http.ListenAndServe("localhost:8080", router))
}
