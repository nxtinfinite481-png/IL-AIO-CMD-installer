# INFINITE LABS AIO CMD

**All-in-one VPS, panel, server, and system management toolkit.**

INFINITE LABS AIO CMD is a terminal-based toolkit designed to simplify VPS and server management through a centralized interactive CLI.

---

## Overview

INFINITE LABS AIO CMD brings multiple server-management utilities, hosting panels, Pterodactyl tools, Wings/Node management, Docker utilities, themes, extensions, and additional system tools into one organized terminal interface.

The project is designed to make common server deployment and management tasks easier to access from a single CLI.

---

## Features

### Core

- Interactive CLI dashboard
- Centralized module navigation
- System status information
- CPU and RAM usage monitoring
- Modular menu structure
- VPS/server management utilities
- Independent project structure

### Panel Management

The toolkit includes modules for multiple hosting and server-management panels:

- **Pterodactyl**
  - Panel installation and management
  - VPS utilities
  - phpMyAdmin utilities
  - SSL utilities
  - Additional Pterodactyl tools

- **PufferPanel**
  - PufferPanel installation and management

- **Mythical**
  - Mythical panel deployment utilities

- **Paymenter**
  - Paymenter deployment utilities

- **Jexactyl**
  - Jexactyl deployment utilities

- **Convoy**
  - Convoy deployment utilities

- **Pteroca**
  - Pteroca deployment utilities

- **Reviactyl**
  - Reviactyl deployment utilities

- **WHMC**
  - WHMC deployment utilities

### Wings / Node

Dedicated utilities for Pterodactyl Wings/Node management, including installation and configuration-related functionality.

### Docker

Docker-related utilities for managing container-based server environments.

### Toolbox

The Toolbox section provides additional server and networking utilities, including:

- Cloudflare utilities
- System information
- Localtonet
- Root utilities
- Tailscale
- ZeroTier
- Terminal utilities

### Extras

Additional server utilities including:

- CasaOS
- Cockpit
- cPanel
- LVM

### Setup VM

Includes VM/VPS setup utilities and deployment templates for supported environments.

---

## Themes & Blueprint

INFINITE LABS AIO CMD includes a collection of Blueprint resources for Pterodactyl.

- **66 Blueprint Extensions**
- **20 Blueprint Themes**

These resources are organized inside the project's theme management system.

---

## Supported Panels

| Panel | Included | Purpose |
|---|---|---|
| Pterodactyl | Yes | Game server and node management |
| PufferPanel | Yes | Game server management |
| Mythical | Yes | Server management |
| Paymenter | Yes | Hosting billing and invoicing |
| Jexactyl | Yes | Hosting management |
| Convoy | Yes | Server management |
| Pteroca | Yes | Panel management |
| Reviactyl | Yes | Panel management |
| WHMC | Yes | Billing and automation |

---

## Quick Start

Run the following command on your VPS/server:

```bash
bash <(curl -sSL https://raw.githubusercontent.com/nxtinfinite481-png/IL-AIO-CMD-installer/main/run.sh)
```

The launcher starts the INFINITE LABS AIO CMD interface and provides access to the available modules.

---

## Usage

After launching the toolkit, use the interactive menu to select the required module.

Typical workflow:

```text
Launch AIO CMD
      ↓
Main Menu
      ↓
Select Module
      ↓
Select Tool / Panel
      ↓
Configure
      ↓
Install / Manage
```

The exact options available depend on the current project modules.

---

## Project Structure

```text
INFINITE-LABS/
├── Extras/
├── menu/
├── panel/
├── setup vm/
├── thame/
├── toolbox/
├── wings/
├── docker.sh
├── run.sh
└── ui.sh
```

### Main Directories

| Directory | Description |
|---|---|
| `panel/` | Hosting panel installation and management modules |
| `wings/` | Wings / Node utilities |
| `thame/` | Blueprint themes and extensions |
| `toolbox/` | Server and networking utilities |
| `Extras/` | Additional server utilities |
| `setup vm/` | VM/VPS setup utilities |
| `menu/` | Menu and interface components |

---

## Requirements

General requirements:

- Linux VPS or server
- Internet connection
- Bash-compatible environment
- Root or appropriate administrative privileges for system-level operations

Individual modules may have additional requirements depending on the software being installed.

Supported operating systems may vary between modules.

---

## Security

INFINITE LABS AIO CMD is maintained with a focus on clean and reviewable shell scripts.

The project has been checked for:

- Hardcoded credentials
- Legacy branding
- Unnecessary hidden persistence
- Suspicious legacy remote execution
- Broken internal paths
- Shell syntax issues

However, **always review scripts before executing them on a production server**.

You are responsible for understanding and approving any commands executed on your system.

---

## Independence

INFINITE LABS AIO CMD is maintained as an independent project.

The project structure, branding, launcher, and modules are maintained under the **INFINITE LABS** identity.

---

## Contributing

Contributions are welcome.

Basic workflow:

```bash
git clone https://github.com/nxtinfinite481-png/IL-AIO-CMD-installer.git
cd IL-AIO-CMD-installer
```

Create a branch, make your changes, test them on a safe environment, and submit a pull request.

Please test shell scripts before submitting changes.

---

## Disclaimer

INFINITE LABS AIO CMD is provided for server administration and deployment purposes.

Some modules can install, modify, or configure system-level software. Always review the source code and test changes in a non-production environment before using them on important infrastructure.

INFINITE LABS AIO CMD is not officially affiliated with the third-party panels, software, themes, or extensions referenced by the project.

---

## Repository

**GitHub:**

https://github.com/nxtinfinite481-png/IL-AIO-CMD-installer

---

<p align="center">

**INFINITE LABS**

*Build. Create. Scale.*

</p>