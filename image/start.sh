#!/bin/ash
trap 'kill -TERM $PID' TERM INT

echo "This is Tailscale-Caddy-proxy version"
tailscale --version

if [ ! -z "$SKIP_CADDYFILE_GENERATION" ] ; then
   echo "Skipping Caddyfile generation as requested via environment"
else
   echo "Building Caddy configfile"

   mkdir -p /etc/caddy

   echo $TS_HOSTNAME'.'$TS_TAILNET > /etc/caddy/Caddyfile
   echo 'reverse_proxy' $CADDY_TARGET >> /etc/caddy/Caddyfile

   if [ ! -z "$CLOUDFLARE_DNS_API_TOKEN" ] ; then
      echo "Note: Using Cloudflare-based DNS challenge for Let's Encrypt."

cat >> /etc/caddy/Caddyfile <<EOL
tls {
  dns cloudflare ${CLOUDFLARE_DNS_API_TOKEN}
}
EOL

      caddy fmt /etc/caddy/Caddyfile --overwrite
   fi
fi

echo "Starting Caddy"
caddy start --config /etc/caddy/Caddyfile

echo "Starting Tailscale"

export TS_EXTRA_ARGS=--hostname="${TS_HOSTNAME} ${TS_EXTRA_ARGS}"
echo "Note: set TS_EXTRA_ARGS to " $TS_EXTRA_ARGS
/usr/local/bin/containerboot
