# Try to get the latest version from CHANGELOG.md first
VERSION=$(head -n 10 CHANGELOG.md | grep "## \[" | head -n 1 | sed -E 's/## \[([0-9.]*)\].*/\1/')

# Fallback to git tags if CHANGELOG is not working
if [ -z "$VERSION" ]; then
    VERSION=$(git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//')
fi

# Final fallback
if [ -z "$VERSION" ]; then
    VERSION="1.0.0"
fi

echo "$VERSION"
