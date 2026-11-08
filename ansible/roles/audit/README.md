# audit

Read-only compliance checks with JSON reports.

Containers cannot verify UFW, sysctl or fail2ban; disable those groups with the `audit_check_*` variables.

## Variables (defaults/main.yml)

| Variable | Default |
|----------|---------|
| `audit_fail_on_findings` | `true` |
| `audit_report_dir` | `"{{ playbook_dir }}/../reports"` |
| `audit_check_firewall` | `true` |
| `audit_check_sysctl` | `true` |
| `audit_check_fail2ban` | `true` |
| `audit_sshd_binary` | `/usr/sbin/sshd` |
| `audit_ssh_port` | `"{{ hardening_ssh_port | default(22) }}"` |

Override any of these in `group_vars`, `host_vars` or `-e`.
