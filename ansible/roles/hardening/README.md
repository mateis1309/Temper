# hardening

SSH, UFW, fail2ban, unattended upgrades, sysctl, log retention.

Set `hardening_ssh_port` to change the SSH port; it is applied to sshd, UFW and fail2ban. Debian/Ubuntu only. Refuses to run when Ansible connects as root. Tags: `ssh`, `firewall`, `updates`, `fail2ban`, `sysctl`, `logging`.

## Variables (defaults/main.yml)

| Variable | Default |
|----------|---------|
| `hardening_ssh_max_auth_tries` | `3` |
| `hardening_ssh_login_grace_time` | `30` |
| `hardening_ssh_client_alive_interval` | `300` |
| `hardening_ssh_client_alive_count_max` | `2` |
| `hardening_ssh_allow_tcp_forwarding` | `false` |
| `hardening_ssh_port` | `22` |
| `hardening_sshd_binary` | `/usr/sbin/sshd` |
| `hardening_ssh_service` | `ssh` |
| `hardening_ufw_enabled` | `true` |
| `hardening_ufw_allowed_tcp_ports` | `[]` |
| `hardening_unattended_upgrades` | `true` |
| `hardening_auto_reboot` | `false` |
| `hardening_fail2ban_enabled` | `true` |
| `hardening_fail2ban_bantime` | `3600` |
| `hardening_fail2ban_findtime` | `600` |
| `hardening_fail2ban_maxretry` | `5` |
| `hardening_sysctl_enabled` | `true` |
| `hardening_sysctl` | `(list/map, see defaults)` |
| `hardening_journald_system_max_use` | `500M` |
| `hardening_journald_max_retention` | `1month` |
| `hardening_app_log_glob` | `/var/log/apps/*.log` |
| `hardening_app_log_rotate_count` | `8` |

Override any of these in `group_vars`, `host_vars` or `-e`.
