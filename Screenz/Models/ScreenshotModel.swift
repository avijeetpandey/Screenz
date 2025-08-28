//
//  ScreenshotModel.swift
//  Screenz
//
//  Created by Avijeet Pandey on 28/08/25.
//

import Foundation
import AppKit

struct Screenshot: Identifiable, Codable, Hashable {
    let id = UUID()
    let timestamp: Date
    let filename: String
    var imageData: Data
    let originalSize: CGSize
    
    init(image: NSImage, filename: String? = nil) {
        self.timestamp = Date()
        self.filename = filename ?? "Screenshot-\(DateFormatter.screenshotFormatter.string(from: Date())).png"
        self.originalSize = image.size
        
        // Convert NSImage to Data for storage
        if let tiffData = image.tiffRepresentation,
           let bitmapRep = NSBitmapImageRep(data: tiffData),
           let pngData = bitmapRep.representation(using: .png, properties: [:]) {
            self.imageData = pngData
        } else {
            self.imageData = Data()
        }
    }
    
    var image: NSImage? {
        return NSImage(data: imageData)
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Screenshot, rhs: Screenshot) -> Bool {
        lhs.id == rhs.id
    }
}

extension DateFormatter {
    static let screenshotFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        return formatter
    }()
}

enum CaptureMode {
    case fullScreen
    case window
    case selection
    case timed(seconds: Int)
}

enum DrawingTool {
    case pen
    case highlighter
    case arrow
    case rectangle
    case ellipse
    case text
}

struct DrawingStroke {
    let tool: DrawingTool
    let points: [CGPoint]
    let color: NSColor
    let lineWidth: CGFloat
    let text: String?
}
