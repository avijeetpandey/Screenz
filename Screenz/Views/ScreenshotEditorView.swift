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
    
    var body: some View {
        HSplitView {
            // Left side - Image Canvas
            ZStack {
                // Background
                if backgroundColor != .clear {
                    Rectangle()
                        .fill(backgroundColor.gradient)
                } else {
                    Rectangle()
                        .fill(.white)
                }
                
                // Screenshot canvas with drawing
                ScreenshotCanvas(
                    screenshot: screenshot,
                    selectedTool: selectedTool,
                    selectedColor: selectedColor,
                    lineWidth: lineWidth,
                    scale: canvasScale,
                    offset: canvasOffset,
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
        // Create a new image with the editing applied
        guard let originalImage = screenshot.image else { return }
        
        let size = originalImage.size
        let image = NSImage(size: size)
        
        image.lockFocus()
        
        // Draw background if set
        if backgroundColor != .clear {
            NSColor(backgroundColor).setFill()
            NSRect(origin: .zero, size: size).fill()
        }
        
        // Draw original image
        originalImage.draw(in: NSRect(origin: .zero, size: size))
        
        // Draw strokes
        for stroke in drawingStrokes {
            drawStrokeOnContext(stroke: stroke, size: size)
        }
        
        image.unlockFocus()
        
        // Save the edited screenshot
        let editedScreenshot = Screenshot(image: image, filename: "Edited-\(screenshot.filename)")
        screenshotService.screenshots.insert(editedScreenshot, at: 0)
        
        dismiss()
    }
    
    private func exportScreenshot() {
        // Implementation for exporting in different formats
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.png, .jpeg]
        panel.nameFieldStringValue = screenshot.filename
        
        panel.begin { result in
            if result == .OK, let url = panel.url {
                saveImageToURL(url: url)
            }
        }
    }
    
    private func saveImageToURL(url: URL) {
        guard let originalImage = screenshot.image else { return }
        
        let size = originalImage.size
        let image = NSImage(size: size)
        
        image.lockFocus()
        
        if backgroundColor != .clear {
            NSColor(backgroundColor).setFill()
            NSRect(origin: .zero, size: size).fill()
        }
        
        originalImage.draw(in: NSRect(origin: .zero, size: size))
        
        for stroke in drawingStrokes {
            drawStrokeOnContext(stroke: stroke, size: size)
        }
        
        image.unlockFocus()
        
        if let tiffData = image.tiffRepresentation,
           let bitmapRep = NSBitmapImageRep(data: tiffData) {
            
            let fileType: NSBitmapImageRep.FileType = url.pathExtension.lowercased() == "jpg" ? .jpeg : .png
            if let imageData = bitmapRep.representation(using: fileType, properties: [:]) {
                try? imageData.write(to: url)
            }
        }
    }
    
    private func drawStrokeOnContext(stroke: DrawingStroke, size: CGSize) {
        let context = NSGraphicsContext.current?.cgContext
        
        switch stroke.tool {
        case .pen, .highlighter:
            drawPenStroke(stroke: stroke, context: context)
        case .arrow:
            drawArrow(stroke: stroke, context: context)
        case .rectangle:
            drawRectangle(stroke: stroke, context: context)
        case .ellipse:
            drawEllipse(stroke: stroke, context: context)
        case .text:
            drawText(stroke: stroke, size: size)
        }
    }
    
    private func drawPenStroke(stroke: DrawingStroke, context: CGContext?) {
        guard let context = context, stroke.points.count > 1 else { return }
        
        context.setStrokeColor(stroke.color.cgColor)
        context.setLineWidth(stroke.lineWidth)
        context.setLineCap(.round)
        context.setLineJoin(.round)
        
        if stroke.tool == .highlighter {
            context.setAlpha(0.5)
        }
        
        context.beginPath()
        context.move(to: stroke.points[0])
        for point in stroke.points.dropFirst() {
            context.addLine(to: point)
        }
        context.strokePath()
        
        if stroke.tool == .highlighter {
            context.setAlpha(1.0)
        }
    }
    
    private func drawArrow(stroke: DrawingStroke, context: CGContext?) {
        guard let context = context, stroke.points.count >= 2 else { return }
        
        let start = stroke.points.first!
        let end = stroke.points.last!
        
        context.setStrokeColor(stroke.color.cgColor)
        context.setLineWidth(stroke.lineWidth)
        context.setLineCap(.round)
        
        // Draw line
        context.beginPath()
        context.move(to: start)
        context.addLine(to: end)
        context.strokePath()
        
        // Draw arrowhead
        let angle = atan2(end.y - start.y, end.x - start.x)
        let arrowLength: CGFloat = 20
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
    
    private func drawRectangle(stroke: DrawingStroke, context: CGContext?) {
        guard let context = context, stroke.points.count >= 2 else { return }
        
        let start = stroke.points.first!
        let end = stroke.points.last!
        
        let rect = CGRect(
            x: min(start.x, end.x),
            y: min(start.y, end.y),
            width: abs(end.x - start.x),
            height: abs(end.y - start.y)
        )
        
        context.setStrokeColor(stroke.color.cgColor)
        context.setLineWidth(stroke.lineWidth)
        context.stroke(rect)
    }
    
    private func drawEllipse(stroke: DrawingStroke, context: CGContext?) {
        guard let context = context, stroke.points.count >= 2 else { return }
        
        let start = stroke.points.first!
        let end = stroke.points.last!
        
        let rect = CGRect(
            x: min(start.x, end.x),
            y: min(start.y, end.y),
            width: abs(end.x - start.x),
            height: abs(end.y - start.y)
        )
        
        context.setStrokeColor(stroke.color.cgColor)
        context.setLineWidth(stroke.lineWidth)
        context.strokeEllipse(in: rect)
    }
    
    private func drawText(stroke: DrawingStroke, size: CGSize) {
        guard let text = stroke.text, let point = stroke.points.first else { return }
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: stroke.lineWidth * 4),
            .foregroundColor: stroke.color
        ]
        
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        attributedString.draw(at: point)
    }
}

