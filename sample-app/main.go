package main

import (
	"fmt"
	"html/template"
	"net/http"
	"os"
	"strings"

	"github.com/gorilla/mux"
)

// PageVariables struct holds the data to be displayed in the template
type PageVariables struct {
	ColorName string
	ColorCode string
}

func main() {
	r := mux.NewRouter()

	r.HandleFunc("/", colorHandler).Methods("GET")

	port := "8888"
	fmt.Printf("Server is running on :%s...\n", port)
	http.ListenAndServe(":"+port, r)
}

func colorHandler(w http.ResponseWriter, r *http.Request) {
	color := r.URL.Query().Get("color")

	if color == "" {
		color = os.Getenv("COLOR")
	}

	if color == "" {
		color = "default"
	}

	// Check if the request is coming from curl
	userAgent := r.Header.Get("User-Agent")
	if strings.Contains(userAgent, "curl") {
		encodedColor := template.HTMLEscapeString(color)
		w.Write([]byte(fmt.Sprintf("Requested color: %s\n", encodedColor)))
		return
	}

	pageVariables := PageVariables{
		ColorName: color,
		ColorCode: getColorCode(color),
	}

	renderTemplate(w, pageVariables)
}

func renderTemplate(w http.ResponseWriter, data PageVariables) {
	tmpl, err := template.New("index.html").Parse(htmlTemplate)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	err = tmpl.Execute(w, data)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

func getColorCode(color string) string {
	switch color {
	case "red":
		return "#FF0000"
	case "green":
		return "#00FF00"
	case "blue":
		return "#0000FF"
	case "yellow":
		return "#FFFF00"
	default:
		return "#000000" // Default color (black)
	}
}

const htmlTemplate = `
<!DOCTYPE html>
<html>
<head>
	<title>Color Display</title>
	<style>
		body {
			font-size: 24px;
			text-align: center;
			margin-top: 50px;
		}
	</style>
</head>
<body style="background-color:{{.ColorCode}};">
	<p>{{.ColorName}} <span style="color:{{.ColorCode}};"></span></p>
</body>
</html>`
