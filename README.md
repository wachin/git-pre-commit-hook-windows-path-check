# Git Pre-Commit Hook For Windows-Safe Paths

This repository is designed to prevent commits that contain file paths or filenames incompatible with Windows.

Its core component is **pre-commit-windows-paths**: a global Git hook that runs before every commit. It checks only the staged files and blocks the commit if it detects common Windows compatibility issues, such as:

* Forbidden characters in filenames
* Filenames ending with a space or a period
* Reserved names such as `CON`, `AUX`, `COM1`, and `LPT1`
* Path segments that are too long
* Relative paths that exceed the recommended length
* Paths that, when cloned on Windows, are likely to exceed the maximum supported path length

The installation process is described in **install-global-hook.sh**. It creates `~/.config/git/hooks`, places the hook there, and configures `git config --global core.hooksPath ...` so that it applies automatically to all of your Git repositories.

The **README** confirms this purpose and also explains the available environment variables for customizing path length limits and the estimated Windows checkout base path.

In summary, this is a tool for Linux developers and teams that want to stop Windows-incompatible files at commit time, preventing clone or checkout failures later on Windows.


## Repository Contents

- `pre-commit-windows-paths`: main reusable hook
- `install-global-hook.sh`: installs it as your global Git `pre-commit`
- `uninstall-global-hook.sh`: removes the global `pre-commit` symlink
- `README.md`: usage instructions

## Why This Exists

Linux allows many file and folder names that later break `git clone` or `git checkout` on Windows.

Typical failures include:

- a directory ending with periods, such as `Acerca de...`
- a reserved name such as `AUX.txt`
- very long file or folder names
- very deep nested paths that become too long only when cloned into a real Windows folder like `C:\Users\Name\Documents\Projects\repo`

This hook stops those paths at commit time and prints the exact problem so the developer can fix it before pushing.

## Install Globally

Clone or download this repository on your Linux machine, then run:

```bash
chmod +x install-global-hook.sh
./install-global-hook.sh
```

That installer:

- marks the hook as executable
- creates the global hooks directory if needed
- symlinks `pre-commit-windows-paths` as your global `pre-commit`
- runs `git config --global core.hooksPath ...`

After that, every `git commit` in every repository using your global Git config will run this hook first.

## Manual Installation

If you prefer to install it manually:

```bash
mkdir -p ~/.config/git/hooks
ln -sf "$(pwd)/pre-commit-windows-paths" ~/.config/git/hooks/pre-commit
chmod +x "$(pwd)/pre-commit-windows-paths"
chmod +x ~/.config/git/hooks/pre-commit
git config --global core.hooksPath ~/.config/git/hooks
```

## Optional Tuning

You can tune the limits and the estimated Windows clone destination with environment variables:

```bash
export REPOPATH_SANITIZER_MAX_PATH=260
export REPOPATH_SANITIZER_MAX_SEGMENT=255
export REPOPATH_SANITIZER_CHECKOUT_ROOT='C:\Users\Juan\Documents\Projects'
```

If you want these settings always active, place them in your shell startup file such as `~/.bashrc`.

## How It Behaves

When a staged path is problematic, the hook blocks the commit and prints:

- the staged path
- the problem code
- a human-readable explanation

Example categories you may see:

- `TRAILING_SPACE_PERIOD`
- `RESERVED_DEVICE`
- `SEGMENT_TOO_LONG`
- `PATH_TOO_LONG`
- `CHECKOUT_PATH_TOO_LONG`

## Uninstall

If you want to remove the global hook:

```bash
chmod +x uninstall-global-hook.sh
./uninstall-global-hook.sh
```

If you want to stop using the global hooks directory entirely:

```bash
git config --global --unset core.hooksPath
```

## Notes

- The hook checks only **staged** paths, because those are the ones about to enter history.
- It is self-contained and does not depend on another local project path.
- It works independently of any GUI application.
- If a specific repository defines its own `core.hooksPath`, that repository setting overrides the global one.
