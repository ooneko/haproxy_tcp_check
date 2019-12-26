# HAPROXY TCP CHECK Wrapper
HAProxy TCP Çheck Wrapper is a deamon, listening on specific TCP port.

Execute a script when the TCP port is connected, and return the result to TCP client.



# How to use?
## Build
```
make

make install
```

## Configration of HAProxy TCP Check Wrapper
Copy /etc/haproxy-tcp-check-wrapper to /etc

Edit the /etc/haproxy-tcp-check-wrapper/config.toml

```ini
# Which IP address bound to.
host = "0.0.0.0"
# Which TCP Port bound to.
port = 9090
# Which script to run, when tcp connection established.
script = "/root/mysqlchk.mysql"
```

Just run haproxy-tcp-check-wrapper
```
haproxy_tcp_check &
```

## Configration of HAProxy
```
listen mysql
    mode tcp
    balance source
    option tcp-check
    tcp-check expect string MySQL\ master\ is\ running
    default-server port 9090 downinter 5s rise 3 fall 2 slowstart 60s
    option tcplog
    bind 10.177.4.100:3306
    server control-01 10.177.4.10:3306 check
    server control-02 10.177.4.11:3306 check
    server control-03 10.177.4.12:3306 check
```


