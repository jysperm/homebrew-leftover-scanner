# Homebrew Leftover Scanner
Use rules from Homebrew Cask to scan for leftover files from uninstalled software.

3413 casks are supported now.

Currently an MVP version, TODO list:

- Support detecting `launchctl` and `login_item`

Known issues:

- JetBrains' IDEs will be detected as uninstalled if you install them via JetBrains Toolbox

![Screenshot](https://raw.githubusercontent.com/jysperm/homebrew-leftover-scanner/main/screenshots/scan-leftovers.jpg)

## Install & Usages

Install via `brew tap`:

```
brew tap jysperm/leftover-scanner
brew tap homebrew/cask # If you haven't tapped before (Homebrew don't do this by default since 4.0)
```

Run it:

```
brew scan-leftovers
```

This script doesn't actually delete files, you can follow the instructions in the output to run `brew uninstall` (at your own risk):

```
$ brew scan-leftovers
==> 4154 casks to scan ...
==> Installed from cask:
netspot, slack, sketch, steam, brave-browser, powerphotos, downie, paw, tg-pro, clashx, imazing, visual-studio-code, electrum, logseq, handbrake, obs, netnewswire, iterm2, numi, gitup, docker, blender, telegram, discord, wireshark, firefox, iina, google-chrome, zoom, grammarly, squirrel, bettertouchtool, keka, xbar
==> Installed from other ways:
bitwarden, wechat, planet, qq, medis
==> Found leftovers from bitbar, get rid of them via: brew uninstall -f --zap bitbar
/Users/jysperm/Library/Caches/com.matryer.BitBar (trash 3 files, 84.2KB)
/Users/jysperm/Library/Preferences/com.matryer.BitBar.plist (trash 531B)
==> Found leftovers from epic-games, get rid of them via: brew uninstall -f --zap epic-games
/Users/jysperm/Library/Application Support/Epic (trash 264B)
==> Found leftovers from setapp, get rid of them via: brew uninstall -f --zap setapp
/Users/jysperm/Library/Application Scripts/com.setapp.DesktopClient.SetappAgent.FinderSyncExt (trash 64B)
/Users/jysperm/Library/Caches/com.setapp.DesktopClient (trash 3 files, 84.2KB)
/Users/jysperm/Library/Caches/com.setapp.DesktopClient.SetappAgent (trash 4 files, 6.1MB)
/Users/jysperm/Library/Logs/Setapp (trash 7 files, 344.8KB)
```

### Full Disk Access
Full Disk Access is required for this script to scan paths across the entire file system.

Please enable Full Disk Access for your terminal under System Preferences > Security & Privacy > Privacy > Full Disk Access.

## About the rules
Most Homebrew casks have a `zap` section, it contains the cache files or logs of that software which can be deleted when you are no longer using it.

However `brew` doesn't delete these files by default, so the `zap` section may not be well maintained. If you find any issues, you can contribute to the official [homebrew-cask](https://github.com/Homebrew/homebrew-cask) repository.

```
$ brew cat bitbar
cask "bitbar" do
  version "1.10.1"
  sha256 "8a7013dca92715ba80cccef98b84dd1bc8d0b4c4b603f732e006eb204bab43fa"

  url "https://github.com/matryer/bitbar/releases/download/v#{version}/BitBar.app.zip"
  name "BitBar"
  desc "Utility to display the output from any script or program in the menu bar"
  homepage "https://github.com/matryer/bitbar/"

  app "BitBar.app"

  zap trash: [
    "~/Library/BitBar Plugins",
    "~/Library/Caches/com.matryer.BitBar",
    "~/Library/Preferences/com.matryer.BitBar.plist",
  ]
end
```
