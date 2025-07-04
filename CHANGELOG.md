# 📋 Changelog

## [1.2.0] - 2025-01-04

### 🎉 Major Improvements

#### 🔐 Authentication & Registration System
- **NEW**: Added user registration and login scripts (`register-user.ps1` and `register-user.sh`)
- **NEW**: Automatic credential persistence in `.ai-os-credentials.json`
- **IMPROVED**: Setup scripts now automatically load saved credentials
- **FIXED**: Critical gap where users couldn't register or obtain USER_ID/TENANT_ID

#### 📚 Documentation Overhaul
- **NEW**: Created `QUICK_START.md` - 5-minute setup guide for beginners
- **NEW**: Added download links for Windsurf and setup instructions
- **NEW**: WSL (Windows Subsystem for Linux) setup guide for Windows users
- **UPDATED**: Fixed all references from "Claude Code" to "Cascade" (Windsurf's AI)
- **UPDATED**: Added proper terminal WSL instructions for Windsurf
- **IMPROVED**: More user-friendly setup process with step-by-step instructions

#### 🛠️ Scripts & Automation
- **NEW**: Cross-platform support with PowerShell (.ps1) and Bash (.sh) versions
- **NEW**: `auto-setup.md` with commands for Cascade to execute automatically
- **IMPROVED**: Better error handling and user feedback in all scripts
- **IMPROVED**: Automatic SSH key generation and configuration

#### 🤖 Agent Development
- **ENHANCED**: Comprehensive agent development guide with full examples
- **NEW**: Sentiment analysis agent example with complete implementation
- **NEW**: Testing examples for agent development
- **NEW**: Multi-agent collaboration examples

### 🐛 Bug Fixes
- Fixed incorrect "Claude: Sign in" command (now correctly shows "Windsurf: Sign in")
- Fixed credential loading issues in setup scripts
- Fixed WSL terminal detection in Windsurf
- Fixed repository references (now correctly points to Pedrovaleriolopez/ai-os-client)

### 📝 Files Added/Updated
- `scripts/register-user.ps1` (NEW)
- `scripts/register-user.sh` (NEW)
- `scripts/setup-client.ps1` (UPDATED)
- `scripts/setup-client.sh` (UPDATED)
- `scripts/auto-setup.md` (NEW)
- `QUICK_START.md` (NEW)
- `README.md` (UPDATED)
- `docs/CLIENT_SETUP_GUIDE.md` (UPDATED)
- `docs/AGENT_DEVELOPMENT_GUIDE.md` (ENHANCED)
- `.github/README_COLLABORATION.md` (UPDATED)

### 🔄 Breaking Changes
None - all changes are backward compatible

### 🚀 Next Steps
- Transfer repository from Pedrovaleriolopez to allfluencee organization
- Create v1.0.0 release
- Add video tutorials
- Implement automated testing for setup scripts

---

## [1.1.0] - 2025-01-03

### Initial Release
- Basic MCP configuration templates
- Initial documentation
- SSH-based connection to AI-OS services
- Basic test scripts

---

*For questions or issues, please visit our [GitHub Issues](https://github.com/Pedrovaleriolopez/ai-os-client/issues) or join our [Discord Community](https://discord.gg/ai-os)*