# 🤝 Contributing to PiPassive

Thank you for your interest in contributing to PiPassive! This document will guide you through the contribution process.

## 📋 Table of Contents

- [How to Contribute](#how-to-contribute)
- [Reporting Bugs](#reporting-bugs)
- [Feature Requests](#feature-requests)
- [Pull Requests](#pull-requests)
- [Coding Guidelines](#coding-guidelines)
- [Testing](#testing)

---

## 🚀 How to Contribute

There are many ways to contribute to PiPassive:

1. **🐛 Report bugs** - Found a problem? Open an issue!
2. **💡 Suggest features** - Have an idea? Share it!
3. **📝 Improve documentation** - Corrections, translations, examples
4. **🔧 Write code** - Bug fixes, new features, optimizations
5. **🧪 Testing** - Test on different hardware and configurations
6. **⭐ Support** - Star the project, share it!

---

## 🐛 Reporting Bugs

### Before Reporting

1. **Search existing issues** - The problem might already be known
2. **Check documentation** - Consult [troubleshooting.md](docs/troubleshooting.md)
3. **Test with clean configuration** - Verify it's not a local issue

### How to Report

Open a **GitHub Issue** with:

**Bug Report Template:**

```markdown
## Bug Description
[Clear and concise description of the problem]

## Steps to Reproduce
1.
2.
3.

## Expected Behavior
[What you expected to happen]

## Actual Behavior
[What happens instead]

## Logs
```
[Paste relevant logs - REMOVE credentials!]
```

## Environment
- Raspberry Pi Model: [e.g. Raspberry Pi 4 Model B 4GB]
- OS: [e.g. Raspberry Pi OS Bullseye 64-bit]
- Docker Version: [output of `docker --version`]
- Docker Compose Version: [output of `docker compose version`]

## Configuration Files
[Share docker-compose.yml or .env.example if relevant - NEVER .env with credentials!]

## Screenshots
[If applicable]

## Additional Notes
[Any other useful information]
```

---

## 💡 Feature Requests

### Before Proposing

1. **Check if it doesn't exist already** - Search in issues and discussions
2. **Evaluate if it's in-scope** - Does the feature make sense for the project?
3. **Consider alternatives** - Are there different ways to achieve the same goal?

### How to Propose

Open a **GitHub Discussion** or **Issue** with:

**Feature Request Template:**

```markdown
## Feature Description
[Clear description of the proposed feature]

## Problem it Solves
[What problem does it solve? Why is it useful?]

## Proposed Solution
[How do you think it should work?]

## Alternatives Considered
[Have you considered other solutions?]

## Additional Context
[Screenshots, examples, links, etc.]

## Implementation Ideas
[If you have ideas on how to implement it]
```

---

## 🔀 Pull Requests

### Environment Setup

```bash
# Fork the repository on GitHub
# Then clone your fork
git clone https://github.com/YOUR_USERNAME/PiPassive.git
cd PiPassive

# Add upstream remote
git remote add upstream https://github.com/ORIGINAL_OWNER/PiPassive.git

# Create a branch for your feature
git checkout -b feature/feature-name
```

### Workflow

1. **Create a branch** for your changes
2. **Make your changes** following the guidelines
3. **Test thoroughly** on Raspberry Pi if possible
4. **Commit with clear messages**
5. **Push to your fork**
6. **Open a Pull Request**

### Commit Messages

Use descriptive commit messages:

```bash
# ✅ GOOD
git commit -m "Add health check for EarnApp container"
git commit -m "Fix: Correct password escaping in setup.sh"
git commit -m "Docs: Add troubleshooting for MystNode port forwarding"

# ❌ BAD
git commit -m "fix bug"
git commit -m "update"
git commit -m "changes"
```

### Commit Message Format

```
<type>: <subject>

<body (optional)>

<footer (optional)>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting, missing semicolon, etc (no code change)
- `refactor`: Code refactoring
- `test`: Adding or modifying tests
- `chore`: Maintenance, dependencies, etc

### Pull Request Template

```markdown
## Description
[Clear description of the changes]

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
[How did you test the changes?]

- [ ] Tested on Raspberry Pi 3
- [ ] Tested on Raspberry Pi 4
- [ ] Tested on Raspberry Pi 5
- [ ] Scripts executed successfully
- [ ] Documentation updated

## Checklist
- [ ] My code follows the project style
- [ ] I have commented the code where necessary
- [ ] I have updated the documentation
- [ ] My changes do not generate new warnings
- [ ] I have tested the changes locally
- [ ] I have added tests if applicable

## Screenshots
[If applicable]

## Related Issues
Fixes #123
Related to #456
```

---

## 📝 Coding Guidelines

### Bash Scripts

```bash
# Use strict mode
set -e  # Exit on error
set -u  # Exit on undefined variable
set -o pipefail  # Exit on pipe failure

# Functions naming
function_name() {  # lowercase with underscore
    local var_name="value"  # use local for function variables
}

# Variables
CONSTANT_NAME="value"  # UPPERCASE for constants
variable_name="value"   # lowercase for variables

# Comments
# Single line comment for brief explanations

################################################################################
# Multi-line comment block for important sections
################################################################################

# Error handling
if [[ condition ]]; then
    # code
else
    log_error "Clear error message"
    exit 1
fi
```

### Docker Compose

```yaml
# Indentation: 2 spaces
# Order: image, container_name, restart, environment, volumes, ports, networks

services:
  service_name:
    image: image:tag
    container_name: service_name
    restart: unless-stopped
    environment:
      - VAR_NAME=value
    volumes:
      - ./path:/container/path
    ports:
      - "host:container"
    networks:
      - network_name
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

### Markdown Documentation

```markdown
# Use Clear Headers
## With Hierarchy
### As Needed

Use **bold** for emphasis and `code` for commands/files.

## Code Blocks with Language

```bash
# Always specify language
command --with-flags
```

## Lists

- Use bullet points
- For unordered lists
- Keep items concise

1. Numbered lists
2. For sequential steps
3. With clear actions
```

---

## 🧪 Testing

### Test Checklist

Before making PR, test:

- [ ] Scripts execute without errors
- [ ] Correct permissions (chmod +x for .sh)
- [ ] Variables in .env work
- [ ] Containers start correctly
- [ ] Logs don't show errors
- [ ] Dashboard shows correct info
- [ ] Backup and restore work
- [ ] Documentation is updated

### Hardware Testing

If possible, test on:
- Raspberry Pi 3 (ARMv7 architecture)
- Raspberry Pi 4 (ARM64 architecture)
- Raspberry Pi 5 (ARM64 architecture)

### Manual Flow Testing

```bash
# Clone fresh
git clone [your-fork]
cd PiPassive

# Test installation
./install.sh

# Test setup
./setup.sh

# Test management
./manage.sh start
./manage.sh status
./manage.sh logs
./manage.sh stop

# Test backup/restore
./backup.sh
./restore.sh backups/[latest]

# Test web dashboard
# Access http://pipassive.local in your browser
```

---

## 📚 Documentation

### When to Update Documentation

Update documentation when:
- You add new features
- You change existing behavior
- You add new dependencies
- You modify configuration
- You add new commands

### Files to Update

- `README.md` - For main features
- `QUICKSTART.md` - If you change basic workflow
- `docs/services.md` - For new services
- `docs/troubleshooting.md` - For new common problems
- `docs/advanced.md` - For advanced configurations
- `CHANGELOG.md` - For every significant change

---

## 🌍 Translations

Translation contributions are welcome!

Create a directory `docs/translations/[lang]/` and translate:
- README.md
- QUICKSTART.md
- docs/services.md
- docs/troubleshooting.md

---

## ❓ Questions?

- **General Questions:** Open a Discussion on GitHub
- **Bug Reports:** Open an Issue
- **Feature Requests:** Open a Discussion or Issue
- **Security Issues:** See SECURITY.md (if available)

---

## 📜 Code of Conduct

### Our Standards

- ✅ Be respectful and inclusive
- ✅ Accept constructive feedback
- ✅ Focus on what's best for the community
- ✅ Show empathy towards other members

- ❌ Trolling, insults or personal attacks
- ❌ Public or private harassment
- ❌ Publishing others' private information
- ❌ Unprofessional conduct

### Enforcement

Unacceptable behaviors can be reported by opening an issue.
Maintainers reserve the right to remove comments and ban users.

---

## 🎉 Acknowledgments

All contributors will be mentioned in the README!

For significant contributions:
- Mention in release notes
- "Contributor" badge on profile
- Eternal gratitude! 🙏

---

## 📄 License

By contributing to PiPassive, you agree that your contributions will be released under the MIT License.

---

**Thank you for contributing to PiPassive!** 🍓

Every contribution, big or small, is appreciated! 💚
