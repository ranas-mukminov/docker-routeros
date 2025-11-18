# RouterOS with Podman

**WARNING**: This example runs a privileged RouterOS lab VM. Do not deploy in production or expose directly to the public internet.

## Overview

This document provides examples for running the RouterOS Docker image using Podman, an alternative container runtime that can run Docker-formatted containers.

## Prerequisites

- Podman installed on your system
- KVM support (optional, but recommended for better performance)
- Root or appropriate user permissions for device access

## Basic Podman Run Example

### Minimal Configuration

Run RouterOS with only essential management ports:

```bash
podman run -d \
  --name routeros \
  --cap-add=NET_ADMIN \
  --device=/dev/net/tun \
  --device=/dev/kvm \
  -p 2222:22 \
  -p 8291:8291 \
  -p 8728:8728 \
  -p 8729:8729 \
  evilfreelancer/docker-routeros:latest
```

### Lab Configuration

Run RouterOS with extensive port exposure for testing:

```bash
podman run -d \
  --name routeros-lab \
  --cap-add=NET_ADMIN \
  --device=/dev/net/tun \
  --device=/dev/kvm \
  -p 22:22 \
  -p 23:23 \
  -p 80:80 \
  -p 443:443 \
  -p 8291:8291 \
  -p 5900:5900 \
  -p 8728:8728 \
  -p 8729:8729 \
  -p 1194:1194 \
  -p 1194:1194/udp \
  -p 1701:1701 \
  -p 1723:1723 \
  -p 500:500/udp \
  -p 4500:4500/udp \
  evilfreelancer/docker-routeros:latest
```

## Podman Compose Example

You can also use `podman-compose` with the existing Docker Compose files:

```bash
# Using minimal profile
podman-compose -f examples/docker-compose.minimal.yml up -d

# Using lab profile
podman-compose -f examples/docker-compose.lab.yml up -d
```

## Rootless Podman Considerations

### Important Limitations

When running Podman in rootless mode, certain features may not be available:

1. **KVM Access**: `/dev/kvm` typically requires root access. Without it, RouterOS will run slower (pure emulation instead of hardware acceleration).

2. **TUN Device**: `/dev/net/tun` may not be accessible in rootless mode, which could affect VPN functionality.

3. **NET_ADMIN Capability**: Some network operations may be restricted.

### Rootless Example

For rootless Podman (without KVM and with limited capabilities):

```bash
podman run -d \
  --name routeros-rootless \
  -p 2222:22 \
  -p 8728:8728 \
  -p 8729:8729 \
  evilfreelancer/docker-routeros:latest
```

**Note**: This will be significantly slower as it runs without KVM acceleration.

## Managing the Container

### Start/Stop/Restart

```bash
# Start the container
podman start routeros

# Stop the container
podman stop routeros

# Restart the container
podman restart routeros
```

### View Logs

```bash
podman logs routeros

# Follow logs in real-time
podman logs -f routeros
```

### Access Container Shell

```bash
podman exec -it routeros /bin/bash
```

### Check Health Status

If the image includes health checks:

```bash
podman healthcheck run routeros
```

## Connecting to RouterOS

Once the container is running:

- **SSH**: `ssh admin@localhost -p 2222` (password: blank on first start)
- **Winbox**: Connect to `localhost:8291`
- **API**: Connect to `localhost:8728` or `localhost:8729` (SSL)
- **VNC**: Use VNC client to connect to `localhost:5900` (if exposed)

## Security Considerations

### Lab Environment Only

This container configuration is designed for **lab and testing purposes only**:

- Never expose these ports to the public internet
- Use firewall rules to restrict access to trusted IP addresses
- Change default RouterOS credentials immediately after first login
- Consider using a dedicated isolated network for testing

### Privileged Mode

The `--privileged` flag is **NOT used** in these examples, but some RouterOS features may require it. If you need privileged mode:

```bash
podman run -d \
  --name routeros-privileged \
  --privileged \
  -p 2222:22 \
  -p 8728:8728 \
  evilfreelancer/docker-routeros:latest
```

**WARNING**: Privileged containers have significantly elevated permissions. Only use in trusted, isolated environments.

## Persistent Storage

To persist RouterOS configuration across container restarts:

```bash
podman run -d \
  --name routeros \
  --cap-add=NET_ADMIN \
  --device=/dev/net/tun \
  --device=/dev/kvm \
  -v ./routeros-data:/routeros \
  -p 2222:22 \
  -p 8728:8728 \
  evilfreelancer/docker-routeros:latest
```

## Troubleshooting

### Container Won't Start

1. Check if KVM is available: `ls -la /dev/kvm`
2. Verify TUN device: `ls -la /dev/net/tun`
3. Check Podman logs: `podman logs routeros`

### Performance Issues

- Ensure KVM is available and accessible
- Consider allocating more CPU/memory resources
- Check host system resources with `podman stats`

### Connection Refused

- Verify the container is running: `podman ps`
- Check port mappings: `podman port routeros`
- Ensure host firewall allows the connections
- Wait for RouterOS to fully boot (may take 30-60 seconds)

## Additional Resources

- [Podman Documentation](https://docs.podman.io/)
- [Podman Compose](https://github.com/containers/podman-compose)
- [MikroTik RouterOS Documentation](https://help.mikrotik.com/)

## Support

For issues specific to this Docker image, please report them at:
https://github.com/ranas-mukminov/docker-routeros/issues
