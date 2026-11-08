# Contributing

Thanks for helping out! This project aims to stay small, readable and safe by default.

## Dev setup

```bash
python3 -m venv .venv && . .venv/bin/activate
pip install -r requirements-dev.txt
ansible-galaxy collection install -r ansible/requirements.yml
make lint    # needs terraform and tflint on PATH
make test    # needs Docker
```

Optionally install [pre-commit](https://pre-commit.com) and run `pre-commit install`. See the README's Testing section for what the containers can and cannot verify.

## Workflow

1. Fork and create a branch from `main`.
2. Make your change. Keep roles idempotent: a second `ansible-playbook` run must report `changed=0`.
3. Run `make lint` and `make test` locally.
4. Open a pull request describing what changed and how you tested it.

## Guidelines

- Use fully-qualified module names (`ansible.builtin.apt`, not `apt`).
- Every Terraform variable and output needs a `description` and a `type`.
- Security-relevant defaults must be restrictive; loosening one needs a rationale in the PR.
- Add new hardening checks to `audit` so they are verified, not just applied.

## Reporting security issues

Please open a private security advisory on GitHub rather than a public issue.
