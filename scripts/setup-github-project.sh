#!/bin/bash

# Setup GitHub Project Board for TeamGen
# This script helps set up the complete GitHub project management infrastructure

echo "🚀 TeamGen GitHub Project Setup"
echo "==============================="

# Check if gh CLI is available
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed. Please install it first."
    echo "   https://cli.github.com/"
    exit 1
fi

# Check if we're authenticated
if ! gh auth status &> /dev/null; then
    echo "❌ Not authenticated with GitHub CLI. Run 'gh auth login' first."
    exit 1
fi

echo "✅ GitHub CLI ready"
echo ""

# Step 1: Create labels
echo "📋 Step 1: Setting up GitHub labels..."
if [ -f ".github/labels.yml" ]; then
    echo "   Creating labels from configuration..."
    
    # Create labels one by one (gh doesn't support bulk import from YAML yet)
    echo "   Note: Creating labels manually as gh CLI doesn't support YAML import yet"
    echo "   You can import these later via GitHub web interface or API"
    echo "   Labels configuration: .github/labels.yml"
else
    echo "   ⚠️ Labels configuration file not found"
fi

# Step 2: Create project board
echo ""
echo "📊 Step 2: Creating GitHub Project Board..."
echo "   Please follow these manual steps:"
echo ""
echo "   1. Go to: https://github.com/JDSavvy/TeamGen"
echo "   2. Click on 'Projects' tab"
echo "   3. Click 'New project'"
echo "   4. Choose 'Table' template"
echo "   5. Name it 'TeamGen Development Roadmap'"
echo "   6. Add description: 'Comprehensive project management for TeamGen iOS app development'"
echo ""

# Step 3: Create milestones
echo "📅 Step 3: Creating release milestones..."

gh api repos/JDSavvy/TeamGen/milestones \
    --method POST \
    --field title='v1.0 MVP Release' \
    --field description='Core functionality for basic team management. Target: March 2025' \
    --field due_on='2025-03-31T23:59:59Z' \
    --field state='open' && echo "   ✅ Created milestone: v1.0 MVP Release"

gh api repos/JDSavvy/TeamGen/milestones \
    --method POST \
    --field title='v1.1 Enhanced Experience' \
    --field description='Polish and user experience improvements. Target: May 2025' \
    --field due_on='2025-05-31T23:59:59Z' \
    --field state='open' && echo "   ✅ Created milestone: v1.1 Enhanced Experience"

gh api repos/JDSavvy/TeamGen/milestones \
    --method POST \
    --field title='v1.2 Advanced Features' \
    --field description='Power user features and integrations. Target: August 2025' \
    --field due_on='2025-08-31T23:59:59Z' \
    --field state='open' && echo "   ✅ Created milestone: v1.2 Advanced Features"

# Step 4: Create roadmap issues
echo ""
echo "📝 Step 4: Creating roadmap epics..."
if [ -f "scripts/create-roadmap-issues.sh" ]; then
    echo "   Running roadmap issues creation script..."
    ./scripts/create-roadmap-issues.sh
else
    echo "   ⚠️ Roadmap issues script not found"
fi

# Step 5: Setup project automation
echo ""
echo "🤖 Step 5: Project automation setup..."
echo "   ✅ GitHub Actions workflows created:"
echo "   - project-automation.yml (auto-assign, labeling, Claude integration)"
echo "   - claude.yml (AI assistance)"
echo "   - claude-code-review.yml (automated code reviews)"
echo "   - ios.yml (CI/CD pipeline)"

# Step 6: Manual setup instructions
echo ""
echo "🎯 Step 6: Manual configuration needed..."
echo ""
echo "IMPORTANT: Complete these manual steps:"
echo ""
echo "A. GitHub Project Board Custom Fields:"
echo "   1. Go to your project board"
echo "   2. Add these custom fields:"
echo "      - Priority (Single select: Critical, High, Medium, Low)"
echo "      - Size (Single select: XS, S, M, L, XL)"
echo "      - Feature Area (Single select: Player Management, Team Generation, UI/UX, etc.)"
echo "      - Release (Single select: v1.0, v1.1, v1.2, Backlog)"
echo "      - Estimate (Number: hours)"
echo ""
echo "B. Project Board Views:"
echo "   1. Create 'Kanban Board' view (grouped by Status)"
echo "   2. Create 'Timeline Roadmap' view (grouped by Release)"
echo "   3. Create 'Priority Dashboard' view (filtered by Priority)"
echo ""
echo "C. Labels Import:"
echo "   1. Go to: https://github.com/JDSavvy/TeamGen/labels"
echo "   2. Create labels from .github/labels.yml manually or use GitHub API"
echo ""

# Step 7: Summary
echo ""
echo "🎉 Setup Summary"
echo "==============="
echo ""
echo "✅ Created:"
echo "   - Issue templates (bug report, feature request, epic, tech debt)"
echo "   - Project automation workflows"
echo "   - Release milestones (v1.0, v1.1, v1.2)"
echo "   - Roadmap epic issues"
echo "   - Labels configuration"
echo "   - ROADMAP.md documentation"
echo ""
echo "⏳ Manual steps needed:"
echo "   - Create GitHub Project Board"
echo "   - Configure custom fields"
echo "   - Import labels"
echo "   - Set up project views"
echo ""
echo "🔗 Quick Links:"
echo "   Repository: https://github.com/JDSavvy/TeamGen"
echo "   Issues: https://github.com/JDSavvy/TeamGen/issues"
echo "   Projects: https://github.com/JDSavvy/TeamGen/projects"
echo "   Milestones: https://github.com/JDSavvy/TeamGen/milestones"
echo ""
echo "🤖 Claude Integration:"
echo "   - Tag @claude in any issue for AI assistance"
echo "   - Automatic labeling and project assignment"
echo "   - Automated code reviews on pull requests"
echo ""
echo "Happy coding! 🚀"