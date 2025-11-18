# Mikrotik RouterOS in Docker

This project provides a Docker image that runs a MikroTik RouterOS virtual machine inside QEMU.

It is designed for development and testing, especially when working with the RouterOS API
or libraries such as [routeros-api-php](https://github.com/EvilFreelancer/routeros-api-php).

This repository is a fork of [EvilFreelancer/docker-routeros](https://github.com/EvilFreelancer/docker-routeros),
maintained by [Ranas Mukminov](https://github.com/ranas-mukminov).

[English] | [Русский](README.ru.md)

## Use cases

- Local lab for RouterOS API development
- CI/unit tests against a real RouterOS instance
- Quick RouterOS sandbox without running a full VM or hardware

> For production-like, multi-device network labs consider
> [VR Network Lab](https://github.com/vrnetlab/vrnetlab) instead.

## Getting started

> **GitHub Copilot**: When extending this repo, prefer adding **examples** for other runtimes
> (Docker Compose profiles, Podman, Kubernetes, Nomad) under the `examples/` directory
> instead of changing core image behaviour.

### Pull image from Docker Hub

```bash
docker pull evilfreelancer/docker-routeros
docker run -d \
  -p 2222:22 \
  -p 8728:8728 \
  -p 8729:8729 \
  -p 5900:5900 \
  -ti evilfreelancer/docker-routeros
```

This starts a RouterOS instance with SSH, API, API-SSL and VNC access.

### docker-compose example

See [docker-compose.dist.yml](docker-compose.dist.yml) for a full example:

```yml
version: "3.9"

services:
  routeros:
    image: evilfreelancer/docker-routeros:latest
    restart: unless-stopped
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun
      - /dev/kvm
    ports:
      - "2222:22"
      - "23:23"
      - "80:80"
      - "5900:5900"
      - "8728:8728"
      - "8729:8729"
```

### Build from source

```bash
git clone https://github.com/ranas-mukminov/docker-routeros.git
cd docker-routeros
docker build . --tag ros
docker run -d \
  -p 2222:22 \
  -p 8728:8728 \
  -p 8729:8729 \
  -p 5900:5900 \
  -ti ros
```

After starting the container you can:
- Connect via VNC on port 5900 to access the RouterOS console.
- Connect via SSH on port 2222.

### Creating a Custom Dockerfile

You can easily create your own Dockerfile to include custom scripts or
configurations. The Docker image supports various tags, which are listed
[here](https://hub.docker.com/r/evilfreelancer/docker-routeros/tags/).
By default, the `latest` tag is used if no tag is specified.

```dockerfile
FROM evilfreelancer/docker-routeros
ADD ["your-scripts.sh", "/"]
RUN /your-scripts.sh
```

## Exposed ports

The RouterOS VM exposes multiple ports, commonly mapped from the container:
- **Defaults**: 21, 22, 23, 80, 443, 8291, 8728, 8729
- **IPSec**: 50, 51, 500/udp, 4500/udp
- **OpenVPN**: 1194/tcp, 1194/udp
- **L2TP**: 1701
- **PPTP**: 1723

Adjust the port mappings in `docker run` or `docker-compose` according to your needs.

## Other runtimes (examples)

This repository includes example configurations for running RouterOS across different container runtimes and orchestration platforms. All examples are designed for **controlled lab environments only** and should not be deployed in production or exposed to the public internet.

### Docker Compose Profiles

We provide multiple Docker Compose profiles for different use cases:

- **[examples/docker-compose.lab.yml](examples/docker-compose.lab.yml)** - Full-featured lab profile
  - Exposes extensive ports for comprehensive RouterOS testing
  - Includes VPN, IPSec, RADIUS, and all management interfaces
  - Ideal for development and full-stack testing scenarios

- **[examples/docker-compose.minimal.yml](examples/docker-compose.minimal.yml)** - Minimal security-focused profile
  - Exposes only essential management ports (SSH, Winbox, API)
  - Reduced attack surface for focused testing
  - Recommended starting point for most lab scenarios

### Podman

For those who prefer Podman as a Docker alternative:

- **[examples/podman/routeros-podman.md](examples/podman/routeros-podman.md)**
  - Complete guide for running RouterOS with Podman
  - Includes rootless Podman considerations and limitations
  - Compatible with `podman-compose` for multi-container setups

**Note**: `/dev/kvm` access and full hardware acceleration may be limited in rootless Podman configurations.

### Kubernetes

For container orchestration in home lab clusters:

- **[examples/kubernetes/routeros-deployment.yaml](examples/kubernetes/routeros-deployment.yaml)** - Kubernetes Deployment
  - Includes privileged security context for QEMU/KVM
  - Device mounts for hardware acceleration
  - Health checks using liveness and readiness probes

- **[examples/kubernetes/routeros-service.yaml](examples/kubernetes/routeros-service.yaml)** - Kubernetes Service
  - NodePort configuration for lab cluster access
  - Alternative LoadBalancer and ClusterIP examples
  - Port forwarding instructions

**Note**: This deployment uses privileged containers and may be blocked by Pod Security Standards. Only deploy in lab namespaces with appropriate policies.

### Nomad

For HashiCorp Nomad orchestration:

- **[examples/nomad/routeros.nomad.hcl](examples/nomad/routeros.nomad.hcl)**
  - Complete Nomad job specification
  - Service registration and health checks
  - Resource allocation and node constraints
  - Integration with Consul for service discovery

**Note**: Requires Nomad configuration to allow privileged containers (`plugin.docker.config.allow_privileged = true`).

### Security Considerations for Alternative Runtimes

All runtime examples follow these security principles:

- **Explicit configuration**: All uses of `privileged`, `hostPath`, `devices`, and `cap_add` are clearly marked and commented
- **Minimal ports**: Default configurations expose only essential management ports
- **Lab-only warnings**: Every example includes clear warnings about lab-only usage
- **Access control**: Recommendations for firewall rules and network isolation

For more details, see the [examples/README.md](examples/README.md) which includes:
- Comprehensive security guidelines for each runtime
- Troubleshooting guides
- Configuration customization patterns
- Best practices for lab deployments

## Security notes

- This image is meant for **development and lab usage**.
- **Do not expose RouterOS ports directly to the public Internet** without proper firewalling.
- If you use `--device /dev/kvm`, ensure only trusted users have access to the host.

## Troubleshooting

### QEMU fails to start

- Verify KVM availability: `/dev/kvm` exists and permissions are correct.
- Ensure `NET_ADMIN` capability and `/dev/net/tun` device are available.

### VNC does not connect

- Check port mapping (5900).
- Ensure no other service already uses 5900 on the host.

### Container restarts repeatedly

- Check logs with `docker logs <container_id>`.
- Verify that RouterOS image downloaded successfully during build.

## Links

For more insights into Docker and virtualization technologies
related to RouterOS and networking, explore the following resources:

* [Mikrotik RouterOS in Docker using Qemu](https://habr.com/ru/articles/498012/) - An article on Habr that provides a guide on setting up Mikrotik RouterOS in Docker using Qemu.
* [RouterOS API Client](https://github.com/EvilFreelancer/routeros-api-php) - GitHub repository for the RouterOS API PHP library, useful for interfacing with MikroTik devices.
* [VR Network Lab](https://github.com/vrnetlab/vrnetlab) - A project for running network equipment in Docker containers, recommended for production-level RouterOS simulations.
* [qemu-docker](https://github.com/joshkunz/qemu-docker) - A resource for integrating QEMU with Docker, enabling virtual machine emulation within containers.
* [QEMU/KVM on Docker](https://github.com/ennweb/docker-kvm) - Demonstrates using QEMU/KVM virtualization within Docker containers for improved performance.

## License

Licensed under the MIT License. See [LICENSE](LICENSE) for details.
