#!/bin/bash

# install_r_mac.sh
# Script for installing R 4.4.3, RStudio and development tools for Mac
# ================================================================

# Enable verbose mode with -v flag
VERBOSE=false
if [[ "$1" == "-v" || "$1" == "--verbose" ]]; then
    VERBOSE=true
fi

log() {
    if $VERBOSE; then
        echo "$1"
    fi
}

log_always() {
    echo "$1"
}

log_always "🚀 === Starting installation of R 4.4.3, RStudio and development tools for Mac ==="

# Check if Homebrew is installed, if not, install it
if ! command -v brew &> /dev/null; then
    log "🍺 Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for this session
    log "🔄 Adding Homebrew to PATH..."
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    log "🍺 Homebrew is already installed. Updating..."
    if $VERBOSE; then
        brew update
    else
        brew update &> /dev/null
    fi
fi

# Install XCode Command Line Tools (equivalent of Rtools for Mac)
log "🛠️ Installing XCode Command Line Tools..."
if $VERBOSE; then
    xcode-select --install || log "✓ XCode Command Line Tools are already installed or installation request has started."
else
    xcode-select --install &> /dev/null || true
fi

# Check if R is installed and which version
R_INSTALLED=false
if command -v R &> /dev/null; then
    R_VERSION=$(R --version | head -n 1 | awk '{print $3}')
    log "📊 Current R version: $R_VERSION"
    
    # Check if it's a 4.4.x version
    if [[ $R_VERSION == 4.4.* ]]; then
        log "✅ R version 4.4.x is already installed. Skipping R installation."
        R_INSTALLED=true
    else
        log "⚠️ Installed R version is not 4.4.x. Installing R 4.4.3..."
    fi
fi

# Install R 4.4.3 only if needed
if [ "$R_INSTALLED" = false ]; then
    log "📥 Installing R 4.4.3..."
    # Install R 4.4.3 via Homebrew cask
    if $VERBOSE; then
        brew install --cask r@4.4.3 || brew install --cask r || log "❌ Please try to install R 4.4.3 manually from https://cloud.r-project.org/bin/macosx/"
    else
        brew install --cask r@4.4.3 &> /dev/null || brew install --cask r &> /dev/null || log_always "❌ Could not install R. Please try to install R 4.4.3 manually from https://cloud.r-project.org/bin/macosx/"
    fi
    
    # Check the installed R version
    if command -v R &> /dev/null; then
        R_VERSION=$(R --version | head -n 1 | awk '{print $3}')
        log "📊 Installed R version: $R_VERSION"
    fi
fi

# Check if RStudio is installed
if [ -d "/Applications/RStudio.app" ] || [ -d "$HOME/Applications/RStudio.app" ]; then
    log "✅ RStudio is already installed. Skipping RStudio installation."
else
    log "📥 Installing RStudio..."
    if $VERBOSE; then
        brew install --cask rstudio || log "❌ RStudio installation failed. Try installing manually from https://www.rstudio.com/products/rstudio/download/"
    else
        brew install --cask rstudio &> /dev/null || log_always "❌ RStudio installation failed. Try installing manually from https://www.rstudio.com/products/rstudio/download/"
    fi
fi

# Install essential libraries for R development (Mac equivalent of Rtools)
log "🔧 Installing essential development tools..."

# Define all required dependencies
dependencies=(
    "curl"
    "openssl@3"
    "libgit2"
    "libxml2"
    "pkg-config"
    "cairo"
    "pango"
    "libpng"
    "jpeg"
    "freetype"
    "gfortran"
)

cask_dependencies=(
    "xquartz"
    "pandoc"
)

# Install formula dependencies
total_deps=${#dependencies[@]}
log_always "📦 Installing formula dependencies..."

for i in "${!dependencies[@]}"
do
    dep="${dependencies[$i]}"
    current=$((i+1))
    log_always "   Installing [$current/$total_deps]: $dep"
    if $VERBOSE; then
        brew install "$dep" || log "⚠️ $dep installation failed or already installed."
    else
        brew install "$dep" &> /dev/null || true
    fi
done

# Install cask dependencies
total_cask_deps=${#cask_dependencies[@]}
log_always "📦 Installing cask dependencies..."

for i in "${!cask_dependencies[@]}"
do
    dep="${cask_dependencies[$i]}"
    current=$((i+1))
    log_always "   Installing [$current/$total_cask_deps]: $dep"
    if $VERBOSE; then
        brew install --cask "$dep" || log "⚠️ $dep installation failed or already installed."
    else
        brew install --cask "$dep" &> /dev/null || true
    fi
done

log_always "✨ === Installation completed! ==="
log_always "🚀 You can start RStudio from the Applications folder or via Spotlight."
if command -v R &> /dev/null; then
    log_always "📊 R version: $(R --version | head -n 1 | awk '{print $3}')"
fi
log_always "🛠️ Development tools have been installed."

if $VERBOSE; then
    log ""
    log "📋 === Installation paths ==="
    log "📂 R: $(which R 2>/dev/null || echo 'Not found')"
    log "📂 RScript: $(which Rscript 2>/dev/null || echo 'Not found')"
    log "📂 RStudio should be installed in: /Applications/RStudio.app"
fi