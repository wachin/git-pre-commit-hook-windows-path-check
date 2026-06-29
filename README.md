# Git Pre-Commit Hook For Windows-Safe Paths

Reusable Git `pre-commit` hook for Linux developers who want to stop Windows-incompatible paths before they enter repository history.

It blocks a commit when staged paths would likely cause problems on Windows, including:

- forbidden characters
- trailing spaces or trailing periods
- reserved names such as `CON`, `AUX`, `COM1`, `LPT1`
- file or folder names that are too long
- repository-relative paths that are too long
- estimated final Windows checkout paths that are too long after adding the clone base folder

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
