package internal

import (
	http2 "ledger-finance-server/server/internal/http"
	"log"
	"net/http"
	"time"
)

var tries = 0

func StartServer() {
	http.Handle("/api/", http.StripPrefix("/api/", http.FileServer(http.Dir("./web"))))
	http.HandleFunc("/manage-item/", http2.ManageItem)
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		if tries > 5 {
			log.Fatal("An fatal error occurred. " +
				"To many tries to restart http, the application will now be closed.")
		}
		log.Print("An error occurred while the start up of http. " +
			"Try again in 5 seconds...")
		tries++
		time.Sleep(time.Second * 5)
		StartServer()
		return
	}
	tries = 0
}
