# @claude GitHub Integration Setup Guide

## 🚀 Official Anthropic @claude Bot Setup

This guide sets up the official Anthropic @claude GitHub bot integration for the TeamGen project.

## Prerequisites ✅

- [x] GitHub repository access (admin permissions)
- [x] Anthropic API key (from your Claude Code setup)
- [x] Claude Code installed locally

## Quick Setup (Recommended)

### Step 1: Install GitHub App via Claude Code

In your Claude Code terminal (the one you're using now), run:

```bash
/install-github-app
```

This command will:
- Set up the official Claude GitHub App
- Configure required secrets automatically
- Create workflow files
- Enable @claude mentions

### Step 2: Add Repository Secrets

Go to your GitHub repository settings and add these secrets:

1. **Repository Settings** → **Secrets and variables** → **Actions**
2. **Add repository secret**:
   - Name: `ANTHROPIC_API_KEY`
   - Value: Your Anthropic API key

### Step 3: Verify Installation

1. Check that the GitHub App is installed:
   - Go to: https://github.com/settings/installations
   - Verify "Claude" app is listed with access to TeamGen

2. Check workflow file exists:
   - `.github/workflows/claude.yml` should be present

3. Test @claude mention:
   - Create a test issue
   - Comment: `@claude Hello! Can you help analyze this project?`
   - Claude should respond within a few minutes

## Manual Setup (Alternative)

If the quick setup doesn't work, follow these manual steps:

### 1. Install Claude GitHub App

Visit: https://github.com/apps/claude
- Click "Install"
- Select your TeamGen repository
- Grant required permissions

### 2. Add Repository Secrets

Navigate to: `https://github.com/JDSavvy/TeamGen/settings/secrets/actions`

Add these secrets:
- `ANTHROPIC_API_KEY`: Your Anthropic API key
- `APP_ID`: (if using GitHub App auth)
- `APP_PRIVATE_KEY`: (if using GitHub App auth)

### 3. Workflow Configuration

The workflow file `.github/workflows/claude.yml` is already configured with:
- Trigger on @claude mentions
- TeamGen-specific context
- Clean Architecture guidelines
- Modern Swift patterns enforcement

## How to Use @claude Bot

### In Issues:
```markdown
@claude Can you help implement the missing PlayerEntity tests?

@claude Review the Clean Architecture implementation and suggest improvements

@claude Create a comprehensive test suite for TeamGenerationService
```

### In Pull Requests:
```markdown
@claude Please review this PR for performance issues

@claude Can you add accessibility support to this new UI component?

@claude Help optimize this SwiftData query for better performance
```

### In Code Reviews:
```markdown
@claude Suggest improvements for this team balancing algorithm

@claude Check if this implementation follows our Clean Architecture guidelines

@claude Add error handling to this async function
```

## @claude Capabilities

### Code Implementation ✨
- Fix compilation errors
- Implement missing features
- Add comprehensive tests
- Refactor code for better architecture

### Code Review 🔍
- Analyze PR changes
- Suggest performance improvements
- Check architecture compliance
- Review security implications

### Testing 🧪
- Create unit tests
- Add integration tests
- Implement UI tests
- Fix test compilation errors

### Documentation 📚
- Add inline documentation
- Create README updates
- Generate API documentation
- Explain complex algorithms

## Project-Specific Guidelines

@claude is configured with TeamGen-specific knowledge:

### Architecture Enforcement
- Clean Architecture (Domain → Core → Features → Shared)
- @Observable ViewModels (not @ObservableObject)
- Protocol-based dependency injection
- SwiftData with proper migrations

### Code Quality Standards
- SwiftLint compliance
- SwiftFormat adherence
- 90%+ test coverage target
- Comprehensive accessibility support

### Current Priorities
1. **Fix test implementations** - Resolve compilation errors
2. **Complete core features** - Implement missing functionality
3. **Performance optimization** - Profile and optimize
4. **Accessibility** - Full VoiceOver and Dynamic Type support

## Troubleshooting

### @claude Not Responding?
1. Check GitHub App installation
2. Verify `ANTHROPIC_API_KEY` is set correctly
3. Ensure you have repository admin permissions
4. Check workflow file syntax

### API Rate Limits?
- @claude respects Anthropic API rate limits
- May take longer to respond during high usage
- Consider upgrading API plan for faster responses

### Workflow Errors?
- Check Actions tab for detailed error logs
- Verify all required secrets are set
- Ensure workflow file is valid YAML

## Advanced Configuration

### Custom System Message
The workflow includes TeamGen-specific instructions for @claude:
- iOS app context
- SwiftUI + Clean Architecture patterns
- Modern Swift requirements
- Testing expectations

### Model Selection
Currently using `claude-3-5-sonnet-20241022` (latest model) for:
- Best code understanding
- Comprehensive responses
- Latest Swift/iOS knowledge

### Response Limits
- Max tokens: 4000 (configurable)
- Timeout: 10 minutes
- Automatic retry on failures

## Security Best Practices

- ✅ API keys stored in GitHub Secrets
- ✅ No hardcoded credentials
- ✅ Limited repository scope
- ✅ Audit log tracking

## Next Steps

1. **Complete Quick Setup**: Run `/install-github-app`
2. **Test Integration**: Create a test issue with @claude mention
3. **Start Development**: Use @claude for immediate test fixes
4. **Monitor Usage**: Track @claude interactions and improvements

---

**Ready to revolutionize your development workflow with AI assistance!** 🤖✨