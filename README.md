# Temper

[![CI](https://github.com/mateis1309/temper/actions/workflows/ci-lint.yml/badge.svg)](https://github.com/mateis1309/temper/actions/workflows/ci-lint.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

**Forge VMs. Temper them.** A declarative infrastructure and hardening pipeline for rapid, repeatable virtualization environments.
**Terraform** provisions VMs on KVM/libvirt; **Ansible** applies a security baseline, deploys services and audits the result.
No cloud account required: everything runs on a Linux workstation or homelab host.

## Architecture

```text
   terraform apply                              ansible-playbook site.yml
 ┌─────────────────────────────────┐          ┌──────────────────────────────────┐
 │ modules/networking  NAT network │          │ baseline   common role           │
 │ modules/compute     VMs + disks │──hosts──▶│ hardening  SSH, UFW, fail2ban... │
 │ cloud-init          admin user  │  .ini    │ services   nginx on `web` group  │
 └─────────────────────────────────┘          │ audit      read-only checks      │
        writes ansible/inventory/hosts.ini    └──────────────────────────────────┘
                                                        │
                                                        ▼
                                          hardened, verified nodes
                                          + reports/<host>.json
```

Terraform renders an Ansible inventory from the nodes it creates, grouped by each node's `role`. That file is the only hand-off between the two tools.

## Features

- **Modular Terraform**: separate `networking` and `compute` modules; nodes are a single typed map, so scaling is one line.
- **Hardening role**: key-only SSH with root login disabled, UFW (default deny, rate-limited SSH), fail2ban, unattended security upgrades, kernel sysctl tuning, persistent size-capped journald and logrotate.
- **Lockout protection**: the sshd config is validated with `sshd -t` and rolled back on failure; the role refuses to run when connecting as root; SSH is allowed in UFW before the default policy flips to deny.
- **Service deployment**: example `nginx` role with security headers, config validation and an HTTP smoke test.
- **Compliance audit**: read-only `audit` role verifies the hardening actually took effect, writes a JSON report per host and can fail the run.
- **Idempotent**: re-running the playbooks should report no changes.

## Prerequisites

| Tool | Version | Needed for |
|------|---------|------------|
| Terraform | >= 1.5 | `make up`, `make lint` |
| Ansible (ansible-core) | >= 2.16 | `make deploy`, `make test` |
| libvirt + KVM | running `libvirtd`, a storage pool named `default` | `make up` |
| `genisoimage` or `mkisofs` | any | cloud-init ISO creation (`make up`) |
| SSH key pair | e.g. `ssh-keygen -t ed25519` | `make up` fails without the public key |
| Docker | any recent | `make test` (Molecule) |
| tflint, yamllint, ansible-lint | see `requirements-dev.txt` | `make lint` |

Your user needs access to `qemu:///system` (typically membership in the `libvirt` group). AppArmor or SELinux can block a non-standard storage pool path. Targets must be Debian/Ubuntu images with cloud-init (the default is Ubuntu 22.04). Linux hosts only; macOS and WSL are not supported for `make up`.

## Quick start

```bash
git clone https://github.com/mateis1309/temper.git
cd temper

[ -f ~/.ssh/id_ed25519.pub ] || ssh-keygen -t ed25519   # key used for the admin user
cp terraform/terraform.tfvars.example terraform/terraform.tfvars   # edit as needed

make init        # terraform init
make up          # create network + VMs, write ansible/inventory/hosts.ini
                 # first run downloads the Ubuntu cloud image and waits for DHCP leases (a few minutes)
make deps        # install Ansible collections
make ping        # verify SSH connectivity
make deploy      # baseline -> hardening -> services -> audit
```

Or without `make`:

```bash
cd terraform && terraform init && terraform apply
cd ../ansible && ansible-galaxy collection install -r requirements.yml
ansible-playbook playbooks/site.yml
```

Tear everything down with `make down`.

## Configuration

Terraform inputs (see `terraform/variables.tf`):

| Variable | Default | Purpose |
|----------|---------|---------|
| `nodes` | 2x web, 1x utility | Map of name to `{ role, vcpu, memory_mb, disk_gb }` |
| `network_cidr` | `10.10.10.0/24` | Isolated NAT network |
| `base_image_source` | Ubuntu 22.04 cloud image | URL or path of a qcow2 image |
| `admin_user` | `ops` | User created by cloud-init, used by Ansible |
| `libvirt_uri` | `qemu:///system` | Use `qemu+ssh://user@host/system` for a remote host |
| `pool_name` | `default` | Existing libvirt storage pool |
| `name_prefix` | `temper` | Prefix for all libvirt objects |
| `network_domain` | `lab.local` | DNS domain of the libvirt network |
| `ssh_public_key_path` | `~/.ssh/id_ed25519.pub` | Key authorized for the admin user |
| `ssh_private_key_path` | `~/.ssh/id_ed25519` | Key written into the generated inventory |
| `generate_inventory` | `true` | Write `ansible/inventory/hosts.ini` |

Each role has a README listing its variables: [common](ansible/roles/common/README.md), [hardening](ansible/roles/hardening/README.md), [nginx](ansible/roles/nginx/README.md), [audit](ansible/roles/audit/README.md). Ansible tunables live in `roles/hardening/defaults/main.yml`; override per group in `ansible/inventory/group_vars/`. For example `web.yml` opens port 80 on web nodes via `hardening_ufw_allowed_tcp_ports`.

Run a single concern with tags: `ansible-playbook playbooks/hardening.yml --tags ssh,firewall`.

## Troubleshooting

- **`ip = null` / "no IPv4 lease"**: the VM has not got a DHCP lease yet. Wait a minute and run `make up` again.
- **Terraform cannot read the public key**: create one with `ssh-keygen -t ed25519` or set `ssh_public_key_path`.
- **Permission denied on `qemu:///system`**: add your user to the `libvirt` group and log in again.
- **Locked out after hardening**: the role keeps your SSH port reachable in UFW and validates sshd before restarting. If you changed `hardening_ssh_port`, point Ansible at the new port. Otherwise use `virsh console <vm>` to recover.
- **Host key warnings**: `ansible.cfg` uses `StrictHostKeyChecking=accept-new` (trust on first use), which suits a lab. Tighten it for anything else.
- **Cloud-init admin user has passwordless sudo** (`NOPASSWD:ALL`): fine for a lab, review it before wider use.

## Repository layout

```text
terraform/            root module, modules/{networking,compute}, inventory template
ansible/playbooks/    site, baseline, hardening, services, audit
ansible/molecule/     Docker-based role tests (converge, idempotence, verify)
ansible/roles/        common, hardening, nginx, audit
ansible/inventory/    generated hosts.ini + committed group_vars
.github/workflows/    CI: terraform fmt/validate/tflint, yamllint, ansible-lint
```

## Testing

```bash
pip install -r requirements-dev.txt
ansible-galaxy collection install -r ansible/requirements.yml
make lint    # terraform fmt, tflint, yamllint, ansible-lint
make test    # Molecule: needs Docker
```

The Molecule scenario spins up Ubuntu 22.04 and Debian 12 systemd containers, applies the `hardening`, `nginx` and `audit` roles, runs them a second time to prove idempotence, then verifies the result independently (effective `sshd -T` settings, auto-update config, nginx headers). CI runs the same steps on every push and pull request.

**What containers can't prove:** UFW, fail2ban and kernel sysctls depend on the host kernel, so those parts are switched off in the Molecule scenario (`hardening_ufw_enabled`, `hardening_sysctl_enabled`, `hardening_fail2ban_enabled`). Test them end to end by running `make up && make deploy` against real VMs; the `audit` role then checks them.

See [CONTRIBUTING.md](CONTRIBUTING.md). Please report vulnerabilities privately as described in [SECURITY.md](SECURITY.md), and follow the [Code of Conduct](CODE_OF_CONDUCT.md).

## Limitations and roadmap

- Debian/Ubuntu only (apt, UFW). RHEL-family support (dnf, firewalld) is welcome as a contribution.
- libvirt only. The compute module is tied to libvirt and Debian cloud-init today; other backends (Proxmox, AWS) would need their own module.
- Planned: a VM-based Molecule scenario (libvirt/Vagrant) to cover UFW and sysctl, CIS benchmark mapping for the audit checks, auditd rules.

## Security note

This is a baseline, not a certification. Review the defaults against your own threat model before using them on anything important.

## License

MIT. See [LICENSE](LICENSE).
