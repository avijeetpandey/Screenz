//
//  ScreenshotEditorView.swift
//  Screenz
//
//  Created by Avijeet Pandey on 28/08/25.
//

import SwiftUI
import AppKit

struct ScreenshotEditorView: View {
    let screenshot: Screenshot
    @ObservedObject var screenshotService: ScreenshotService
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedTool: DrawingTool = .pen
    @State private var selectedColor: Color = .red
    @State private var lineWidth: CGFloat = 3.0
    @State private var canvasScale: CGFloat = 1.0
    @State private var canvasOffset: CGSize = .zero
    @State private var drawingStrokes: [DrawingStroke] = []
    @State private var undoStack: [DrawingStroke] = []
    @State private var currentStroke: [CGPoint] = []
    @State private var showingTextEditor = false
    @State private var textInput = ""
    @State private var textPosition: CGPoint = .zero
    @State private var backgroundColor: Color = .clear
    
    // Helper to get the current background option with gradient support
    private var currentBackgroundFill: AnyView {
        // Find matching gradient option
        let gradientOptions: [(Color, LinearGradient)] = [
            (.blue, LinearGradient(colors: [.blue.opacity(0.7), .purple.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)),
            (.pink, LinearGradient(colors: [.pink.opacity(0.6), .orange.opacity(0.6)], startPoint: .leading, endPoint: .trailing)),
            (.green, LinearGradient(colors: [.green.opacity(0.5), .blue.opacity(0.5)], startPoint: .top, endPoint: .bottom)),
            (.purple, LinearGradient(colors: [.purple.opacity(0.4), .pink.opacity(0.4), .orange.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing)),
            (.yellow, LinearGradient(colors: [.yellow.opacity(0.3), .orange.opacity(0.4)], startPoint: .top, endPoint: .bottom)),
            (.mint, LinearGradient(colors: [.mint.opacity(0.4), .cyan.opacity(0.4)], startPoint: .leading, endPoint: .trailing)),
            (.red, LinearGradient(colors: [.red.opacity(0.3), .pink.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)),
            (.indigo, LinearGradient(colors: [.indigo.opacity(0.5), .blue.opacity(0.5), .cyan.opacity(0.3)], startPoint: .top, endPoint: .bottom)),
            (.brown, LinearGradient(colors: [.brown.opacity(0.3), .orange.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
        ]
        
        // Check if current background color matches a gradient option
        if let gradientMatch = gradientOptions.first(where: { $0.0 == backgroundColor }) {
            return AnyView(gradientMatch.1)
        } else if backgroundColor != .clear {
            return AnyView(backgroundColor)
        } else {
            return AnyView(Color.clear)
        }
    }
    
    var body: some View {
        HSplitView {
            // Left side - Image Canvas
            ZStack {
                // Enhanced Background with gradient support
                if backgroundColor != .clear {
                    currentBackgroundFill
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Color.white
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                // Screenshot canvas with drawing
                ScreenshotCanvasView(
                    screenshot: screenshot,
                    selectedTool: selectedTool,
                    selectedColor: selectedColor,
                    lineWidth: lineWidth,
                    backgroundColor: backgroundColor,
                    drawingStrokes: $drawingStrokes,
                    currentStroke: $currentStroke,
                    onTextTap: { position in
                        textPosition = position
                        showingTextEditor = true
                    }
                )
                .scaleEffect(canvasScale)
                .offset(canvasOffset)
                .clipped()
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            canvasScale = max(0.5, min(3.0, value))
                        }
                        .simultaneously(with:
                            DragGesture()
                                .onChanged { value in
                                    if selectedTool == .pen || selectedTool == .highlighter {
                                        return
                                    }
                                    canvasOffset = value.translation
                                }
                        )
                )
            }
            .frame(minWidth: 400)
            
            // Right side - Editing Panel
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Edit Tools")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("Close Editor")
                }
                .padding()
                
                Divider()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Drawing Tools Section
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Drawing Tools", icon: "pencil")
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                                ToolButton(icon: "pencil", title: "Pen", isSelected: selectedTool == .pen) {
                                    selectedTool = .pen
                                }
                                
                                ToolButton(icon: "highlighter", title: "Highlight", isSelected: selectedTool == .highlighter) {
                                    selectedTool = .highlighter
                                }
                                
                                ToolButton(icon: "textformat", title: "Text", isSelected: selectedTool == .text) {
                                    selectedTool = .text
                                }
                                
                                ToolButton(icon: "arrow.up.right", title: "Arrow", isSelected: selectedTool == .arrow) {
                                    selectedTool = .arrow
                                }
                                
                                ToolButton(icon: "rectangle", title: "Rectangle", isSelected: selectedTool == .rectangle) {
                                    selectedTool = .rectangle
                                }
                                
                                ToolButton(icon: "circle", title: "Circle", isSelected: selectedTool == .ellipse) {
                                    selectedTool = .ellipse
                                }
                            }
                        }
                        
                        Divider()
                        
                        // Color and Style Section
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Style", icon: "paintbrush")
                            
                            VStack(spacing: 16) {
                                // Color Selection
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Color")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    ColorSelectionGrid(selectedColor: $selectedColor)
                                }
                                
                                // Line Width
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Brush Size")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        
                                        Spacer()
                                        
                                        Text("\(Int(lineWidth))")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Slider(value: $lineWidth, in: 1...20, step: 1) {
                                        Text("Line Width")
                                    } minimumValueLabel: {
                                        Image(systemName: "minus")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    } maximumValueLabel: {
                                        Image(systemName: "plus")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .accentColor(.blue)
                                }
                                
                                // Background Color
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Background")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    BackgroundSelectionGrid(backgroundColor: $backgroundColor)
                                }
                            }
                        }
                        
                        Divider()
                        
                        // View Controls Section
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "View", icon: "magnifyingglass")
                            
