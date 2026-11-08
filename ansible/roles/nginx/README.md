# nginx

Example hardened nginx server with a smoke test.

Debian/Ubuntu only.

## Variables (defaults/main.yml)

| Variable | Default |
|----------|---------|
| `nginx_site_title` | `"{{ inventory_hostname }}"` |
| `nginx_listen_port` | `80` |

Override any of these in `group_vars`, `host_vars` or `-e`.
