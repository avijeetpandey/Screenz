//
//  ScreenshotModel.swift
//  Screenz
//
//  Created by Avijeet Pandey on 28/08/25.
//

import SwiftUI
import AppKit

// MARK: - Screenshot Model
struct Screenshot: Identifiable, Hashable {
    let id = UUID()
    let image: NSImage?
    let filename: String
    let dateTaken: Date
    let originalSize: CGSize
    
    // Computed property for timestamp (used by ContentView and ScreenshotGalleryView)
    var timestamp: Date {
        return dateTaken
    }
    
    init(image: NSImage?, filename: String) {
        self.image = image
        self.filename = filename
        self.dateTaken = Date()
        self.originalSize = image?.size ?? CGSize(width: 0, height: 0)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Screenshot, rhs: Screenshot) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Drawing Tools
enum DrawingTool: CaseIterable {
    case pen
    case highlighter
    case text
    case arrow
    case rectangle
    case ellipse
    
    var systemImage: String {
        switch self {
        case .pen: return "pencil"
        case .highlighter: return "highlighter"
        case .text: return "textformat"
        case .arrow: return "arrow.up.right"
        case .rectangle: return "rectangle"
        case .ellipse: return "circle"
        }
    }
    
    var title: String {
        switch self {
        case .pen: return "Pen"
        case .highlighter: return "Highlight"
        case .text: return "Text"
        case .arrow: return "Arrow"
        case .rectangle: return "Rectangle"
        case .ellipse: return "Circle"
        }
    }
}

// MARK: - Drawing Stroke
struct DrawingStroke: Identifiable {
    let id = UUID()
    let tool: DrawingTool
    let points: [CGPoint]
    let color: NSColor
    let lineWidth: CGFloat
    let text: String?
    
    init(tool: DrawingTool, points: [CGPoint], color: NSColor, lineWidth: CGFloat, text: String? = nil) {
        self.tool = tool
        self.points = points
        self.color = color
        self.lineWidth = lineWidth
        self.text = text
    }
}

// MARK: - Capture Mode
enum CaptureMode: CaseIterable {
    case fullScreen
    case window
    case selection
    
    var title: String {
        switch self {
        case .fullScreen: return "Full Screen"
        case .window: return "Window"
        case .selection: return "Selection"
        }
    }
    
    var systemImage: String {
        switch self {
        case .fullScreen: return "display"
        case .window: return "macwindow"
        case .selection: return "selection.pin.in.out"
        }
    }
}
