package main

import (
	"log"
	"net/http"
	"os"
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "3000"
	}

	fs := http.FileServer(http.Dir("public"))
	http.Handle("/", fs)

	log.Println("Listening on port " + port + "...")
	http.ListenAndServe(":"+port, nil)
}
