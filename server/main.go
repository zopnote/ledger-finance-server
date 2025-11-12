package main

import (
	"database/sql"
	"fmt"
	"net/http"
	"os"
	"time"

	_ "modernc.org/sqlite"
)

func ServeHttp(w http.ResponseWriter, req *http.Request) {
	w.Header().Set("Content-Type", "text/plain")
	w.Write([]byte("This is an example server.\n"))
	// fmt.Fprintf(w, "This is an example server.\n")
	// io.WriteString(w, "This is an example server.\n")
}

func main() {

	http.HandleFunc("", ServeHttp)
	err := http.ListenAndServe(":3030", nil)

	year := time.Now().Year()

	month := int(time.Now().Month())
	quarter := (month-1)/3 + 1

	err = os.Mkdir("data", os.ModeDir)
	db, err := sql.Open("sqlite", fmt.Sprintf("data/td-finances-%d-q%d.db", year, quarter))
	if err != nil {
		panic(err)
	}
	defer db.Close()

	if err := db.Ping(); err != nil {
		panic(err)
	}
	_, err = db.Exec(`CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, name TEXT)`)
	if err != nil {
		panic(err)
	}

	_, err = db.Exec(`INSERT INTO users (name) VALUES (?)`, "Lenny")
	if err != nil {
		panic(err)
	}

	rows, err := db.Query(`SELECT id, name FROM users`)
	if err != nil {
		panic(err)
	}
	defer rows.Close()

	for rows.Next() {
		var id int
		var name string
		rows.Scan(&id, &name)
		fmt.Println(id, name)
	}
}
