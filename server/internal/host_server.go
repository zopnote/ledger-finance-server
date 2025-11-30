package internal

import (
	"fmt"
	server "ledger-finance-server/server/internal/paths"
	"log"
	"net/http"
	"time"
)

var Tries = 0

func StartServer() {
	prefix := "/api"
	root := fmt.Sprintf("%s/", prefix)
	http.Handle(
		root,
		http.StripPrefix(root, http.FileServer(http.Dir("./web"))))
	http.HandleFunc(fmt.Sprintf("%s/status", prefix), server.Status)
	http.HandleFunc(fmt.Sprintf("%s/book", prefix), server.Book)
	http.HandleFunc(fmt.Sprintf("%s/retrieve-booked", prefix), server.Status)
	http.HandleFunc(fmt.Sprintf("%s/list-booked", prefix), server.Status)

	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		if Tries > 5 {
			log.Fatal("An fatal error occurred. " +
				"To many Tries to restart paths, the application will now be closed.")
		}
		log.Print("An error occurred while the start up of paths. " +
			"Try again in 5 seconds...")
		Tries++
		time.Sleep(time.Second * 5)
		StartServer()
		return
	}
	Tries = 0
}
