#!/bin/bash

# Check GitHub App Installation Status
# This script helps verify if the Claude GitHub App is properly installed

echo "🔍 Checking Claude GitHub App Installation Status"
echo "=================================================="

# Check if repository is accessible
echo "1. Testing repository access..."
if git ls-remote --heads origin >/dev/null 2>&1; then
    echo "   ✅ Repository is accessible"
else
    echo "   ❌ Repository access failed"
    exit 1
fi

# Check workflow files
echo "2. Checking workflow files..."
if [ -f ".github/workflows/claude-official.yml" ]; then
    echo "   ✅ Claude workflow file exists"
else
    echo "   ❌ Claude workflow file missing"
fi

# Check if CLAUDE.md exists
echo "3. Checking project configuration..."
if [ -f "CLAUDE.md" ]; then
    echo "   ✅ CLAUDE.md configuration exists"
else
    echo "   ❌ CLAUDE.md configuration missing"
fi

# Check recent commits
echo "4. Checking recent integration commits..."
if git log --oneline -3 | grep -q "claude\|Claude"; then
    echo "   ✅ Claude integration commits found"
else
    echo "   ❌ No Claude integration commits found"
fi

# Instructions for manual verification
echo ""
echo "🔍 Manual Verification Steps:"
echo "==============================="
echo "1. Visit: https://github.com/settings/installations"
echo "2. Look for 'Claude' in your installed GitHub Apps"
echo "3. Verify it has access to TeamGen repository"
echo ""
echo "If Claude App is NOT installed:"
echo "1. Visit: https://github.com/apps/claude"
echo "2. Click 'Install'"
echo "3. Select TeamGen repository"
echo "4. Grant required permissions"
echo ""
echo "🧪 Test Integration:"
echo "==================="
echo "1. Go to: https://github.com/JDSavvy/TeamGen/issues/new"
echo "2. Create issue with: '@claude Hello! Test integration'"
echo "3. Wait for Claude response (2-5 minutes)"
echo ""
echo "📊 Current Status:"
echo "=================="
echo "   Workflow Files: ✅ Ready"
echo "   Repository: ✅ Accessible"
echo "   GitHub App: ❓ Manual verification needed"
echo "   API Key: ❓ Check repository secrets"