# alpine-nix

A docker container that compiles and installs nix on Alpine Linux.

## Building

```bash
# Move to parent directory
cd ..

# Build the docker images
./build.sh
```

## Verification

```bash
docker run -it --rm dkubb/alpine-nix
```
