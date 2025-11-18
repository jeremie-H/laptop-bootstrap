# laptop-bootstrap

Automated laptop configuration using Ansible for Ubuntu/Debian systems. This project bootstraps a development environment with essential tools, configurations, and optimizations.

## Features

This playbook configures your laptop with:

- **System Configuration**
  - Swap configuration and tuning
  - ZFS filesystem tuning (optional)

- **Development Environment**
  - Git configuration
  - Oh My Zsh with plugins (powerlevel10k, autosuggestions, syntax highlighting)
  - Node.js management via Volta
  - fzf fuzzy finder
  - Development tools and aliases

- **Optional Components** (uncomment in `playbook.yml`)
  - Docker and Docker Compose
  - Syncthing file synchronization
  - GNOME desktop customizations
  - APT package management

## Prerequisites

- Ubuntu/Debian-based system
- sudo/root access
- Internet connection

## Quick Install

```bash
curl --proto '=https' -L --tlsv1.2 -sSf https://raw.githubusercontent.com/jeremie-H/laptop-bootstrap/main/runme.sh > /tmp/runme.sh
chmod +x /tmp/runme.sh
/tmp/runme.sh
```

The script will:
1. Install git and Ansible (if needed)
2. Clone this repository
3. Run the Ansible playbook

## Manual Installation

If you prefer to run the playbook manually:

```bash
# Install Ansible
sudo apt-get update
sudo apt-get install -y python3-pip git
pip3 install ansible

# Clone the repository
git clone https://github.com/jeremie-H/laptop-bootstrap.git
cd laptop-bootstrap

# Run the playbook
ansible-playbook playbook.yml -i inventory.yml --ask-become-pass
```

## Customization

### Variables

Edit the configuration in `group_vars/`:
- `group_vars/all` - Common variables for all hosts
- `group_vars/laptops` - Laptop-specific variables

Key variables to customize:
```yaml
# Git configuration
full_name: "Your Name"
git_email: "your.email@example.com"

# APT packages to install
apt_packages:
  - curl
  - jq
  - meld
  # Add your packages here
```

### Enable Optional Roles

Edit `playbook.yml` and uncomment roles you want to enable:

```yaml
roles:
  # Uncomment to enable:
  # - { role: apt, tags: apt }
  # - { role: gnome, tags: gnome }
  # - { role: docker, tags: docker }
  # - { role: syncthing, tags: syncthing }
  # - { role: zfs, tags: zfs }
```

### Run Specific Roles

Use tags to run only specific roles:

```bash
# Only install oh-my-zsh
ansible-playbook playbook.yml -i inventory.yml --tags oh-my-zsh

# Run multiple roles
ansible-playbook playbook.yml -i inventory.yml --tags "git,tools-developer"

# Skip specific roles
ansible-playbook playbook.yml -i inventory.yml --skip-tags swap
```

## Available Roles

| Role | Description | Tag |
|------|-------------|-----|
| swap | Configure swap settings and swappiness | `swap` |
| git | Configure Git (user, email, defaults) | `git` |
| oh-my-zsh | Install Oh My Zsh with plugins and themes | `oh-my-zsh` |
| tools-developer | Install Volta, Node.js, fzf, and dev tools | `tools-developer` |
| apt | Install APT packages | `apt` |
| gnome | GNOME desktop customizations | `gnome` |
| docker | Install Docker and Docker Compose | `docker` |
| syncthing | Install and configure Syncthing | `syncthing` |
| zfs | Tune ZFS filesystem parameters | `zfs` |

## Development

### Testing

```bash
# Check syntax
ansible-playbook playbook.yml --syntax-check

# Dry run (check mode)
ansible-playbook playbook.yml -i inventory.yml --check

# Run with verbose output
ansible-playbook playbook.yml -i inventory.yml -vvv
```

### Linting

```bash
# Install linting tools
pip3 install ansible-lint yamllint

# Run linters
ansible-lint
yamllint .
```

### Project Structure

```
laptop-bootstrap/
├── ansible.cfg          # Ansible configuration
├── playbook.yml         # Main playbook
├── inventory.yml        # Inventory file
├── defaults/            # Default variables
├── group_vars/          # Group variables
│   ├── all              # Variables for all hosts
│   └── laptops          # Laptop-specific variables
├── roles/               # Ansible roles
│   ├── apt/
│   ├── docker/
│   ├── git/
│   ├── gnome/
│   ├── oh-my-zsh/
│   ├── ssh-keyscan/
│   ├── swap/
│   ├── syncthing/
│   ├── tools-developer/
│   └── zfs/
└── runme.sh            # Bootstrap script
```

## Troubleshooting

### Common Issues

**Playbook fails with permission errors**
- Make sure you run with `--ask-become-pass` or configure passwordless sudo

**Fonts not showing correctly in terminal**
- Log out and log back in after installation
- Make sure GNOME Terminal is using "MesloLGS NF 12" font

**Ansible not found after pip install**
- Add `~/.local/bin` to your PATH: `export PATH="$HOME/.local/bin:$PATH"`

**Role fails with "module not found"**
- Install required Ansible collections: `ansible-galaxy collection install community.general ansible.posix`

### Logs

Bootstrap script logs are saved to `/tmp/laptop-bootstrap-YYYYMMDD-HHMMSS.log`

## Security Considerations

- Sensitive variables should be encrypted with `ansible-vault`
- SSH password authentication is insecure; use SSH keys when possible
- Review all tasks before running with elevated privileges
- Keep your playbooks in a private repository if they contain sensitive data

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test your changes
5. Submit a pull request

## License

MIT License - See [LICENSE](LICENSE) file for details

## Author

Jérémie H.

## Acknowledgments

- [Oh My Zsh](https://ohmyz.sh/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [Volta](https://volta.sh/)
- [Ansible](https://www.ansible.com/)
