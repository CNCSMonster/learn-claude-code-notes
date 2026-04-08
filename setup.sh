#!/bin/bash
# Setup script for learn-claude-code-notes
# Installs mdBook and sets up the development environment

set -e

echo "📚 Installing mdBook and mermaid..."

MDBOOK_VERSION="0.4.36"

# Check if cargo is available
if command -v cargo &> /dev/null; then
    # Try cargo-binstall first (faster)
    if command -v cargo-binstall &> /dev/null; then
        echo "Using cargo-binstall..."
        cargo binstall mdbook@$MDBOOK_VERSION -y
        cargo binstall mdbook-mermaid -y
    else
        echo "Using cargo install..."
        cargo install mdbook --version $MDBOOK_VERSION
        cargo install mdbook-mermaid
    fi
else
    # Download pre-built binary
    echo "Downloading pre-built binary..."
    curl -L https://github.com/rust-lang/mdBook/releases/download/v${MDBOOK_VERSION}/mdbook-v${MDBOOK_VERSION}-x86_64-unknown-linux-gnu.tar.gz | tar xz
    chmod +x mdbook
    echo "mdBook downloaded to current directory"
    echo "Move it to your PATH: sudo mv mdbook /usr/local/bin/"
    echo "Then install mdbook-mermaid: cargo install mdbook-mermaid"
fi

echo ""
echo "✅ mdBook + mermaid installed successfully!"
echo ""
echo "📖 Start development server:"
echo "   mdbook serve --open"
echo ""
echo "🔨 Build static files:"
echo "   mdbook build"
echo ""
echo "📊 Mermaid usage:"
echo "   \`\`\`mermaid"
echo "   graph TD"
echo "       A --> B"
echo "   \`\`\`"
echo ""
