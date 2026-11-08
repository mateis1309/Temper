# Changelog

## [0.1.0] - Unreleased
- Fix: inline `ansible_managed` in task content broke converge on ansible-core 2.16.
- Fix: `hardening_ssh_port` is now written to sshd (`Port`) and checked by the audit role.
- Pinned dev tooling and collection ranges; Molecule images overridable via `MOLECULE_*_IMAGE`.
- Role metadata and READMEs; OS-family assertions in `hardening` and `nginx`.
- Terraform: precondition for missing DHCP leases; `optional()` defaults in the compute module.
- Terraform: libvirt/KVM networking and compute modules, generated Ansible inventory.
- Ansible: `common`, `hardening`, `nginx` and `audit` roles.
- CI: terraform fmt/validate/tflint, yamllint, ansible-lint, Molecule.
- Molecule scenario (Docker, Ubuntu 22.04 + Debian 12) with idempotence and verify checks.
