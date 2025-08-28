# Screenz 📸

A powerful and elegant screenshot capture and editing application for macOS, built with SwiftUI and modern macOS technologies.

![Screenz App Screenshot](https://img.shields.io/badge/Platform-macOS%2013.0+-blue.svg)
![Swift Version](https://img.shields.io/badge/Swift-5.9+-orange.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## ✨ Features

### 🎯 Screenshot Capture
- **Full Screen Capture** - Capture entire desktop with one click
- **Window Capture** - Capture specific application windows  
- **Selection Capture** - Draw to select custom regions with precision
- **Timed Capture** - Set countdown timer for delayed screenshots
- **Auto-save** - Screenshots automatically saved to organized folders
- **Instant Preview** - Immediate preview after capture

### 🎨 Advanced Image Editor
- **Side-by-Side Layout** - Professional editing interface with image canvas and tool panel
- **Comprehensive Drawing Tools**:
  - 🖊️ **Pen Tool** - Smooth freehand drawing with pressure sensitivity
  - 🖍️ **Highlighter** - Semi-transparent highlighting for emphasis
  - ➡️ **Arrow Tool** - Smart arrows with auto-sizing arrowheads
  - ⬜ **Rectangle & Circle** - Perfect geometric shapes
  - 📝 **Text Annotations** - Custom text with size and color control
  
- **Beautiful Gradient Backgrounds** (9 stunning options):
  - 🌅 **Sunset** - Pink to orange horizontal gradient
  - 🌊 **Ocean** - Green to blue vertical gradient  
  - 🌌 **Aurora** - Purple, pink, orange multi-color diagonal
  - 🏔️ **Deep Ocean** - Indigo to blue to cyan vertical
  - 🍃 **Cool Mint** - Mint to cyan horizontal
  - 🌹 **Rose** - Red to pink diagonal
  - 🌍 **Earth** - Brown to orange diagonal
  - 💙 **Blue Purple** - Blue to purple diagonal
  - ☀️ **Warm** - Yellow to orange vertical

- **Advanced Styling**:
  - 🎨 Color palette with 14 predefined colors + custom picker
  - 📏 Adjustable brush size (1-20 pixels)
  - 🔍 Zoom controls (50% to 300%) with gesture support
  - ↩️ Full undo/redo history
  - 🗑️ Clear all with confirmation

### 🖥️ Modern macOS Interface
- **Native SwiftUI Design** - Perfect integration with macOS design language
- **Elegant Sidebar Gallery** - Organized screenshot library with thumbnails
- **Live Preview** - Real-time editing with instant visual feedback
- **Friction-free Workflow** - No popups or modal dialogs, everything accessible
- **Adaptive Appearance** - Automatic dark/light mode support
- **Keyboard Shortcuts** - Quick access to all major functions

### 🔐 Privacy & Security
- **Screen Recording Permissions** - Proper macOS permission handling
- **Sandboxed Application** - Secure execution environment
- **Local Storage Only** - All data stays on your machine
- **No Analytics** - Complete privacy, no data collection

## 🚀 Quick Start

### Requirements
- **macOS 13.0 Ventura** or later
- **Xcode 15.0** or later (for development)
- **Screen Recording Permission** (granted on first use)

### Installation

#### Option 1: Build from Source
```bash
# Clone the repository
git clone https://github.com/yourusername/Screenz.git
cd Screenz

# Open in Xcode
open Screenz.xcodeproj

# Build and run (⌘+R)
```

#### Option 2: Download Release
1. Download the latest release from [Releases](https://github.com/yourusername/Screenz/releases)
2. Drag `Screenz.app` to your Applications folder
3. Launch and grant Screen Recording permission when prompted

### First Launch Setup

1. **Grant Permissions**: 
   - System will prompt for Screen Recording access
   - Go to System Settings > Privacy & Security > Screen Recording
   - Enable Screenz

2. **Choose Storage Location**:
   - Default: `~/Pictures/Screenz/`
   - Custom location can be set in preferences

3. **Start Capturing**:
   - Use capture buttons in the main interface
   - Screenshots appear automatically in the sidebar
   - Double-click any screenshot to edit

## 🎮 Usage Guide

### Taking Screenshots

| Capture Type | Method | Description |
|-------------|--------|-------------|
| **Full Screen** | Click "Full Screen" | Captures entire primary display |
| **Window** | Click "Window" → Select | Click on any window to capture |
| **Selection** | Click "Selection" → Draw | Drag to select custom area |
| **Timed** | Click "Timed" → Set timer | 3-10 second countdown capture |

### Editing Screenshots

1. **Open Editor**: Double-click any screenshot in sidebar
2. **Select Tool**: Choose from pen, highlighter, arrow, shapes, or text
3. **Choose Style**: Pick colors, adjust brush size, select background
4. **Edit Away**: Draw, annotate, and enhance your screenshot
5. **Save/Export**: Use toolbar buttons to save or export

### Keyboard Shortcuts

| Action | Shortcut | Description |
|--------|----------|-------------|
| Full Screen Capture | `⌘+1` | Instant full screen |
| Selection Capture | `⌘+2` | Selection mode |
| Undo | `⌘+Z` | Undo last edit |
| Redo | `⌘+⇧+Z` | Redo last undone edit |
| Save | `⌘+S` | Save current edit |
| Export | `⌘+E` | Export screenshot |

## 🛠️ Development Setup

### Prerequisites
```bash
# Ensure you have Xcode Command Line Tools
xcode-select --install

# Verify Swift version
swift --version  # Should be 5.9+
```

### Project Structure
```
Screenz/
├── ScreenzApp.swift          # App entry point
├── ContentView.swift         # Main app interface
├── Models/
│   └── ScreenshotModel.swift # Screenshot data model
├── Services/
│   └── ScreenshotService.swift # Core capture logic
└── Views/
    ├── CaptureHomeView.swift     # Capture interface
    ├── ScreenshotGalleryView.swift # Gallery sidebar
    ├── ScreenshotEditorView.swift  # Main editor
    ├── EditorToolbar.swift         # Editor tools
    └── SupportingViews.swift       # UI components
```

### Key Technologies
- **SwiftUI** - Modern declarative UI framework
- **Core Graphics** - Image processing and drawing
- **ScreenCaptureKit** - macOS screen capture APIs
- **Combine** - Reactive programming
- **FileManager** - Local storage management

### Building
```bash
# Debug build
xcodebuild -scheme Screenz -configuration Debug

# Release build  
xcodebuild -scheme Screenz -configuration Release

# Archive for distribution
xcodebuild archive -scheme Screenz -archivePath build/Screenz.xcarchive
```

## 🤝 Contributing

We welcome contributions! Here's how to get started:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### Development Guidelines
- Follow Swift naming conventions
- Write unit tests for new features
- Update documentation for API changes
- Test on multiple macOS versions
- Ensure accessibility compliance

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Apple** - For the amazing SwiftUI and ScreenCaptureKit APIs
- **SF Symbols** - For the beautiful iconography
- **macOS Design Guidelines** - For interface inspiration

## 📧 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/Screenz/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/Screenz/discussions)
- **Email**: support@screenz.app

## 🗺️ Roadmap

- [ ] **Cloud Sync** - iCloud integration for cross-device access
- [ ] **Advanced Annotations** - More shape tools and text formatting
- [ ] **Batch Processing** - Edit multiple screenshots simultaneously
- [ ] **Plugin System** - Third-party tool integration
- [ ] **Video Capture** - Screen recording capabilities
- [ ] **OCR Integration** - Text extraction from screenshots

---

**Made with ❤️ for the macOS community**

*Screenz - Capture, Edit, Share. Effortlessly.*
