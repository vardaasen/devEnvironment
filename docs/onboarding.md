# Onboarding: Git and SSH Setup

## Prerequisites

- Git installed (`winget install Git.Git`)
- PowerShell Core installed (`winget install Microsoft.PowerShell`)

## Level 1: Basic Setup (Minimum)

### 1. Generate SSH Key
```powershell
ssh-keygen -t ed25519 -C "your-email@example.com"
```

### 2. Add Key to GitHub
```powershell
# Copy public key to clipboard
Get-Content ~/.ssh/id_ed25519.pub | Set-Clipboard
```

Go to GitHub → Settings → SSH and GPG keys → New SSH key.

### 3. Configure Identity
```powershell
# Copy the template
Copy-Item .env.template .env

# Edit with your values
notepad .env
```

Fill in `GIT_USER_NAME`, `GIT_USER_EMAIL`, and `SSH_SIGNING_KEY`.

### 4. Apply to a Repository

After `git init` in any repo:
```powershell
git setvardaasen   # Your alias, or use Set-GitIdentity
```

## Level 2: Signed Commits (Recommended)

### 1. Enable SSH Signing
```powershell
git config --global gpg.format ssh
git config --global commit.gpgsign true
git config --global user.signingkey ~/.ssh/id_ed25519.pub
```

### 2. Create Allowed Signers File
```powershell
$email = "your-email@example.com"
$pub = Get-Content ~/.ssh/id_ed25519.pub
"$email $pub" | Set-Content ~/.ssh/allowed_signers
git config --global gpg.ssh.allowedSignersFile ~/.ssh/allowed_signers
```

### 3. Add Signing Key to GitHub

Same public key, but add it as a **Signing Key** (not just Authentication).
GitHub → Settings → SSH and GPG keys → New SSH key → Key type: Signing Key.

## Level 3: Vault-Managed Keys (Advanced)

For maximum security, store private keys in a password manager with SSH agent support:

### 1Password

1. Store SSH key in 1Password
2. Enable SSH Agent in 1Password Settings → Developer
3. Add to `~/.ssh/config`:
```
Host *
    IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
```

On Windows:
```
Host *
    IdentityAgent "\\.\pipe\openssh-ssh-agent"
```

Enable 1Password SSH agent in Settings → Developer → SSH Agent.

### Bitwarden / Vaultwarden

Free and self-hostable alternative. Requires Bitwarden CLI for SSH agent integration.

### ProtonPass

Newer option with SSH key storage support.

## Per-Repository Identity

This project uses **local** git config per repo to prevent accidental cross-contamination:
```powershell
# Never set user.name/email globally
# Always use per-repo config
git config --local user.name "Your Name"
git config --local user.email "your-email@example.com"
```

The `Set-GitIdentity` function in the PowerShell profile reads from `.env` and applies this automatically.

## Security Notes

- **Never commit `.env`** — it is gitignored
- **Never commit private keys** — only public keys (`.pub`) in templates
- **Review OWASP Secrets Management** — https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html
- **Use passphrases** on all SSH keys as a second layer of defense
