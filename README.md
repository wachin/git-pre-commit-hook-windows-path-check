# Git Pre-Commit Hook For Windows-Safe Paths

This repository is designed to prevent commits that contain file paths or filenames incompatible with Windows.

Its core component is **pre-commit-windows-paths**: a reusable Git hook that runs before a commit in repositories where you install it. It checks only the staged files and blocks the commit if it detects common Windows compatibility issues, such as:

* Forbidden characters in filenames
* Filenames ending with a space or a period
* Reserved names such as `CON`, `AUX`, `COM1`, and `LPT1`
* Path segments that are too long
* Relative paths that exceed the recommended length
* Paths that, when cloned on Windows, are likely to exceed the maximum supported path length

This is a tool for Linux developers and teams that want to stop Windows-incompatible files at commit time, preventing clone or checkout failures later on Windows.


## Repository Contents

- `pre-commit-windows-paths`: main reusable hook
- `install-hook.sh`: installs it into one target repository
- `uninstall-hook.sh`: removes it from one target repository
- `README.md`: usage instructions

## Why This Exists

Linux allows many file and folder names that later break `git clone` or `git checkout` on Windows.

Typical failures include:

- a directory ending with periods, such as `Acerca de...`
- a reserved name such as `AUX.txt`
- very long file or folder names
- very deep nested paths that become too long only when cloned into a real Windows folder like `C:\Users\Name\Documents\Projects\repo`

This hook stops those paths at commit time and prints the exact problem so the developer can fix it before pushing.

## Install In One Repository

Clone or download this repository on your Linux machine, then run:

```bash
chmod +x install-hook.sh
./install-hook.sh /path/to/target-repository
```

That installer:

- marks the hook as executable
- creates the target repository hooks directory if needed
- symlinks `pre-commit-windows-paths` as `.git/hooks/pre-commit` inside that repository

After that, `git commit` will run this hook only in that repository.

## Manual Installation

If you prefer to install it manually in a specific repository:

```bash
cd /path/to/target-repository
mkdir -p .git/hooks
ln -sf /path/to/git-pre-commit-hook-windows-path-check/pre-commit-windows-paths .git/hooks/pre-commit
chmod +x /path/to/git-pre-commit-hook-windows-path-check/pre-commit-windows-paths
chmod +x .git/hooks/pre-commit
```

## Optional Tuning

You can tune the limits and the estimated Windows clone destination with environment variables:

```bash
export REPOPATH_SANITIZER_MAX_PATH=260
export REPOPATH_SANITIZER_MAX_SEGMENT=255
export REPOPATH_SANITIZER_CHECKOUT_ROOT='C:\Users\YourUser\Documents\Projects'
```

Replace `YourUser` with the actual Windows username, or use the real base folder where the repository is usually cloned on Windows.

This variable is only used to estimate the final checkout path on Windows:

```text
<checkout_root>\<repo_name>\<relative_path>
```

If you want these settings always active, place them in your shell startup file such as `~/.bashrc`.

This section is completely **optional**. It allows the hook to be either more strict or more flexible when estimating whether a path could cause problems on Windows.

Let's go through it step by step.

Suppose your repository contains the following file:

```text
docs/manuales/español/capitulo1/imagenes/tutorial/muy_largo/archivo.txt
```

The hook needs to answer the following question:

> **"If someone clones this repository on Windows, will the full path be too long?"**

However, there is one problem: **the hook runs on Linux**, so it has no way of knowing where the Windows user will clone the repository.

Instead, it makes an estimate.

For example, if you define:

```bash
export REPOPATH_SANITIZER_CHECKOUT_ROOT='C:\Users\Washington\Documents\GitHub'
```

and the repository is named:

```text
LinuxFileManager
```

the hook estimates the final Windows checkout path as:

```text
C:\Users\Washington\Documents\GitHub\
LinuxFileManager\
docs\
manuales\
español\
capitulo1\
imagenes\
tutorial\
muy_largo\
archivo.txt
```

It then measures the total length of that path.

---

## What does each variable mean?

### 1. Defines the maximum allowed length for the **entire path**.

```bash
export REPOPATH_SANITIZER_MAX_PATH=260
```

Defines the maximum allowed length for the **entire path**.

The traditional Windows limit is:

```text
260 characters
```

although modern versions of Windows can support longer paths if that feature has been enabled.

If you want to be more permissive, you can use values such as:

```bash
export REPOPATH_SANITIZER_MAX_PATH=320
```

or

```bash
export REPOPATH_SANITIZER_MAX_PATH=1024
```

---

### 2. This limits the length of **each individual file or directory name**.

```bash
export REPOPATH_SANITIZER_MAX_SEGMENT=255
```

This limits the length of **each individual file or directory name**.

For example:

```text
Project/
```

is one path segment.

```text
Documents/
```

is another.

```text
file.pdf
```

is another.

Windows generally does not allow individual file or directory names longer than **255 characters**, even if the total path length is much larger.

---

### 3. Assume the repository will be cloned here

```bash
export REPOPATH_SANITIZER_CHECKOUT_ROOT='C:\Users\YourUser\Documents\Projects'
```

This is the most interesting variable.

It tells the hook:

> "Assume the repository will be cloned here."

The hook will then estimate the final checkout path as:

```text
C:\Users\YourUser\Documents\Projects\
MyRepository\
...
```

If you normally clone your repositories into:

```text
D:\Git\
```

you can instead use:

```bash
export REPOPATH_SANITIZER_CHECKOUT_ROOT='D:\Git'
```

This will produce a more accurate estimate of the final path length.


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

If you want to remove the hook from one repository:

```bash
chmod +x uninstall-hook.sh
./uninstall-hook.sh /path/to/target-repository
```

## Notes

- The hook checks only **staged** paths, because those are the ones about to enter history.
- It is self-contained and does not depend on another local project path.
- It works independently of any GUI application.
