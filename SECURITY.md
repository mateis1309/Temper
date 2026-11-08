# Security Policy

Temper configures security-sensitive settings (SSH, firewall, kernel parameters), so reports of unsafe defaults or lockout risks are taken seriously.

## Reporting a vulnerability

Please **do not** open a public issue. Use GitHub's private reporting instead:
**Security tab -> Report a vulnerability**.

Include the affected file or role, what you expected, what happened, and steps to reproduce. You can expect an initial response within 7 days.

## Scope

In scope: insecure defaults in the roles or Terraform modules, ways the playbooks can lock an operator out or weaken a host, and secrets leaking into generated files or state.

Out of scope: vulnerabilities in Terraform, Ansible, libvirt, or upstream OS packages (report those upstream), and hardening that is simply absent (open a feature request).

## Supported versions

Only the latest release on `main` receives fixes.
