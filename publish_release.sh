#!/bin/bash
set -e

VERSION=$(./get_version.sh)
echo "🚀 Publishing Lex v$VERSION..."

# 1. Provide a clean build and testing
echo "🧹 Cleaning and compiling tests..."
make clean
make test

# 2. Build Release Assets (.dmg and .zip)
echo "📦 Building Release Assets..."
make release
make verify-sparkle

# 3. Generate Appcast (Sparkle Auto-Update Feed)
echo "✨ Generating Appcast..."
make appcast

# 4. Commit any changes (including the updated appcast.xml)
if [[ -n $(git status -s) ]]; then
    echo "💾 Committing changes (appcast.xml / changelog)..."
    git add .
    git commit -m "chore: release v$VERSION and update appcast"
    git push origin main
fi

# 5. Tag the release
echo "🏷️ Tagging v$VERSION..."
git tag -f "v$VERSION"
git push origin "v$VERSION" --force

# 6. Create or Update GitHub Release
echo "🌐 Creating GitHub Release v$VERSION..."
gh release create "v$VERSION" Lex.dmg Lex.app.zip --title "Lex v$VERSION" --generate-notes || \
gh release upload "v$VERSION" Lex.dmg Lex.app.zip --clobber

echo "✅ Done! v$VERSION successfully published."
echo "⚠️ Don't forget to enable GitHub Pages from the 'main' branch root to serve 'appcast.xml'."
