# 🍓 PiPassive - Raspberry Pi Passive Income Automator

Automated system to install and manage multiple passive income applications on your Raspberry Pi with one click!

## 📋 Supported Services

This project automatically manages the following services:

1. **Honeygain** - Share your internet connection
2. **EarnApp** - Earn by sharing internet bandwidth
3. **Pawns.app** - Monetize your connection
4. **PacketStream** - Bandwidth sharing for market research
5. **TraffMonetizer** - Internet traffic sharing
6. **Repocket** - Network sharing platform
7. **EarnFM** - Earn from your unused bandwidth
8. **MystNode** - Decentralized VPN node
9. **PacketShare** - Packet sharing for passive income

## 🚀 Quick Installation (One-Click)

### Prerequisites
- Raspberry Pi (3, 4 or 5) with Raspberry Pi OS
- Internet connection
- SSH access or local terminal

### Automatic Installation

```bash
# Clone the repository
git clone https://github.com/simplayy/PiPassive.git
cd PiPassive

# Make installation script executable
chmod +x install.sh

# Run automatic installation
./install.sh
```

The script will automatically install:
- Docker and Docker Compose
- All necessary dependencies
- **Always active Web Dashboard** (starts automatically at boot)
- Configure all passive income services

## ⚙️ Configuration

After installation, you can configure services in two ways:

### Option 1️⃣: Web Configuration (Recommended)

The easiest and most intuitive way:

```bash
# Web dashboard is always active automatically
# Access directly in your browser
http://pipassive.local:8888/setup
```

In the browser you'll find a complete form to configure:
- All services (API credentials, tokens, IDs)
- Timezone and system settings
- Direct instructions for each service with registration links

The form will automatically save configurations to the `.env` file.

**For MystNode**: After configuration, access `http://pipassive.local:4449` to complete the node identity.

### Option 2️⃣: Terminal Configuration (CLI)

For those who prefer the terminal:

```bash
./setup.sh
```

The script will guide you step-by-step through the interactive configuration of each service, with direct questions and instructions.

### Manual Mode (Advanced)

If you prefer to edit directly:

```bash
# Copy the template
cp .env.example .env

# Edit with your editor
nano .env
```

## 🎮 Service Management

### Main Commands

```bash
# Start all services
./manage.sh start

# Stop all services
./manage.sh stop

# Restart all services
./manage.sh restart

# Show services status
./manage.sh status

# Show logs of a specific service
./manage.sh logs honeygain

# Update all containers
./manage.sh update
```

### Web Dashboard

Access the web dashboard to monitor your services in real time:

```
http://pipassive.local:8888
```

The dashboard includes:
- **Home**: Real-time status of all services (Active/Inactive)
- **Setup**: Web form to configure credentials
- **Quick Links**: Direct access to official dashboards of each service
- **Action Buttons**: Restart, Stop, View Logs for each service

The web server is **always active** thanks to a systemd service that starts automatically at system boot.

## 📊 Monitoring

The system includes:
- Real-time text dashboard
- Centralized logs for each service
- Automatic status checks
- Alerts for non-functioning services

## 🔧 Project Structure

```
PiPassive/
├── README.md                 # This file
├── install.sh               # Main installation script
├── setup.sh                 # Interactive configuration script
├── manage.sh                # Service management script
├── dashboard.sh             # Monitoring dashboard
├── docker-compose.yml       # Docker Compose configuration
├── .env.example             # Environment variables template
├── backup.sh                # Backup script
├── restore.sh               # Restore script
├── docs/                    # Detailed documentation
│   ├── services.md          # Guide to obtain API keys
│   ├── troubleshooting.md   # Troubleshooting
│   └── advanced.md          # Advanced configurations
└── configs/                 # Service configurations
    └── [service]/           # Config for each service
```

## 📱 Obtaining API Keys

Each service requires registration. Follow the [detailed guide](docs/services.md) to obtain:

1. **Honeygain**: https://join.honeygain.com/SIMNI7E3A1 (with $3 bonus)
2. **EarnApp**: https://earnapp.com/i/KSj1BgEi
3. **Pawns**: https://pawns.app/?r=4060689 (with $3 bonus)
4. **PacketStream**: https://packetstream.io/?psr=6GQZ
5. **TraffMonetizer**: https://traffmonetizer.com/?aff=1677252
6. **Repocket**: https://link.repocket.com/mnGO
7. **EarnFM**: https://earn.fm/ref/SIMO7N4P
8. **MystNode**: https://mystnodes.co/?referral_code=Z2MtvYCSj92pngdiqavF51ZLxs1ZQtWHY6ap0Lsi
9. **PacketShare**: https://www.packetshare.io/?code=F5AF0C1F37B0D827

## 🔒 Security

- Never commit the `.env` file with your credentials
- Use strong passwords for each service
- Keep the operating system updated
- Monitor services regularly

## 🔄 Backup and Restore

### Backup

```bash
./backup.sh
```

Creates a backup of all configurations in `backups/backup_YYYYMMDD_HHMMSS.tar.gz`

### Restore

```bash
./restore.sh backups/backup_YYYYMMDD_HHMMSS.tar.gz
```

## 🐛 Troubleshooting

### Service won't start
```bash
# Check service logs
./manage.sh logs service-name

# Restart specific service
docker-compose restart service-name
```

### Network problems
```bash
# Check connectivity
ping 8.8.8.8

# Restart networking
sudo systemctl restart networking
```

For other problems, check the [troubleshooting guide](docs/troubleshooting.md).

## 📈 Performance and Earnings

Earnings vary based on:
- Internet connection quality
- Geographic location
- Number of active services
- Uptime duration

**Estimated average**: $20-50 per month (highly depends on the factors above)

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the project
2. Create a branch for your feature
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📝 License

MIT License - see [LICENSE](LICENSE) for details

## ⚠️ Disclaimer

- Use these services at your own risk
- Check local laws regarding internet bandwidth sharing
- Carefully read the ToS of each service
- We do not guarantee specific earnings
- Monitor your ISP bandwidth usage

## 📞 Support

- Issues: [GitHub Issues](https://github.com/simplayy/PiPassive/issues)
- Discussions: [GitHub Discussions](https://github.com/simplayy/PiPassive/discussions)

## 🙏 Credits

Created with ❤️ for the Raspberry Pi community

---

**Note**: This project is provided "as-is". Make sure you understand what each service does before using it.
