This is the repository of the Headscale/Caddy/Cloudflare proxy, a docker image that enables easy sharing of docker HTTP services over your own Headscale network via HTTPS.

Please visit [the original repository](https://github.com/hollie/tailscale-caddy-proxy) for the original rationale and additional explanations. This fork adds support for Cloudflare-based DNS challenges so MagicDNS-hosts will automatically request and use SSL certificates from Let's Encrypt.

# Parameters and storage

The docker image takes as input parameters:

* `TS_HOSTNAME` : the name of the host on the Tailscale network

* `TS_TAILNET`: the **full** name of your tailnet. The original container omitted the `.ts.net` suffix, but since Headscale works differently you need to specify your full MagicDNS base domain.

* `CADDY_TARGET`: the name and port of the service you want to connect to.

* `TS_EXTRA_ARGS`: Additional arguments supplied to `tailscale up`. This ususally needs to contain your Headscale URL in the form of `--login-server https://your-headscale.domain.com`

* `CLOUDFLARE_DNS_API_TOKEN`: A Cloudflare API token that is able to modify DNS entries for your configured MagicDNS domain.

You also want to declare a permanent volume to store the Tailscale credentials so that those survive a rebuild of the container. The Tailscale configuration is located in the folder `/var/lib/tailscale` in the container.

# Practical use

Say you have an example service called 'whoami' that is a simple webserver listening on port 80 and you want to expose it via Headscale.

We want to keep the network traffic between this container and the Headscale proxy separated from the default docker network, so declare a network. Attach the whoami container to that network. Declare a container of the `dkoch/headscale-caddy-cloudflare-proxy` image next to it, attach it also to the same network and enter the right environmental parameters for the Headscale and Caddy configuration.

The resulting docker compose file looks like:

```docker
networks:
  headscale_proxy_example:
    external: false

volumes:
  headscale-whoami-state:

services:
  whoami:
    image: traefik/whoami
    networks:
     - headscale_proxy_example

  headscale-whoami-proxy:
    image: foo
    volumes:
      # Persist the tailscale state directory so login state etc. is retained between restarts.
      - headscale-whoami-state:/var/lib/tailscale
    environment:
      # Hostname you want this instance to have on your headscale network
      - TS_HOSTNAME=headscale-example
      # Your tailnet name including the full top level domain(s).
      - TS_TAILNET=vpn.dkoch.org
      # Target service and port
      - CADDY_TARGET=whoami:80
      # Optional extra arguments to pass when starting tailscale. Use this to include your Headscale login URL.
      - TS_EXTRA_ARGS=--login-server https://your-headscale.domain.com
      # Cloudflare API token that is able to modify DNS entries for your configured MagicDNS domain.
      - CLOUDFLARE_DNS_API_TOKEN=your_cloudflare_token_here
    restart: on-failure
    init: true
    networks:
     - headscale_proxy_example
```

Run `docker-compose up` and visit the link that is printed in the terminal to authenticate the machine to your Tailscale network. Disable key expiry via the Tailscale settings page for this host and restart the containers with `docker compose up -d`.

All set! Now you can access the host via the full Tailscale domainname (including the tailnet-XXX.ts.net).

# Acknowledgements

Thank you so much to hollie / Lieven Hollevoet for the [original implementation](https://github.com/hollie/tailscale-caddy-proxy)!

Thanks to lpasselin for his [example code](https://github.com/lpasselin/tailscale-docker) that shows how to extend the default Tailscale image.
