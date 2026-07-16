# nix-config

Home Manager flake for personal machines:

- `linhnguyen@mac-m4`: macOS / Apple Silicon (`aarch64-darwin`)
- `linhnguyen@nixos-pc`: NixOS PC (`x86_64-linux`)
- `linhnguyen@hp-prodesk`: HP ProDesk (`x86_64-linux`)

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

### HP ProDesk

```bash
home-manager switch --flake .#linhnguyen@hp-prodesk
```

Another `x86_64-linux` profile, mirroring the NixOS PC feature set and adding the Rust toolchain (`features/rust`) alongside Go, plus the `claude-code` package (this host only).

#### Self-hosted GitHub Actions runners

`features/github-runners` runs one self-hosted Actions runner per repository as a
systemd user service.

Because this repo is public, the actual runner declarations (repo URLs, labels)
are kept **outside** the repo. Copy `home-manager/hp-prodesk-runners.nix.example`
to `~/.config/nix-config/hp-prodesk-runners.nix` — a plain attrset, one entry per
repo:

```nix
{
  my-repo = {
    url = "https://github.com/owner/my-repo";
    tokenFile = "/home/linhnguyen/.config/github-runner/my-repo.token";
    labels = [ "self-hosted" "linux" "hp-prodesk" ];
  };
}
```

`hp-prodesk.nix` imports that file when it exists. Since it lives outside the
flake, switch with `--impure`:

```bash
home-manager switch --flake .#linhnguyen@hp-prodesk --impure
```

`tokenFile` holds a GitHub PAT with repository administration scope (the runner
exchanges it for a registration token, so it survives restarts); keep it outside
the repo too. After switching, enable the units:

```bash
sudo loginctl enable-linger "$USER"   # keep user services running without a login session
systemctl --user daemon-reload
systemctl --user enable --now github-runner-my-repo
```

To re-register a runner (changed URL/labels), stop the unit and delete
`~/.local/share/github-runner/<name>` before switching again.
