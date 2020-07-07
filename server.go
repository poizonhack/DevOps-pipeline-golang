package main



import (

	"fmt"

	"net/http"

)



// PlayerServer currently returns Hello Devops, world given _any_ request.

func PlayerServer(w http.ResponseWriter, r *http.Request) {

	fmt.Fprint(w, "Hello DevOps")

}
