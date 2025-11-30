package paths

import (
	"encoding/json"
	"fmt"
	"net/http"
)

func Status(w http.ResponseWriter, r *http.Request) {

	jsonString, err := json.Marshal(map[string]any{
		"last_tries": Tries,
	})
	if err != nil {
		_, err := w.Write([]byte(fmt.Sprintf("An error occurred while encoding the status json: %s", err)))
		if err != nil {
			panic(err)
		}
	}
	w.Header().Set("Content-Type", "text/yaml")
	w.Header().Set("Content-Length", string(jsonString))

}
