# Pre-Reinstall Checklist

Run through this list before wiping the machine.

## Automated (run `./backup/backup.sh`)

The backup script handles all of these automatically:

- [ ] GNOME settings (extensions, dconf, keybindings, guake)
- [ ] Sticky notes
- [ ] SSH keys (`~/.ssh/`)
- [ ] AWS credentials (`~/.aws/`)
- [ ] Docker auth (`~/.docker/config.json`)
- [ ] mkcert root CA (`~/.local/share/mkcert/`)
- [ ] GNOME keyrings (`~/.local/share/keyrings/login.keyring`)
- [ ] Git local config (`.gitconfig_local`)
- [ ] NPM config (`.npmrc`)

## Manual

These need manual attention:

- [ ] **Commit and push dotfiles** — `cd ~/dotfiles && git add -A && git commit && git push`
- [ ] **Browser** — Verify Chrome sync is up to date (bookmarks, extensions, passwords)
- [ ] **Calibre library** — Back up `~/Calibre Library/` if you have books (large, not in dotfiles)
- [ ] **Ardour projects** — Back up any active audio sessions
- [ ] **OBS Studio** — Back up scenes/profiles from `~/.config/obs-studio/` if customized
- [ ] **FortiClient VPN** — Note down VPN server addresses and credentials
- [ ] **IntelliJ settings** — Verify JetBrains settings sync is enabled, or export settings
- [ ] **VS Code / Cursor** — Verify settings sync is enabled
- [ ] **Project repos** — Ensure all local repos are pushed to remote
- [ ] **Virtual machines** — Back up any VM images
- [ ] **Downloads folder** — Check for anything important in `~/Downloads/`
- [ ] **Backup zip** — Copy `tmp/backup-*.zip` to USB or cloud storage

## After Reinstall

1. Run the bootstrap:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/janjitsu/dotfiles/master/bootstrap.sh | bash
   ```
2. Restore SSH keys:
   ```bash
   unzip backup-*.zip
   cp -r backup-*/ssh ~/.ssh
   chmod 700 ~/.ssh && chmod 600 ~/.ssh/id_rsa*
   ```
3. Restore AWS: `cp -r backup-*/aws ~/.aws`
4. Restore Docker: `mkdir -p ~/.docker && cp backup-*/docker/config.json ~/.docker/`
5. Restore mkcert: `cp -r backup-*/mkcert ~/.local/share/mkcert`
6. Restore keyrings: `cp backup-*/keyrings/* ~/.local/share/keyrings/`
7. Restore GNOME: `./backup/gnome.sh restore`
8. Restore sticky notes: `./backup/sticky-notes.sh restore tmp/sticky-notes-*.zip`
9. Install desktop apps: `./setup/apps/idea.sh`, `./setup/apps/ardour.sh`, etc.
10. Log into Chrome, JetBrains, Docker Hub, AWS CLI, etc.
