#!/bin/bash

# Runs - Automatic Git Push Script
# Double-click this file to push everything to GitHub

echo "🏀 Runs - GitHub Push Script"
echo "=============================="
echo ""

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "📂 Working directory: $SCRIPT_DIR"
echo ""

# Check if git is initialized
if [ ! -d ".git" ]; then
    echo "🔧 Initializing git repository..."
    git init
    echo "✅ Git initialized"
    echo ""
fi

# Check if remote exists
if ! git remote | grep -q "origin"; then
    echo "🔗 Adding GitHub remote..."
    git remote add origin https://github.com/AkshithVattem/runs.git
    echo "✅ Remote added"
    echo ""
fi

# Add all files
echo "📝 Adding all files..."
git add .
echo "✅ Files added"
echo ""

# Commit
echo "💾 Committing changes..."
git commit -m "Complete Runs basketball app implementation

Features:
✅ Google/Apple Sign In
✅ Profile creation with photo upload
✅ GPS-verified check-ins
✅ Real-time court activity graphs
✅ Friend requests system
✅ Direct messaging
✅ Live session timers
✅ Supabase backend integration
✅ Complete onboarding flow
✅ Player profile cards
✅ Enhanced friends system
✅ Court activity analytics

Tech Stack:
- SwiftUI + SwiftData
- Supabase (PostgreSQL + Realtime)
- PostGIS for geospatial queries
- CoreLocation for GPS
- VisionKit for QR scanning
- Swift Charts for analytics"

echo "✅ Changes committed"
echo ""

# Push to GitHub
echo "🚀 Pushing to GitHub..."
echo "⚠️  You'll be prompted for credentials:"
echo "   Username: AkshithVattem"
echo "   Password: Your GitHub Personal Access Token"
echo ""

git branch -M main
git push -u origin main

# Check if push was successful
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ ✅ ✅ SUCCESS! ✅ ✅ ✅"
    echo ""
    echo "🎉 Your code is now on GitHub!"
    echo "🔗 View it at: https://github.com/AkshithVattem/runs"
    echo ""
else
    echo ""
    echo "❌ Push failed!"
    echo ""
    echo "Common issues:"
    echo "1. Wrong credentials - Make sure you're using a Personal Access Token, not password"
    echo "2. No internet connection"
    echo "3. Repository doesn't exist - Make sure https://github.com/AkshithVattem/runs exists"
    echo ""
    echo "Need a token? Go to: https://github.com/settings/tokens"
    echo ""
fi

echo "Press any key to close..."
read -n 1
