# TODO

## Done

- [x] Git config
- [x] GNOME extensions and configs backup/restore
- [x] Remove git dependency from bootstrap
- [x] Sticky notes backup (sensitive content, gitignored)
- [x] PulseEffects config symlink
- [x] Touchegg config symlink + service setup
- [x] Desktop apps setup (IntelliJ, Postman, VMPK)
- [x] VMPK keymapping backup and symlink
- [x] Fedora equivalents for all Ubuntu setup scripts
- [x] Generic orchestrators (drop a script, it runs)
- [x] Debloat scripts (remove snap + flatpak)
- [x] Centralize symlinks in setup/symlinks.sh
- [x] Bootstrap one-liner (curl, no git needed)

## In Progress

- [ ] Save and restore vim sessions with tmux
- [ ] Enable system copy-paste with tmux

## Future Improvements

### Refactor to Ansible
- Replace bash scripts with Ansible playbooks for idempotency, better error handling, and cross-distro abstraction
- Use Ansible roles: `base`, `desktop`, `gnome`, `dev-tools`, `apps`
- Use `ansible-pull` for the bootstrap one-liner instead of curl | bash
- Leverage Ansible's `package` module to abstract apt/dnf differences
- Use Ansible `template` module instead of sed for `%USER%` replacement

### First-Class CLI Commands
- Make scripts in `scripts/` available as commands in `$PATH`
- Add `~/.local/bin` or `~/dotfiles/scripts` to PATH in shellrc
- Add proper `--help` and argument parsing to each script
- Scripts to promote: `pactl_switch_sink.sh`, `share_folder_smb.sh`, `generate_cpf.sh`

### Other
- [ ] Kanata: install binary to `/usr/local/bin` instead of `~/Programs`
- [ ] Move old `scripts/docker.sh` to `setup/common/docker.sh` (already done, clean up old)
- [ ] Add a `setup/desktop/cemu.sh` for the Wii emulator (desktop file exists, no setup script)
- [ ] Consolidate the gnome/ and backup/ todo files into this one
- [ ] Add health check script that verifies all symlinks and services are in place
- [ ] Add `--dry-run` flag to setup.sh to preview what would be changed
- [ ] Add Termux setup support (setup/termux/ exists but is minimal)
