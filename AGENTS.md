# AGENTS.md

Personal dotfiles for Fedora 44 + sway (Wayland), applied with Ansible.

## Layout

- `playbook.yml`: main playbook, runs the `linux` role on localhost.
- `roles/linux/tasks/`: tasks, everything is tagged (`--list-tags`).
- `roles/linux/vars/main/`: lists (packages, repositories, symlinks, units, vscodium), auto-loaded.
- `roles/linux/files/`: configs, symlinked into `$HOME` (`vars/main/symlinks.yml`).
- `system.yml`: encrypted Fedora install on a disk (wipes it).
- `windows/`: Windows bootstrap (winget).
- Tooling (ansible, ansible-lint, molecule) comes from mise: `roles/linux/files/mise/config.toml`.

## Rules

- Commit on `master`, only after the user reviewed the change.
- One-line commit messages, no `Co-Authored-By` or AI attribution.
- Never push unless asked.
- Comments: 1-3 words, no explanatory comments. Every package entry has one.
- Never remove something without proposing a replacement.
- Keep every package manager (dnf, flatpak, snap, brew, pip, npm, cargo, nix).
- Prefer Wayland-native tools.
- No `ignore_errors`, no fake `changed_when`: make tasks really idempotent.
- Services: `state: started` + handlers on config change, never `restarted` in tasks.
- System configs: drop-ins (`*.conf.d/`) rather than editing vendor files.

## Gotchas

- `umask 077`: always set `mode` on files and extracted archives.
- Configs are symlinks to the repo: apps writing their config edit the repo.
- `/usr/sbin` is merged into `/usr/bin`.

## Checks

```
ansible-lint
ansible-playbook playbook.yml --syntax-check
molecule test
```

CI (`.github/workflows/ci.yml`, `fedora:44` containers): lint, package existence (`--tags repos` then `--tags dnf --check`), molecule.