struct ScreenshotCanvas: View {
    let screenshot: Screenshot
    let selectedTool: DrawingTool
    let selectedColor: Color
    let lineWidth: CGFloat
    let scale: CGFloat
    let offset: CGSize
    @Binding var drawingStrokes: [DrawingStroke]
    @Binding var currentStroke: [CGPoint]
    let onTextTap: (CGPoint) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Draw the actual screenshot image
                if let image = screenshot.image {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                // Drawing overlay
                Canvas { context, size in
                    // Draw existing strokes
                    for stroke in drawingStrokes {
                        drawStroke(context: context, stroke: stroke)
                    }
                    
                    // Draw current stroke being drawn
                    if !currentStroke.isEmpty {
                        let currentDrawingStroke = DrawingStroke(
                            tool: selectedTool,
                            points: currentStroke,
                            color: NSColor(selectedColor),
                            lineWidth: lineWidth,
                            text: nil
                        )
                        drawStroke(context: context, stroke: currentDrawingStroke)
                    }
                }
                .allowsHitTesting(true)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            if selectedTool == .text {
                                onTextTap(value.location)
                            } else if selectedTool == .rectangle || selectedTool == .ellipse || selectedTool == .arrow {
                                // For shapes, we want to replace the current stroke with start and end points
                                if currentStroke.isEmpty {
                                    currentStroke.append(value.startLocation)
                                }
                                if currentStroke.count == 1 {
                                    currentStroke.append(value.location)
                                } else {
                                    currentStroke[1] = value.location
                                }
                            } else {
                                // For pen and highlighter, add continuous points
                                currentStroke.append(value.location)
                            }
                        }
                        .onEnded { _ in
                            if !currentStroke.isEmpty && selectedTool != .text {
                                let stroke = DrawingStroke(
                                    tool: selectedTool,
                                    points: currentStroke,
                                    color: NSColor(selectedColor),
                                    lineWidth: lineWidth,
                                    text: nil
                                )
                                drawingStrokes.append(stroke)
                                currentStroke.removeAll()
                            }
                        }
                )
            }
        }
    }
    
    private func drawStroke(context: GraphicsContext, stroke: DrawingStroke) {
        switch stroke.tool {
        case .pen, .highlighter:
            drawPenStroke(context: context, stroke: stroke)
        case .arrow:
            drawArrow(context: context, stroke: stroke)
        case .rectangle:
            drawRectangle(context: context, stroke: stroke)
        case .ellipse:
            drawEllipse(context: context, stroke: stroke)
        case .text:
            drawText(context: context, stroke: stroke)
        }
    }
    
    private func drawPenStroke(context: GraphicsContext, stroke: DrawingStroke) {
        guard stroke.points.count > 1 else { return }
        
        var path = Path()
        path.move(to: stroke.points[0])
        for point in stroke.points.dropFirst() {
            path.addLine(to: point)
        }
        
        let strokeStyle = StrokeStyle(
            lineWidth: stroke.lineWidth,
            lineCap: .round,
            lineJoin: .round
        )
        
        var strokeColor = Color(stroke.color)
        if stroke.tool == .highlighter {
            strokeColor = strokeColor.opacity(0.5)
        }
        
        context.stroke(
            path,
            with: .color(strokeColor),
            style: strokeStyle
        )
    }
    
    private func drawArrow(context: GraphicsContext, stroke: DrawingStroke) {
        guard stroke.points.count >= 2 else { return }
        
        let start = stroke.points.first!
        let end = stroke.points.last!
        
        var path = Path()
        path.move(to: start)
        path.addLine(to: end)
        
        // Add arrowhead
        let angle = atan2(end.y - start.y, end.x - start.x)
        let arrowLength: CGFloat = max(15, stroke.lineWidth * 3)
        let arrowAngle: CGFloat = .pi / 6
        
        let arrowPoint1 = CGPoint(
            x: end.x - arrowLength * cos(angle - arrowAngle),
            y: end.y - arrowLength * sin(angle - arrowAngle)
        )
        let arrowPoint2 = CGPoint(
            x: end.x - arrowLength * cos(angle + arrowAngle),
            y: end.y - arrowLength * sin(angle + arrowAngle)
        )
        
        path.move(to: end)
        path.addLine(to: arrowPoint1)
        path.move(to: end)
        path.addLine(to: arrowPoint2)
        
        context.stroke(
            path,
            with: .color(Color(stroke.color)),
            style: StrokeStyle(lineWidth: stroke.lineWidth, lineCap: .round)
        )
    }
    
    private func drawRectangle(context: GraphicsContext, stroke: DrawingStroke) {
        guard stroke.points.count >= 2 else { return }
        
        let start = stroke.points.first!
        let end = stroke.points.last!
        
        let rect = CGRect(
            x: min(start.x, end.x),
            y: min(start.y, end.y),
            width: abs(end.x - start.x),
            height: abs(end.y - start.y)
        )
        
        context.stroke(
            Path(rect),
            with: .color(Color(stroke.color)),
            style: StrokeStyle(lineWidth: stroke.lineWidth)
        )
    }
    
    private func drawEllipse(context: GraphicsContext, stroke: DrawingStroke) {
        guard stroke.points.count >= 2 else { return }
        
        let start = stroke.points.first!
        let end = stroke.points.last!
        
        let rect = CGRect(
            x: min(start.x, end.x),
            y: min(start.y, end.y),
            width: abs(end.x - start.x),
            height: abs(end.y - start.y)
        )
        
        context.stroke(
            Path(ellipseIn: rect),
            with: .color(Color(stroke.color)),
            style: StrokeStyle(lineWidth: stroke.lineWidth)
        )
    }
    
    private func drawText(context: GraphicsContext, stroke: DrawingStroke) {
        guard let text = stroke.text, let point = stroke.points.first else { return }
        
        context.draw(
            Text(text)
                .font(.system(size: max(12, stroke.lineWidth * 3)))
                .foregroundColor(Color(stroke.color))
                .bold(),
            at: point,
            anchor: .topLeading
        )
    }
}
