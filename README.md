# nix-config

Home Manager flake for personal machines:

- `linhnguyen@mac-m4`: macOS / Apple Silicon (`aarch64-darwin`)
- `linhnguyen@nixos-pc`: NixOS PC (`x86_64-linux`)

## Usage

### macOS MacBook

```bash
home-manager switch --flake .#linhnguyen@mac-m4
```

Includes the `darwin-trampoline-apps` Home Manager module so macOS GUI launchers can be generated for terminal apps.

After switching, run the generated trampoline app refresh during activation by re-running the same command whenever app entries change.

### NixOS PC

```bash
home-manager switch --flake .#linhnguyen@nixos-pc
```

The NixOS PC profile reuses the same shared Home Manager features as the macOS profile, but uses the Linux home directory `/home/linhnguyen` and does not load the macOS trampoline app module.
