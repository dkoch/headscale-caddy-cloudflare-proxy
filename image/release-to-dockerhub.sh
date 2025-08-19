set -ex
# SET THE FOLLOWING VARIABLES
# docker hub username
USERNAME=dieterkoch
# image name
IMAGE=headscale-caddy-cloudflare-proxy
# platforms
# PLATFORM=linux/arm64,linux/amd64,linux/arm/v7
PLATFORM=linux/amd64
# bump version
version=`awk -F "=" '/TAILSCALE_VERSION=/{print $NF}' Dockerfile`
echo "Building version: $version"
# run build
docker buildx build --platform $PLATFORM -t $USERNAME/$IMAGE:latest -t $USERNAME/$IMAGE:$version --push .
