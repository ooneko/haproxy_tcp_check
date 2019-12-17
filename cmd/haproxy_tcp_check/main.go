/*
 * Copyright 2019 - 2019 KingSoft
 * Author: Lucas Hua (huabinhong@kingsoft.com)
 */

package main

import (
	"fmt"
	flag "github.com/spf13/pflag"
	"github.com/spf13/viper"
	"net"
	"os"
	"os/exec"
	"strconv"
)

var connHost string
var connPort int
var scriptPath string

func parseArgs() {
	flag.StringP("host", "h", "0.0.0.0", "IP address the service bind to.")
	flag.IntP("port", "p", 8080, "Port which service bind to.")
	flag.StringP("script", "s", "", "The script path.")

	viper.AddConfigPath(".")
	viper.AddConfigPath("/etc/haproxy-tcp-check-wrapper")
	viper.SetConfigName("config.toml")
	viper.SetConfigType("toml")
	viper.BindPFlags(flag.CommandLine)
	flag.Parse()

	err := viper.ReadInConfig()
	if err != nil {
		if _, ok := err.(viper.ConfigFileNotFoundError); ok {
			fmt.Println("Not found config file, ignore.")
		} else {
			fmt.Println(err.Error())
		}
	}

	connHost = viper.GetString("host")
	connPort = viper.GetInt("port")
	scriptPath = viper.GetString("script")
}

func main() {
	parseArgs()

	l, err := net.Listen("tcp", connHost+":"+strconv.Itoa(connPort))
	if err != nil {
		fmt.Println("Error listenning:", err.Error())
		os.Exit(1)
	}

	defer l.Close()

	fmt.Println("Listening on " + connHost + ":" + strconv.Itoa(connPort))
	for {
		conn, err := l.Accept()
		if err != nil {
			fmt.Println("Error accepting ", err.Error())
		}
		go handlerRequest(conn)
	}
}

func handlerRequest(conn net.Conn) {
	cmd := exec.Command("/bin/bash", scriptPath)
	out, err := cmd.Output()
	if err != nil {
		fmt.Println("Error occurs in command executed" + err.Error())
		conn.Write([]byte(err.Error()))
	} else {
		conn.Write([]byte(out))
	}
	conn.Close()
}
