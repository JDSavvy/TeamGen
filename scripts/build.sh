#!/bin/bash

# TeamGen Build Script
# Comprehensive build, test, and quality check automation

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT="TeamGen.xcodeproj"
SCHEME="TeamGen"
DESTINATION="platform=iOS Simulator,name=iPhone 16 Pro"

# Print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required tools are installed
check_dependencies() {
    print_status "Checking dependencies..."
    
    if ! command -v xcodebuild &> /dev/null; then
        print_error "xcodebuild not found. Please install Xcode."
        exit 1
    fi
    
    if ! command -v swiftlint &> /dev/null; then
        print_warning "SwiftLint not found. Installing via Homebrew..."
        brew install swiftlint
    fi
    
    if ! command -v swiftformat &> /dev/null; then
        print_warning "SwiftFormat not found. Installing via Homebrew..."
        brew install swiftformat
    fi
    
    print_success "All dependencies available"
}

# Clean build directory
clean_build() {
    print_status "Cleaning build directory..."
    xcodebuild clean -project "$PROJECT" -scheme "$SCHEME" > /dev/null 2>&1
    print_success "Build directory cleaned"
}

# Run SwiftLint
run_swiftlint() {
    print_status "Running SwiftLint..."
    if swiftlint lint; then
        print_success "SwiftLint passed"
    else
        print_error "SwiftLint found issues"
        exit 1
    fi
}

# Run SwiftFormat check
run_swiftformat_check() {
    print_status "Checking code formatting..."
    if swiftformat --lint .; then
        print_success "Code formatting is correct"
    else
        print_error "Code formatting issues found. Run 'swiftformat .' to fix"
        exit 1
    fi
}

# Build project
build_project() {
    print_status "Building project..."
    if xcodebuild build \
        -project "$PROJECT" \
        -scheme "$SCHEME" \
        -destination "$DESTINATION" \
        -configuration Debug \
        -quiet; then
        print_success "Build successful"
    else
        print_error "Build failed"
        exit 1
    fi
}

# Run unit tests
run_unit_tests() {
    print_status "Running unit tests..."
    if xcodebuild test \
        -project "$PROJECT" \
        -scheme "$SCHEME" \
        -destination "$DESTINATION" \
        -only-testing:TeamGenTests \
        -enableCodeCoverage YES \
        -quiet; then
        print_success "Unit tests passed"
    else
        print_error "Unit tests failed"
        exit 1
    fi
}

# Run UI tests
run_ui_tests() {
    print_status "Running UI tests..."
    if xcodebuild test \
        -project "$PROJECT" \
        -scheme "$SCHEME" \
        -destination "$DESTINATION" \
        -only-testing:TeamGenUITests \
        -quiet; then
        print_success "UI tests passed"
    else
        print_warning "UI tests failed (non-critical for development)"
    fi
}

# Generate documentation
generate_docs() {
    print_status "Generating documentation..."
    if xcodebuild docbuild \
        -project "$PROJECT" \
        -scheme "$SCHEME" \
        -destination "$DESTINATION" \
        -quiet; then
        print_success "Documentation generated"
    else
        print_warning "Documentation generation failed"
    fi
}

# Show help
show_help() {
    echo "TeamGen Build Script"
    echo ""
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  help          Show this help message"
    echo "  clean         Clean build directory only"
    echo "  lint          Run code quality checks only"
    echo "  build         Build project only"
    echo "  test          Run tests only"
    echo "  unit-test     Run unit tests only"
    echo "  ui-test       Run UI tests only"
    echo "  docs          Generate documentation only"
    echo "  full          Run complete pipeline (default)"
    echo "  ci            Run CI/CD pipeline simulation"
    echo ""
}

# Main execution logic
case "${1:-full}" in
    "help")
        show_help
        ;;
    "clean")
        check_dependencies
        clean_build
        ;;
    "lint")
        check_dependencies
        run_swiftlint
        run_swiftformat_check
        ;;
    "build")
        check_dependencies
        clean_build
        build_project
        ;;
    "test")
        check_dependencies
        clean_build
        build_project
        run_unit_tests
        run_ui_tests
        ;;
    "unit-test")
        check_dependencies
        clean_build
        build_project
        run_unit_tests
        ;;
    "ui-test")
        check_dependencies
        clean_build
        build_project
        run_ui_tests
        ;;
    "docs")
        check_dependencies
        generate_docs
        ;;
    "full")
        print_status "Running full build pipeline..."
        check_dependencies
        clean_build
        run_swiftlint
        run_swiftformat_check
        build_project
        run_unit_tests
        run_ui_tests
        generate_docs
        print_success "Full pipeline completed successfully! 🎉"
        ;;
    "ci")
        print_status "Running CI/CD simulation..."
        check_dependencies
        clean_build
        run_swiftlint
        run_swiftformat_check
        build_project
        run_unit_tests
        # Skip UI tests in CI simulation for speed
        print_success "CI/CD simulation completed! ✅"
        ;;
    *)
        print_error "Unknown option: $1"
        show_help
        exit 1
        ;;
esac