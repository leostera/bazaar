package main

import (
	"github.com/gin-gonic/gin"
	"net/http"
)

func main() {
	r := gin.Default()
	r.GET("/", func(c *gin.Context) {
		c.Data(200, "plain/text", []byte("hello world!"))
	})
	http.ListenAndServe(":8081", r)
}
