# Runtime Examples for RouterOS Docker Image

<!-- GitHub Copilot: new runtime examples (Docker Compose profiles, Podman, Kubernetes, Nomad)
     must follow security rules from .github/copilot-instructions.md and stay lab-only. -->

**WARNING**: All examples in this directory are designed for **lab and testing environments only**. Do not deploy in production or expose directly to the public internet.

## Overview

This directory contains example configurations for running the RouterOS Docker image across different container runtimes and orchestration platforms. All examples follow security best practices for lab environments while clearly documenting security implications.

## Available Examples

### Docker Compose Profiles

- **[docker-compose.lab.yml](docker-compose.lab.yml)** - Full-featured lab profile
  - Exposes extensive ports for comprehensive RouterOS testing
  - Includes VPN, IPSec, RADIUS, and all management interfaces
  - Uses privileged mode for maximum functionality
  - Ideal for full-stack RouterOS development and testing

- **[docker-compose.minimal.yml](docker-compose.minimal.yml)** - Minimal security-focused profile
  - Exposes only essential management ports (SSH, Winbox, API)
  - Reduced attack surface for focused testing
  - Commented examples for enabling additional ports as needed
  - Recommended starting point for most lab scenarios

### Podman

- **[podman/routeros-podman.md](podman/routeros-podman.md)** - Podman runtime examples
  - Basic `podman run` commands for minimal and lab configurations
  - Podman Compose compatibility notes
  - Rootless Podman considerations and limitations
  - Troubleshooting guide for common Podman issues

### Kubernetes

- **[kubernetes/routeros-deployment.yaml](kubernetes/routeros-deployment.yaml)** - Kubernetes Deployment
  - Single-replica Deployment with privileged security context
  - Device mounts for KVM and TUN/TAP support
  - Health check configuration using liveness/readiness probes
  - Resource limits and node selector examples

- **[kubernetes/routeros-service.yaml](kubernetes/routeros-service.yaml)** - Kubernetes Service
  - NodePort service for home lab clusters
  - Alternative ClusterIP and LoadBalancer configurations
  - Port forwarding examples
  - Network policy recommendations

### Nomad

- **[nomad/routeros.nomad.hcl](nomad/routeros.nomad.hcl)** - HashiCorp Nomad job
  - Complete Nomad job specification
  - Privileged container configuration
  - Service registration and health checks
  - Resource allocation and constraints
  - Comprehensive deployment notes

## Security Guidelines

All examples in this directory follow these security principles:

### 1. Explicit Security Configurations

All security-sensitive settings are **explicit and commented**:
- `privileged: true` or `privileged = true`
- `cap_add: [NET_ADMIN]`
- Device mounts (`/dev/kvm`, `/dev/net/tun`)
- `hostPath` volumes in Kubernetes
- Security contexts and capabilities

### 2. Minimal Port Exposure

- Default configurations expose only essential management ports
- Additional ports are provided as commented examples
- Each port includes a comment explaining its purpose
- Lab profiles expose more ports for comprehensive testing

### 3. Lab-Only Warnings

Every example file includes:
- Clear warning at the top about lab-only usage
- Explicit statement: "Do not deploy in production"
- Security considerations specific to that runtime
- Recommendations for access control and firewalling

### 4. Runtime-Specific Considerations

Each runtime example addresses:
- Specific security implications of that platform
- Required permissions and capabilities
- Device access requirements
- Network isolation recommendations
- Resource limits appropriate for lab use

## Usage Instructions

### Choosing a Profile

1. **Getting Started**: Use `docker-compose.minimal.yml`
   - Minimal port exposure
   - Good security baseline for labs
   - Easy to extend as needed

2. **Full Testing**: Use `docker-compose.lab.yml`
   - All RouterOS features available
   - Comprehensive port exposure
   - For isolated test networks only

3. **Specific Runtime**: Use the appropriate platform example
   - Podman for Docker alternative
   - Kubernetes for container orchestration
   - Nomad for HashiCorp stack integration

### Security Checklist

Before deploying any example:

- [ ] Confirm you're on an isolated lab network
- [ ] Verify firewall rules restrict access to trusted IPs
- [ ] Understand implications of privileged containers
- [ ] Plan to change default RouterOS credentials immediately
- [ ] Consider whether all exposed ports are necessary
- [ ] Review device mount requirements (/dev/kvm, /dev/net/tun)
- [ ] Document any deviations from examples for your environment

### Customizing Examples

When customizing these examples:

1. **Start from the closest example** to your use case
2. **Make security explicit** - don't hide privileged mode or device mounts
3. **Comment your changes** - explain why additional ports or capabilities are needed
4. **Follow the patterns** - maintain consistency with existing examples
5. **Test thoroughly** - verify RouterOS functionality and security boundaries

## Common Configuration Patterns

### Privileged Mode

Most examples use privileged containers for QEMU/KVM functionality:

```yaml
# Docker Compose
privileged: true

# Kubernetes
securityContext:
  privileged: true

# Nomad
privileged = true
```

**Alternative**: Some setups may work without privileged mode by using specific capabilities and device access, but this is less common and may limit functionality.

### Device Access

Required devices for full RouterOS functionality:

- `/dev/kvm` - Hardware acceleration for QEMU (optional but recommended)
- `/dev/net/tun` - Network tunneling support (required for VPN features)

### Network Capabilities

All examples include `NET_ADMIN` capability for network configuration:

```yaml
# Docker Compose
cap_add:
  - NET_ADMIN

# Kubernetes
securityContext:
  capabilities:
    add: ["NET_ADMIN"]

# Nomad
cap_add = ["NET_ADMIN"]
```

### Health Checks

The healthcheck script is available in all runtimes:

- **Docker/Podman**: Uses `HEALTHCHECK` instruction or compose healthcheck
- **Kubernetes**: Uses `livenessProbe` and `readinessProbe`
- **Nomad**: Uses service check with script

## Troubleshooting

### Container Won't Start

1. Check device availability: `ls -la /dev/kvm /dev/net/tun`
2. Verify privileged mode is allowed by your runtime
3. Check container logs for QEMU errors
4. Ensure sufficient resources are allocated

### Connection Issues

1. Verify container is running and healthy
2. Check port mappings are correct
3. Ensure host firewall allows connections
4. Wait 30-60 seconds for RouterOS to fully boot

### Performance Issues

1. Confirm `/dev/kvm` is accessible (hardware acceleration)
2. Check resource limits aren't too restrictive
3. Monitor host system resources
4. Consider increasing CPU/memory allocation

## Contributing

When adding new examples to this directory:

1. Follow the security guidelines above
2. Include comprehensive comments and warnings
3. Test thoroughly in a lab environment
4. Update this README with your new example
5. Follow patterns from existing examples
6. Submit PR to @ranas-mukminov for review

## Additional Resources

- [Main README](../README.md) - General project documentation
- [GitHub Copilot Instructions](../.github/copilot-instructions.md) - Development guidelines
- [MikroTik RouterOS Documentation](https://help.mikrotik.com/)
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)
- [Kubernetes Security](https://kubernetes.io/docs/concepts/security/)
- [Nomad Security](https://www.nomadproject.io/docs/concepts/security)

## Support

For issues with these examples:
- Open an issue: https://github.com/ranas-mukminov/docker-routeros/issues
- Review existing issues and discussions
- Provide details about your environment and configuration
