# nix-config

Minimal Home Manager flake for a single machine:

- Host: `mac-m4`
- User: `linhnguyen`
- System: `aarch64-darwin`

## Usage

```bash
home-manager switch --flake .#linhnguyen@mac-m4
```

Includes the `darwin-trampoline-apps` Home Manager module so macOS GUI launchers can be generated for terminal apps.


After switching, run the generated trampoline app refresh during activation by re-running the same command whenever app entries change.