                            VStack(spacing: 12) {
                                // Zoom Controls
                                HStack {
                                    Text("Zoom")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Spacer()
                                    
                                    Text("\(Int(canvasScale * 100))%")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                HStack(spacing: 8) {
                                    Button(action: { canvasScale = max(0.5, canvasScale - 0.25) }) {
                                        Image(systemName: "minus.magnifyingglass")
                                    }
                                    .buttonStyle(.bordered)
                                    .disabled(canvasScale <= 0.5)
                                    
                                    Slider(value: $canvasScale, in: 0.5...3.0, step: 0.25)
                                        .accentColor(.blue)
                                    
                                    Button(action: { canvasScale = min(3.0, canvasScale + 0.25) }) {
                                        Image(systemName: "plus.magnifyingglass")
                                    }
                                    .buttonStyle(.bordered)
                                    .disabled(canvasScale >= 3.0)
                                }
                                
                                Button("Reset View") {
                                    canvasScale = 1.0
                                    canvasOffset = .zero
                                }
                                .buttonStyle(.bordered)
                                .frame(maxWidth: .infinity)
                            }
                        }
                        
                        Divider()
                        
                        // Actions Section
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Actions", icon: "square.and.arrow.up")
                            
                            VStack(spacing: 8) {
                                HStack(spacing: 8) {
                                    Button(action: undoLastStroke) {
                                        Label("Undo", systemImage: "arrow.uturn.backward")
                                    }
                                    .buttonStyle(.bordered)
                                    .disabled(drawingStrokes.isEmpty)
                                    
                                    Button(action: redoLastStroke) {
                                        Label("Redo", systemImage: "arrow.uturn.forward")
                                    }
                                    .buttonStyle(.bordered)
                                    .disabled(undoStack.isEmpty)
                                }
                                
                                Button(action: clearAll) {
                                    Label("Clear All", systemImage: "trash")
                                }
                                .buttonStyle(.bordered)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .disabled(drawingStrokes.isEmpty)
                                
                                Button(action: saveEditedScreenshot) {
                                    Label("Save Changes", systemImage: "checkmark.circle.fill")
                                }
                                .buttonStyle(.borderedProminent)
                                .frame(maxWidth: .infinity)
                                
                                Button(action: exportScreenshot) {
                                    Label("Export", systemImage: "square.and.arrow.up")
                                }
                                .buttonStyle(.bordered)
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    .padding()
                }
            }
            .frame(width: 280)
            .background(.regularMaterial)
        }
        .navigationTitle("Edit: \(screenshot.filename)")
        .sheet(isPresented: $showingTextEditor) {
            TextAnnotationView(
                text: $textInput,
                position: textPosition,
                onSave: addTextAnnotation
            )
        }
    }
    
    private func undoLastStroke() {
        if !drawingStrokes.isEmpty {
            let removedStroke = drawingStrokes.removeLast()
            undoStack.append(removedStroke)
        }
    }
    
    private func redoLastStroke() {
        if !undoStack.isEmpty {
            let restoredStroke = undoStack.removeLast()
            drawingStrokes.append(restoredStroke)
        }
    }
    
    private func clearAll() {
        undoStack.append(contentsOf: drawingStrokes)
        drawingStrokes.removeAll()
    }
    
    private func addTextAnnotation(text: String) {
        let textStroke = DrawingStroke(
            tool: .text,
            points: [textPosition],
            color: NSColor(selectedColor),
            lineWidth: lineWidth,
            text: text
        )
        drawingStrokes.append(textStroke)
        undoStack.removeAll()
    }
    
    private func saveEditedScreenshot() {
        guard let originalImage = screenshot.image else {
            print("Error: No original image found")
            return
        }
        
        // Create the edited image using Core Graphics
        guard let editedImage = createEditedImageUsingCoreGraphics() else {
            print("Failed to create edited image")
            return
        }
        
        // Create timestamp for filename
        let timestamp = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let editedFilename = "Edited_\(formatter.string(from: timestamp)).png"
        
        // Save the edited screenshot using the service's addScreenshot method
        let editedScreenshot = Screenshot(image: editedImage, filename: editedFilename)
        screenshotService.screenshots.insert(editedScreenshot, at: 0)
        
        print("✅ Saved edited screenshot: \(editedFilename)")
        dismiss()
    }
    
    private func exportScreenshot() {
        guard let originalImage = screenshot.image else {
            print("No image to export")
            return
        }
        
        // Create the edited image using Core Graphics
        guard let editedImage = createEditedImageUsingCoreGraphics() else {
            print("Failed to create edited image")
            return
        }
        
        // Convert to PNG data
        guard let tiffData = editedImage.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiffData),
              let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
            print("Failed to convert image to PNG")
            return
        }
        
        // Create filename with timestamp
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = formatter.string(from: Date())
        let filename = "Screenz_\(timestamp).png"
        
        // Use NSSavePanel to request user permission and save location
        let savePanel = NSSavePanel()
        savePanel.title = "Export Screenshot"
        savePanel.message = "Choose where to save your edited screenshot"
        savePanel.nameFieldStringValue = filename
        savePanel.allowedContentTypes = [.png]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        
        // Set default directory to Desktop if possible
        if let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first {
            savePanel.directoryURL = desktopURL
        }
        
        savePanel.begin { result in
            if result == .OK, let url = savePanel.url {
                do {
                    try pngData.write(to: url)
                    print("✅ Screenshot exported successfully to: \(url.lastPathComponent)")
                    
                    // Show success notification on main thread
                    DispatchQueue.main.async {
                        // You can add a success toast notification here if desired
                        NSSound.beep()
                    }
                } catch {
                    print("❌ Export failed: \(error.localizedDescription)")
                    
                    // Show error alert on main thread
                    DispatchQueue.main.async {
                        let alert = NSAlert()
                        alert.messageText = "Export Failed"
                        alert.informativeText = "Could not save the screenshot: \(error.localizedDescription)"
                        alert.alertStyle = .warning
                        alert.addButton(withTitle: "OK")
                        alert.runModal()
                    }
                }
            }
        }
    }
    
    // NEW: Core Graphics implementation that actually works
    private func createEditedImageUsingCoreGraphics() -> NSImage? {
        guard let originalImage = screenshot.image else { return nil }
        
        let originalSize = originalImage.size
        // Scale down large images for better display/export (max 2048px on longest side)
        let maxDimension: CGFloat = 2048
        let scale = min(1.0, maxDimension / max(originalSize.width, originalSize.height))
        let scaledImageSize = CGSize(width: originalSize.width * scale, height: originalSize.height * scale)
        
        // Add padding around the image - increased to 108px
        let padding: CGFloat = 220
        let finalSize = CGSize(
            width: scaledImageSize.width + (padding * 2),
            height: scaledImageSize.height + (padding * 2)
        )
        
        // Create a new image representation with proper aspect ratio preservation
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
              let context = CGContext(data: nil,
                                    width: Int(finalSize.width),
                                    height: Int(finalSize.height),
                                    bitsPerComponent: 8,
                                    bytesPerRow: 0,
                                    space: colorSpace,
                                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil
        }
        
        // Set the coordinate system to match NSImage (do NOT flip)
        // This prevents the upside-down issue
        
        // Fill the entire canvas with background color if set
        if backgroundColor != .clear {
            let nsColor = NSColor(backgroundColor)
            context.setFillColor(nsColor.cgColor)
            context.fill(CGRect(origin: .zero, size: finalSize))
        } else {
            // Fill with white background if no color is selected
            context.setFillColor(CGColor.white)
            context.fill(CGRect(origin: .zero, size: finalSize))
        }
        
        // Calculate the centered position for the screenshot with proper aspect ratio
        let imageRect = CGRect(
            x: padding,
            y: padding,
            width: scaledImageSize.width,
            height: scaledImageSize.height
        )
        
        // Draw the original screenshot in the center with padding, preserving aspect ratio
        if let cgImage = originalImage.cgImage(forProposedRect: nil, context: nil, hints: nil) {
            // Ensure the image is drawn with correct aspect ratio
            context.draw(cgImage, in: imageRect)
        }
        
        // Draw all strokes (scaled and positioned correctly)
        for stroke in drawingStrokes {
            drawStrokeInContext(context: context, stroke: stroke, imageSize: scaledImageSize, scale: scale, offset: CGPoint(x: padding, y: padding))
        }
        
        // Create NSImage from context with proper size and aspect ratio
        guard let cgImage = context.makeImage() else { return nil }
        let resultImage = NSImage(cgImage: cgImage, size: finalSize)
        
        return resultImage
    }
    
    // NEW: Core Graphics stroke drawing that actually works
    private func drawStrokeInContext(context: CGContext, stroke: DrawingStroke, imageSize: CGSize, scale: CGFloat = 1.0, offset: CGPoint = .zero) {
        let nsColor = stroke.color
        context.saveGState()
        
        switch stroke.tool {
        case .pen, .highlighter:
            context.setStrokeColor(nsColor.cgColor)
            context.setLineWidth(stroke.lineWidth * scale)
            context.setLineCap(.round)
            context.setLineJoin(.round)
            
            if stroke.tool == .highlighter {
                context.setAlpha(0.5)
            }
            
            if stroke.points.count > 1 {
                context.beginPath()
                let firstPoint = CGPoint(
                    x: (stroke.points[0].x * scale) + offset.x,
                    y: (stroke.points[0].y * scale) + offset.y
                )
                context.move(to: firstPoint)
                
                for point in stroke.points.dropFirst() {
                    let cgPoint = CGPoint(
                        x: (point.x * scale) + offset.x,
                        y: (point.y * scale) + offset.y
                    )
                    context.addLine(to: cgPoint)
                }
                context.strokePath()
            }
            
        case .arrow:
            if stroke.points.count >= 2 {
                let start = CGPoint(
                    x: (stroke.points[0].x * scale) + offset.x,
                    y: (stroke.points[0].y * scale) + offset.y
                )
                let end = CGPoint(
                    x: (stroke.points.last!.x * scale) + offset.x,
                    y: (stroke.points.last!.y * scale) + offset.y
                )
                
                context.setStrokeColor(nsColor.cgColor)
                context.setLineWidth(stroke.lineWidth * scale)
                context.setLineCap(.round)
                
                // Draw line
                context.beginPath()
                context.move(to: start)
                context.addLine(to: end)
                context.strokePath()
                
                // Draw arrowhead
                let angle = atan2(end.y - start.y, end.x - start.x)
                let arrowLength: CGFloat = max(15, stroke.lineWidth * 3 * scale)
                let arrowAngle: CGFloat = .pi / 6
                
                let arrowPoint1 = CGPoint(
                    x: end.x - arrowLength * cos(angle - arrowAngle),
                    y: end.y - arrowLength * sin(angle - arrowAngle)
                )
                let arrowPoint2 = CGPoint(
                    x: end.x - arrowLength * cos(angle + arrowAngle),
                    y: end.y - arrowLength * sin(angle + arrowAngle)
                )
                
                context.beginPath()
                context.move(to: end)
                context.addLine(to: arrowPoint1)
                context.move(to: end)
                context.addLine(to: arrowPoint2)
                context.strokePath()
            }
            
        case .rectangle:
            if stroke.points.count >= 2 {
                let start = stroke.points[0]
                let end = stroke.points.last!
                
                let rect = CGRect(
                    x: (min(start.x, end.x) * scale) + offset.x,
                    y: (min(start.y, end.y) * scale) + offset.y,
                    width: abs(end.x - start.x) * scale,
                    height: abs(end.y - start.y) * scale
                )
                
                context.setStrokeColor(nsColor.cgColor)
                context.setLineWidth(stroke.lineWidth * scale)
                context.stroke(rect)
            }
            
        case .ellipse:
            if stroke.points.count >= 2 {
                let start = stroke.points[0]
                let end = stroke.points.last!
                
                let rect = CGRect(
                    x: (min(start.x, end.x) * scale) + offset.x,
                    y: (min(start.y, end.y) * scale) + offset.y,
                    width: abs(end.x - start.x) * scale,
                    height: abs(end.y - start.y) * scale
                )
                
                context.setStrokeColor(nsColor.cgColor)
                context.setLineWidth(stroke.lineWidth * scale)
                context.strokeEllipse(in: rect)
            }
            
        case .text:
            if let text = stroke.text, let point = stroke.points.first {
                let fontSize = max(12, stroke.lineWidth * 3 * scale)
                let font = NSFont.systemFont(ofSize: fontSize)
                
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: nsColor
                ]
                
                let attributedString = NSAttributedString(string: text, attributes: attributes)
                let textPoint = CGPoint(
                    x: (point.x * scale) + offset.x,
                    y: (point.y * scale) + offset.y
                )
                
                // Draw text using Core Text
                let line = CTLineCreateWithAttributedString(attributedString)
                context.textPosition = textPoint
                CTLineDraw(line, context)
            }
        }
        
        context.restoreGState()
    }
}
