package main

import (
	"fmt"
	"log"
	"net"

	"vim-apm.theprimeagen.tv/pkg/parser"
)

func main() {
    tcpVimAPMServer()
}

func tcpVimAPMServer() {
    // Listen for incoming connections on port 8080
    ln, err := net.Listen("tcp", ":6112")
    if err != nil {
        fmt.Println(err)
        return
    }

    // Accept incoming connections and handle them
    for {
        conn, err := ln.Accept()
        fmt.Println("Connection accepted")
        if err != nil {
            fmt.Println(err)
            continue
        }

        // Handle the connection in a new goroutine
        go handleVimAPMConnection(conn)
    }
}

func handleVimAPMConnection(conn net.Conn) {
    // Close the connection when we're done
    defer conn.Close()

    for {
        // Read incoming data
        buf := make([]byte, 1024)
        n, err := conn.Read(buf)
        if err != nil {
            fmt.Println(err)
            return
        }

        str := string(buf[:n])
        for {
            fmt.Printf("current string: %s\n", str)

            parsed, n, err := parser.Next(str)
            if err != nil {
                log.Fatal(err)
            }

            if parsed != nil {
                motion, _ := parsed.AsMotion()
                fmt.Printf("Parsed: %v -- %v\n", parsed, motion)
                str = str[n:]
            } else {
                break
            }
        }
    }
}

