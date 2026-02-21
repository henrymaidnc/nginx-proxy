# nginx-proxy

Shared reverse proxy for all projects on this server.  
Owns ports **80** and **443**. Routes traffic by subdomain to each app's host port.

## Current routing

| Domain | Host port | Project |
|---|---|---|
| tsubame-art.econictek.com | 8082 (frontend), 8002 (API) | tsubame-store |
| henry-portfolio.econictek.com | 8083 | my-creative-showcase |

## Start / reload

```bash
# First time
docker compose up -d

# After editing nginx.conf (no rebuild needed — config is mounted as a volume)
docker compose exec nginx nginx -s reload

# Full restart
docker compose restart nginx
```

## Deploy from local to server

```bash
# On local machine — push changes
git push origin main

# On server — pull and reload
cd /srv/nginx-proxy
git pull
docker compose exec nginx nginx -s reload
```

## Adding a new project

1. Deploy the new app on the server, exposing it on a free host port (e.g. 8084).
2. Add two server blocks to `nginx.conf` (HTTP redirect + HTTPS proxy).
3. Obtain an SSL cert: `certbot certonly --webroot -w /var/www/certbot -d new-domain.econictek.com`
4. `git commit` and `git push`, then on the server: `git pull && docker compose exec nginx nginx -s reload`

## SSL certificates

Certs are managed by certbot on the host and mounted read-only at `/etc/letsencrypt`.  
The `certbot_www` volume serves the ACME HTTP-01 challenge at `/.well-known/acme-challenge/`.
