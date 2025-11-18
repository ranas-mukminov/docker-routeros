# GitHub Copilot Instructions for docker-routeros

This document provides instructions for GitHub Copilot when working with the docker-routeros repository.

## 1. Repository Overview

This repository provides a Docker image that runs MikroTik RouterOS virtual machine inside QEMU. It is designed for development and testing purposes, particularly for RouterOS API development.

## 2. Code Style and Best Practices

- Use POSIX-compliant shell scripts where possible
- Follow existing code formatting and style conventions
- Keep scripts minimal and focused on their specific purpose
- Add clear comments for complex operations
- Preserve existing functionality when making changes

## 3. Security Guidelines

- This image is for **development and lab usage only**
- Never expose RouterOS ports directly to the public Internet without proper firewalling
- Document security implications of privileged containers and device access
- Use minimal port exposure in examples
- Always make security-sensitive configurations explicit and commented

## 4. Docker Best Practices

- Keep the base image minimal (Alpine-based)
- Use multi-stage builds where appropriate
- Minimize layer count and image size
- Document all EXPOSE directives clearly
- Use environment variables for configurable parameters

## 5. Testing and Validation

- Test changes with actual RouterOS container instances
- Verify VNC, SSH, and API connectivity after changes
- Check that QEMU/KVM functionality remains intact
- Validate health checks work correctly

## 6. Documentation

- Keep README.md up to date with all changes
- Provide clear examples for common use cases
- Document all exposed ports and their purposes
- Include troubleshooting guidance for common issues

## 7. Contributing

- Make minimal, focused changes
- Test thoroughly before submitting
- Follow existing patterns in the codebase
- Update documentation alongside code changes

## 8. Feature extension and other container runtimes (separate PR)

When asked to **add new features and support other container runtimes**, prepare a **separate pull request** (after the baseline hardening/CI PR).

### 8.1 Scope of the "feature + runtimes" pull request

This PR should:

1. Add **health-check support** for RouterOS lab containers:
   - Introduce a small shell script under `scripts/healthcheck.sh` that:
     - checks that the main RouterOS TCP port (e.g. SSH `22` or API `8728`) is reachable from inside the container,
     - exits with non-zero status on failure.
   - Add a `HEALTHCHECK` instruction to `Dockerfile` that calls this script.
   - Optionally add a `healthcheck:` section to `docker-compose.dist.yml` referencing the same logic.

   Constraints:
   - Keep the script POSIX-sh compatible.
   - Do not introduce extra dependencies beyond what is already in the image, unless absolutely necessary.
   - Default behaviour of the image must remain the same; healthcheck is additive.

2. Add **examples for other runtimes** in an `examples/` directory:

   Create new files such as:
   - `examples/docker-compose.lab.yml`  
     - lab profile: many RouterOS ports exposed for testing,
     - clearly commented `privileged: true`, `cap_add: [NET_ADMIN]`, `devices: [/dev/net/tun, /dev/kvm]`.
   - `examples/docker-compose.minimal.yml`  
     - minimal profile: only SSH + Winbox + API,
     - other ports commented out with explanations.

   - `examples/podman/routeros-podman.md` (or `.yaml`)  
     - show `podman run` example,
     - note that `/dev/kvm` and `--privileged` may not be available in all environments,
     - clearly warn that this is **lab only** and must not be exposed directly to the internet.

   - `examples/kubernetes/routeros-deployment.yaml` and `examples/kubernetes/routeros-service.yaml`  
     - a simple `Deployment` with a single pod running the existing image,
     - `securityContext` and `volume`/`hostPath` sections explicitly annotated if `privileged`/`/dev/kvm` are required,
     - `Service` exposing a minimal set of ports (for example SSH + Winbox for lab clusters),
     - add comments that this is for **home lab / testing**, not for production.

   - `examples/nomad/routeros.nomad.hcl`  
     - a basic Nomad job with one task using the image,
     - mark `privileged = true` explicitly and comment risks,
     - expose only necessary ports.

   These examples must:
   - be **non-breaking** (no impact on the main Docker image),
   - be clearly marked as **examples for labs**, not production templates,
   - include short comments about security implications of `privileged`, `hostPath` and device mounts.

3. Update README with **"Other runtimes"** section:

   - Add a section called `## Other runtimes (examples)` that:
     - lists Docker Compose lab/minimal examples,
     - mentions Podman, Kubernetes and Nomad examples under `examples/`,
     - repeats that all such deployments are for controlled lab environments only.
   - Link directly to the example files created above.

4. Keep this PR focused:

   - Do not change core image behaviour beyond the optional `HEALTHCHECK`.
   - Do not refactor unrelated scripts or logic.
   - Do not introduce new build tooling (no Makefiles, bake files, etc.) in this PR.

### 8.2 Security rules for extended runtimes

For all new runtime examples:

- Always make `privileged: true`, `hostPath:`, `devices:` and `cap_add:` **explicit and commented**.
- Prefer exposing the **minimum** set of ports to the host/cluster.
- Add a warning comment in each example file, e.g.:

  ```yaml
  # WARNING: This manifest runs a privileged RouterOS lab VM.
  # Do not deploy in production or expose directly to the public internet.
  ```

- Never add cloud-provider-specific annotations or features unless requested.

### 8.3 Pull request requirements for this "feature + runtimes" PR

When preparing this PR:
1. Use a clear title, for example:
   `Add healthcheck and Podman/Kubernetes/Nomad examples for docker-routeros`
2. In the PR description, list the changes in this order:
   1. healthcheck script + Dockerfile/compose integration,
   2. new examples under examples/ (Docker Compose, Podman, Kubernetes, Nomad),
   3. README "Other runtimes" section.
3. Keep commits logically grouped:
   - commit 1: add scripts/healthcheck.sh + Dockerfile/compose healthcheck,
   - commit 2: add examples under examples/,
   - commit 3: README updates and small doc fixes.
4. Assume the PR will be reviewed and merged by @ranas-mukminov.
   - Changes should be easy to audit from a security perspective.
   - No surprise changes outside the described scope.
