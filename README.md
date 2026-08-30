# INFINITE LABS AIO CMD

**Build. Create. Scale.**

INFINITE LABS AIO CMD is a terminal-based administration toolkit for Linux VPS
servers running Pterodactyl-compatible panels, Wings nodes, Blueprint themes
and extensions, and common server utilities.

## Quick start

Run the public launcher from any directory:

```bash
bash <(curl -sSL https://raw.githubusercontent.com/nxtinfinite481-png/IL-AIO-CMD-installer/main/run.sh)
```

The launcher uses the local checkout when available. Otherwise it downloads a
temporary copy of this repository and starts the main menu without depending
on the caller's current working directory.

## Included

- VPS and VM setup modules
- Pterodactyl, Reviactyl, Paymenter, Jexactyl, Convoy, MythicalDash, PteroCA,
  and WHMCS installer routes where their local modules are present
- Pterodactyl Wings installation, configuration, database, and management
  tools
- 20 packaged Blueprint themes
- 66 packaged Blueprint extensions
- Cockpit, CasaOS, 1Panel, Docker, LVM, networking, terminal, and system tools

## Requirements

- A clean Ubuntu or Debian Linux VPS for installation modules
- Root access for system and panel installers
- A domain pointed at the server for web panels and Let's Encrypt
- At least 2 GB RAM; 4 GB or more is recommended for panel workloads
- Internet access for official package and project downloads

## Safety and credentials

- Installation modules are destructive system-administration tools. Review the
  selected module before running it on a production server.
- Database credentials are generated securely by default or requested from the
  operator; this project does not provide shared panel passwords.
- SMTP credentials are intentionally not embedded. Configure mail settings in
  the target application's environment after installation.
- Blueprint assets are packaged locally so the menu does not silently execute a
  remote payload.

## Verification

Run shell syntax checks from the project root:

```bash
find . -type f -name '*.sh' -print0 | xargs -0 -n1 bash -n
```

The menu and local routing can be inspected without performing VPS
installation. Full panel, Wings, VM, package, and certificate flows require a
real supported Linux VPS and are therefore not tested in a development
workspace.

## License

See [LICENSE](LICENSE).