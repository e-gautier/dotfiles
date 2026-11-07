# .files
```
sh <(curl -fsSL https://raw.githubusercontent.com/e-gautier/dotfiles/master/.files)
```
Windows (Administrator Powershell prompt required):
```ps
irm https://raw.githubusercontent.com/e-gautier/dotfiles/master/.files.ps1 | iex
```
## Requirements
- python
- git
- curl
## Tests
```bash
# dependencies
mise install
sudo dnf install -y vagrant vagrant-libvirt
sudo systemctl start libvirtd
# run tests suite
molecule create
molecule converge
molecule verify
# or
molecule test
# check manually
ansible-playbook playbook.yml --list-tags
ansible-playbook -K playbook.yml --tags dotfiles --check --diff
```
## Install a Vim plugin
```
git submodule add PLUGIN_GIT_REPO roles/linux/files/vim/bundle/PLUGIN_NAME
```
Where PLUGIN_GIT_REPO is the url of the git repository of a plugin and PLUGIN_NAME must be the same as the one in the git repository url.
EG. `git submodule add https://github.com/tpope/vim-fugitive.git roles/linux/files/vim/bundle/vim-fugitive`
## Remove a Vim plugin
```
git rm roles/linux/files/vim/bundle/PLUGIN_NAME
```
## Update git submodules
```
git submodule update --remote --recursive
```
## Install Tmux plugins
Download and install
```
C-b I
```
reload tmux.conf
```
C-b r
```
## Install VSCode extensions
```
ansible-playbook -K playbook.yml --tags vscodium
```
## Misc
### SELinux
-
### Firefox: remove white loading flash
In the profile folder do:
```
cat > chrome/userChrome.css

browser[type="content-primary"],
browser[type="content"] {
  background: #000000 !important;
}

.browserContainer {
    background: #000000 !important;
}
```
### Auditd configuration
```
cp roles/linux/files/auditd/audit.rules /etc/audit/rules.d/
```
### NFTables configuration
```
ansible-playbook -K playbook.yml --tags nftables
```
### UBlock Origin filters
```
! block ad div
www.google.com##div[id^="ed_"]

! block ppl searched for div
google.com##.AUiS2

! block Youtube recommendations
www.youtube.com##ytd-browse[page-subtype="home"] #primary

```
## Troubleshooting
### Backlight key caps not working
Add the following kernel parameter:
```
acpi_osi='!Windows 2012'
```
## Contributors
[@wdhif - https://github.com/wdhif](https://github.com/wdhif)
