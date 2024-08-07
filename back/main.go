package main

import (
    "encoding/json"
    "math/rand"
    "net/http"
)

var names = []string{"Alice", "Bob", "Charlie", "Diana", "Eve"}

type Response struct {
    Name string `json:"name"`
}

func main() {
    http.HandleFunc("/random-name", func(w http.ResponseWriter, r *http.Request) {
        randomName := names[rand.Intn(len(names))]
        response := Response{Name: randomName}
        json.NewEncoder(w).Encode(response)
    })

    http.ListenAndServe(":8080", nil)
}
