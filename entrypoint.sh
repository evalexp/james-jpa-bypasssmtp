#!/bin/bash


startServer() {
    java -Dlogback.configurationFile=/root/conf/logback.xml -Dworking.directory=/root/ -Djdk.tls.ephemeralDHKeySize=2048 -cp /root/resources:/root/classes:/root/libs/* org.apache.james.JPAJamesServerMain
}

configureIptables() {
    iptables -t nat -N SMTP_BYPASS
    # LANs ip
    iptables -t nat -A SMTP_BYPASS -d 0.0.0.0/8 -j RETURN  
    iptables -t nat -A SMTP_BYPASS -d 10.0.0.0/8 -j RETURN  
    iptables -t nat -A SMTP_BYPASS -d 127.0.0.0/8 -j RETURN  
    iptables -t nat -A SMTP_BYPASS -d 169.254.0.0/16 -j RETURN  
    iptables -t nat -A SMTP_BYPASS -d 172.16.0.0/12 -j RETURN  
    iptables -t nat -A SMTP_BYPASS -d 192.168.0.0/16 -j RETURN  
    iptables -t nat -A SMTP_BYPASS -d 224.0.0.0/4 -j RETURN  
    iptables -t nat -A SMTP_BYPASS -d 240.0.0.0/4 -j RETURN  
    # SMTP redirect
    iptables -t nat -A SMTP_BYPASS -p tcp --dport 25 -j REDIRECT --to-ports 12345
    # Apply to nat client
    iptables -t nat -A PREROUTING -p tcp -j SMTP_BYPASS
    # Apply to localhost
    iptables -t nat -A OUTPUT -p tcp -j SMTP_BYPASS
}

cp redsocks.conf redsocks.self.conf

if [ -z $SOCKS_HOST ]; then
    startServer
    exit
else
    sed -i "s/\${SOCKS_HOST}/$SOCKS_HOST/g" redsocks.self.conf
fi

if [ -z $SOCKS_PORT ]; then
    echo "[*] Socks port default set to 1080"
    SOCKS_PORT=1080
fi

sed -i "/\${SOCKS_PORT}/s/\${SOCKS_PORT}/$SOCKS_PORT/g" redsocks.self.conf

if [ -z $SOCKS_USERNAME ] || [ -z $SOCKS_PASSWORD ]; then
    echo '[*] Socks5 proxy without authentication is so dangerous.'
    sed -i "/\${SOCKS_USERNAME}/s/login/\/\/\ login/g" redsocks.self.conf
    sed -i "/\${SOCKS_PASSWORD}/s/pass/\/\/\ pass/g" redsocks.self.conf
else
    sed -i "/\${SOCKS_USERNAME}/s/\${SOCKS_USERNAME}/$SOCKS_USERNAME/g" redsocks.self.conf
    sed -i "/\${SOCKS_PASSWORD}/s/\${SOCKS_PASSWORD}/$SOCKS_PASSWORD/g" redsocks.self.conf
fi

redsocks -c redsocks.self.conf 

configureIptables
startServer
