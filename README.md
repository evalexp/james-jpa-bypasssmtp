# James-JPA-Bypass-SMTP

## About

Since most of the VPS providers banned 25 SMTP service port, building your own email service has become increasingly difficult.

In this project, you will see how I solve the problem of 25 SMTP port blocking.

## Requirement

- A proxy server which allows 25 SMTP port outbound
- A high performance server

## Deploy

### Proxy Server

Deploy a socks5 proxy on that server, make sure to apply a strong enough password to ensure security.

### Mail Service Server

Clone this repo, and build it :

```bash
docker build . -t james:jpa-bypasssmtp-3.7.2
```

I do recommand deploy it using `docker-compose`:

```yaml
version: "3"

services:
  james:
    image: james:jpa-bypasssmtp-3.7.2
    restart: always
    container_name: james
    hostname: mail.domain
    environment:
      - SOCKS_HOST=185.22.153.152
      - SOCKS_PORT=10808
      - SOCKS_USERNAME=username
      - SOCKS_PASSWORD=password
    ports:
      - "25:25"
      - "465:465"
      - "587:587"
      - "143:143"
      - "993:993"
    volumes:
      - "./keystore:/root/conf/keystore"
    cap_add:
      - NET_ADMIN
      - NET_RAW
    logging:
      options:
        max-size: "5m"
```
> Notice: `NET_ADMIN` and `NET_RAW` is required.

## Other mail server

Please view `entrypoint.sh` first, which show how I set a proxy without configure `James`.

First, install `redsocks` and `iptables`, configure `iptables` to redirect port `25` to port `12345` served by `redsocks`, and configure `redsocks` so that the service could connect to port 25 SMTP service normally.

So, if you want to use other mail service like iRedMail, you can refer to this.