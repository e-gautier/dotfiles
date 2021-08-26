# .files
full binaries (laptop mode, i3 and all my personnal required crappy binaries):
```
bash <(curl -L https://git.io/fhAyY)
```
minimal binaries (server  mode):
```
bash <(curl -L https://git.io/fhAyY) minimal
```
Windows (Administrator Powershell prompt required):
```ps
Invoke-Expression((New-Object System.Net.WebClient).DownloadString('https://git.io/fjd3F'))
```
This script is idempotent, it can be safely run multiple times.
## Requirements
- git
- curl
## Dependencies
- [Pathogen.vim](https://github.com/tpope/vim-pathogen)
- [Dotbot](https://github.com/anishathalye/dotbot)
## Install a Vim plugin
```
git submodule add PLUGIN_GIT_REPO vim/bundle/PLUGIN_NAME
```
Where PLUGIN_GIT_REPO is the url of the git repository of a plugin and PLUGIN_NAME must be the same as the one in the git repository url.
EG. `git submodule add https://github.com/tpope/vim-pathogen.git vim/bundle/vim-pathogen`
## Remove a Vim plugin
Remove the git module in `.gitmodules` and remove the vim plugin directory
```
git rm vim/bundle/PLUGIN_NAME
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
awk '{system("codium --install-extension "$1)}' ~/dotfiles/vscode/extensions
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
cp auditd/audit.rules /etc/audit/rules.d/
```
### NFTables configuration
```
cp nftables/inet-filter.nft /etc/nftables
```
Uncomment respectively in `/etc/sysconfig/nftables`.
```
systemctl enable --now nftables
```
### UBlock Origin filters
```
! 5/16/2020 https://www.google.com
! block ad div
www.google.com##div[id^="ed_"]

! 6/7/2020 https://www.google.com
! block ppl searched for div
www.google.com###eob_7 > .AUiS2

! 5/25/2020 https://www.youtube.com
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
