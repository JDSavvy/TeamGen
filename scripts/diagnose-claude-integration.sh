#!/bin/bash

echo "🔍 Claude GitHub Integration Diagnose"
echo "====================================="

# 1. Check repository visibility
echo "1. Repository-Zugriff prüfen..."
REPO_INFO=$(curl -s "https://api.github.com/repos/JDSavvy/TeamGen")
if echo "$REPO_INFO" | grep -q '"private": true'; then
    echo "   ⚠️  Repository ist PRIVAT - das könnte das Problem sein!"
elif echo "$REPO_INFO" | grep -q '"private": false'; then
    echo "   ✅ Repository ist öffentlich"
else
    echo "   ❌ Repository nicht erreichbar oder existiert nicht"
fi

# 2. Check if workflows are present
echo "2. Workflow-Dateien prüfen..."
if [ -f ".github/workflows/claude-official.yml" ]; then
    echo "   ✅ Claude Workflow existiert"
else
    echo "   ❌ Claude Workflow fehlt"
fi

# 3. Check recent workflow runs
echo "3. Workflow-Ausführungen prüfen..."
WORKFLOW_RUNS=$(curl -s "https://api.github.com/repos/JDSavvy/TeamGen/actions/runs?per_page=5")
if echo "$WORKFLOW_RUNS" | grep -q '"total_count": 0'; then
    echo "   ⚠️  Keine Workflow-Ausführungen gefunden"
else
    echo "   ✅ Workflows wurden ausgeführt"
fi

echo ""
echo "🚨 Warum @claude nicht funktioniert:"
echo "=================================="
echo ""
echo "1. REPOSITORY SICHTBARKEIT:"
echo "   - Wenn privat: GitHub App braucht explizite Installation"
echo "   - Lösung: https://github.com/apps/claude installieren"
echo ""
echo "2. GITHUB APP INSTALLATION:"
echo "   - Besuche: https://github.com/settings/installations"
echo "   - Prüfe: 'Claude' ist installiert für TeamGen"
echo ""
echo "3. API KEY KONFIGURATION:"
echo "   - Gehe zu: https://github.com/JDSavvy/TeamGen/settings/secrets/actions"
echo "   - Prüfe: ANTHROPIC_API_KEY existiert"
echo ""
echo "4. WORKFLOW PERMISSIONS:"
echo "   - Gehe zu: https://github.com/JDSavvy/TeamGen/settings/actions"
echo "   - Aktiviere: 'Allow GitHub Actions to create and approve pull requests'"
echo ""
echo "🧪 TEST-SCHRITTE:"
echo "==============="
echo "1. Installiere GitHub App: https://github.com/apps/claude"
echo "2. Erstelle Issue mit: '@claude Hello, test integration'"
echo "3. Warte 2-5 Minuten auf Antwort"
echo "4. Prüfe Actions Tab für Workflow-Ausführung"