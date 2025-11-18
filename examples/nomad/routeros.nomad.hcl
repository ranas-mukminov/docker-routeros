# WARNING: This Nomad job runs a privileged RouterOS lab VM.
# Do not deploy in production or expose directly to the public internet.
# This is for home lab / testing environments only.

job "routeros" {
  # Specify the datacenter where this job should run
  datacenters = ["dc1"]
  
  # Type: service jobs run until explicitly stopped
  type = "service"
  
  # Only run one instance of RouterOS
  # RouterOS is stateful and should not be scaled horizontally
  group "routeros" {
    count = 1
    
    # Restart policy - be conservative with restarts
    restart {
      attempts = 3
      interval = "10m"
      delay    = "30s"
      mode     = "fail"
    }
    
    # Network configuration
    network {
      # SSH - Primary management interface
      port "ssh" {
        static = 22
        to     = 22
      }
      
      # Winbox - MikroTik GUI management
      port "winbox" {
        static = 8291
        to     = 8291
      }
      
      # RouterOS API (unencrypted)
      port "api" {
        static = 8728
        to     = 8728
      }
      
      # RouterOS API-SSL (encrypted) - prefer this over unencrypted
      port "api_ssl" {
        static = 8729
        to     = 8729
      }
      
      # HTTP - Webfig (commented out by default for security)
      # port "http" {
      #   static = 80
      #   to     = 80
      # }
      
      # VNC - Console access (commented out by default)
      # port "vnc" {
      #   static = 5900
      #   to     = 5900
      # }
    }
    
    # Task definition
    task "routeros" {
      driver = "docker"
      
      config {
        image = "evilfreelancer/docker-routeros:latest"
        
        # WARNING: privileged mode grants extended permissions
        # Required for QEMU/KVM functionality
        # Only use in trusted, isolated lab environments
        privileged = true
        
        # Port mappings
        ports = [
          "ssh",
          "winbox",
          "api",
          "api_ssl"
        ]
        
        # Add NET_ADMIN capability for network configuration
        cap_add = ["NET_ADMIN"]
        
        # Mount host devices for KVM acceleration and network tunneling
        # WARNING: These device mounts require privileged mode
        devices = [
          {
            host_path      = "/dev/kvm"
            container_path = "/dev/kvm"
          },
          {
            host_path      = "/dev/net/tun"
            container_path = "/dev/net/tun"
          }
        ]
        
        # Optional: mount volume for persistent data
        # volumes = [
        #   "/opt/routeros-data:/routeros"
        # ]
      }
      
      # Resource allocation
      # Adjust based on your lab requirements and available resources
      resources {
        cpu    = 1000  # MHz
        memory = 1024  # MB
      }
      
      # Health check using the built-in healthcheck script
      # Nomad will restart the task if health checks fail
      service {
        name = "routeros"
        port = "ssh"
        
        tags = [
          "lab",
          "routeros",
          "mikrotik"
        ]
        
        check {
          type     = "script"
          name     = "routeros-health"
          command  = "/routeros_source/healthcheck.sh"
          interval = "30s"
          timeout  = "10s"
          
          check_restart {
            limit           = 3
            grace           = "30s"
            ignore_warnings = false
          }
        }
      }
      
      # Environment variables (optional)
      # env {
      #   HEALTHCHECK_PORT = "22"
      #   HEALTHCHECK_TIMEOUT = "5"
      # }
    }
  }
}

# Nomad deployment notes:
#
# 1. PRIVILEGED MODE:
#    This job uses privileged = true which is required for QEMU/KVM.
#    Ensure your Nomad cluster allows privileged containers:
#    - Set plugin.docker.config.allow_privileged = true in Nomad client config
#    - Only use on trusted Nomad clients in isolated environments
#
# 2. DEVICE ACCESS:
#    The job requires access to /dev/kvm and /dev/net/tun on the host.
#    Ensure these devices exist on your Nomad clients:
#    - Check: ls -la /dev/kvm /dev/net/tun
#    - KVM may not be available in VMs or cloud instances without nested virt
#
# 3. NODE CONSTRAINTS:
#    You may want to add constraints to ensure the job runs on nodes with KVM:
#    
#    constraint {
#      attribute = "${attr.kernel.name}"
#      value     = "linux"
#    }
#    
#    constraint {
#      attribute = "${attr.cpu.arch}"
#      value     = "amd64"
#    }
#
# 4. NETWORK MODE:
#    This job uses bridge networking. For host networking:
#    
#    network {
#      mode = "host"
#    }
#    
#    WARNING: Host networking exposes all container ports directly on the host.
#
# 5. RESOURCE ALLOCATION:
#    Adjust CPU and memory based on your RouterOS workload:
#    - Minimum: 512MB RAM, 500 MHz CPU
#    - Recommended: 1024MB RAM, 1000 MHz CPU
#    - Heavy load: 2048MB RAM, 2000 MHz CPU
#
# 6. PERSISTENT STORAGE:
#    To persist RouterOS configuration, uncomment the volumes section
#    and ensure the host path exists with proper permissions.
#
# 7. SERVICE DISCOVERY:
#    The task registers with Consul (if configured) under the name "routeros".
#    You can use Consul DNS to access: routeros.service.consul
#
# 8. SECURITY CONSIDERATIONS:
#    - Never expose this job on public-facing Nomad clients
#    - Use Nomad ACLs to restrict who can submit/modify this job
#    - Consider using Nomad namespaces to isolate lab workloads
#    - Implement firewall rules on the host to restrict access
#    - Change RouterOS default credentials immediately after deployment
#
# 9. DEPLOYMENT:
#    Deploy this job with:
#    nomad job run routeros.nomad.hcl
#    
#    Monitor the job:
#    nomad job status routeros
#    nomad alloc logs <alloc-id>
#    
#    Stop the job:
#    nomad job stop routeros
#
# 10. ACCESSING ROUTEROS:
#     Once running, access RouterOS via:
#     - SSH: ssh admin@<nomad-client-ip> -p 22
#     - Winbox: Connect to <nomad-client-ip>:8291
#     - API: Connect to <nomad-client-ip>:8728 or :8729
#     
#     Default credentials: username=admin, password=<blank>
