//
//  SupportingViews.swift
//  Screenz
//
//  Created by Avijeet Pandey on 28/08/25.
//

import SwiftUI

// MARK: - Selection Capture View
struct SelectionCaptureView: View {
    @ObservedObject var screenshotService: ScreenshotService
    @Environment(\.dismiss) private var dismiss
    @State private var selectionRect: CGRect = .zero
    @State private var isDragging = false
    @State private var startPoint: CGPoint = .zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Semi-transparent overlay
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                // Selection rectangle
                if isDragging {
                    Rectangle()
                        .stroke(.white, lineWidth: 2)
                        .background(.clear)
                        .frame(
                            width: abs(selectionRect.width),
                            height: abs(selectionRect.height)
                        )
                        .position(
                            x: selectionRect.midX,
                            y: selectionRect.midY
                        )
                }
                
                // Instructions
                VStack {
                    Text("Click and drag to select area")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(.black.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    Spacer()
                }
                .padding()
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if !isDragging {
                            isDragging = true
                            startPoint = value.startLocation
                        }
                        
                        let currentPoint = value.location
                        selectionRect = CGRect(
                            x: min(startPoint.x, currentPoint.x),
                            y: min(startPoint.y, currentPoint.y),
                            width: abs(currentPoint.x - startPoint.x),
                            height: abs(currentPoint.y - startPoint.y)
                        )
                    }
                    .onEnded { _ in
                        if selectionRect.width > 10 && selectionRect.height > 10 {
                            Task {
                                await screenshotService.captureSelection(rect: selectionRect)
                            }
                        }
                        dismiss()
                    }
            )
        }
        .ignoresSafeArea()
    }
}

// MARK: - Text Annotation View
struct TextAnnotationView: View {
    @Binding var text: String
    let position: CGPoint
    let onSave: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add Text Annotation")
                .font(.headline)
            
            TextField("Enter text", text: $text)
                .textFieldStyle(.roundedBorder)
                .frame(width: 300)
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Button("Add") {
                    if !text.isEmpty {
                        onSave(text)
                        text = ""
                    }
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(text.isEmpty)
            }
        }
        .padding()
        .frame(width: 400, height: 200)
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
            Spacer()
        }
    }
}

// MARK: - Tool Button
struct ToolButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                Text(title)
                    .font(.caption2)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .foregroundColor(isSelected ? .white : .primary)
            .background(isSelected ? .blue : .gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Color Selection Grid
struct ColorSelectionGrid: View {
    @Binding var selectedColor: Color
    
    private let colors: [Color] = [
        .red, .orange, .yellow, .green, .blue, .purple,
        .pink, .brown, .indigo, .cyan, .mint, .gray,
        .black, .white
    ]
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
            ForEach(colors, id: \.self) { color in
                Button(action: { selectedColor = color }) {
                    Circle()
                        .fill(color)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Circle()
                                .stroke(selectedColor == color ? .blue : .gray.opacity(0.3), lineWidth: selectedColor == color ? 2 : 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Background Selection Grid
struct BackgroundSelectionGrid: View {
    @Binding var backgroundColor: Color
    
    private let backgroundColors: [Color] = [
        .clear, .white, .black, .gray.opacity(0.1),
        .blue, .pink, .green, .purple,
        .yellow, .mint, .red, .indigo, .brown
    ]
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
            ForEach(backgroundColors, id: \.self) { color in
                Button(action: { backgroundColor = color }) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(color == .clear ? .white : color)
                        .frame(height: 32)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(backgroundColor == color ? .blue : .gray.opacity(0.3), lineWidth: backgroundColor == color ? 2 : 1)
                        )
                        .overlay(
                            // Special indicator for transparent background
                            color == .clear ?
                            Text("None")
                                .font(.caption2)
                                .foregroundColor(.gray) : nil
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Screenshot Canvas
struct ScreenshotCanvas: NSViewRepresentable {
    let screenshot: Screenshot
    let selectedTool: DrawingTool
    let selectedColor: Color
    let lineWidth: CGFloat
    let scale: CGFloat
    let offset: CGSize
    @Binding var drawingStrokes: [DrawingStroke]
    @Binding var currentStroke: [CGPoint]
    let onTextTap: (CGPoint) -> Void
    
    func makeNSView(context: Context) -> CanvasNSView {
        let canvasView = CanvasNSView()
        canvasView.coordinator = context.coordinator
        return canvasView
    }
    
    func updateNSView(_ nsView: CanvasNSView, context: Context) {
        nsView.screenshot = screenshot
        nsView.selectedTool = selectedTool
        nsView.selectedColor = NSColor(selectedColor)
        nsView.lineWidth = lineWidth
        nsView.drawingStrokes = drawingStrokes
        nsView.currentStroke = currentStroke
        nsView.onTextTap = onTextTap
        nsView.needsDisplay = true
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        let parent: ScreenshotCanvas
        
        init(_ parent: ScreenshotCanvas) {
            self.parent = parent
        }
    }
}

// MARK: - Canvas NSView
class CanvasNSView: NSView {
    var coordinator: ScreenshotCanvas.Coordinator?
    var screenshot: Screenshot?
    var selectedTool: DrawingTool = .pen
    var selectedColor: NSColor = .red
    var lineWidth: CGFloat = 3.0
    var drawingStrokes: [DrawingStroke] = []
    var currentStroke: [CGPoint] = []
    var onTextTap: ((CGPoint) -> Void)?
    
    private var isDrawing = false
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        
        // Draw screenshot
        if let image = screenshot?.image {
            let imageRect = NSRect(origin: .zero, size: image.size)
            image.draw(in: imageRect)
        }
        
        // Draw completed strokes
        for stroke in drawingStrokes {
            drawStroke(stroke, in: context)
        }
        
        // Draw current stroke in progress
        if !currentStroke.isEmpty && selectedTool != .text {
            let stroke = DrawingStroke(
                tool: selectedTool,
                points: currentStroke,
                color: selectedColor,
                lineWidth: lineWidth
            )
            drawStroke(stroke, in: context)
        }
    }
    
    private func drawStroke(_ stroke: DrawingStroke, in context: CGContext) {
        context.saveGState()
        
        switch stroke.tool {
        case .pen, .highlighter:
            drawPenStroke(stroke, in: context)
        case .arrow:
            drawArrowStroke(stroke, in: context)
        case .rectangle:
            drawRectangleStroke(stroke, in: context)
        case .ellipse:
            drawEllipseStroke(stroke, in: context)
        case .text:
            drawTextStroke(stroke)
        }
        
        context.restoreGState()
    }
    
    private func drawPenStroke(_ stroke: DrawingStroke, in context: CGContext) {
        guard stroke.points.count > 1 else { return }
        
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
    
    private func drawArrowStroke(_ stroke: DrawingStroke, in context: CGContext) {
        guard stroke.points.count >= 2 else { return }
        
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
        
        context.beginPath()
        context.move(to: end)
        context.addLine(to: arrowPoint1)
        context.move(to: end)
        context.addLine(to: arrowPoint2)
        context.strokePath()
    }
    
    private func drawRectangleStroke(_ stroke: DrawingStroke, in context: CGContext) {
        guard stroke.points.count >= 2 else { return }
        
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
    
    private func drawEllipseStroke(_ stroke: DrawingStroke, in context: CGContext) {
        guard stroke.points.count >= 2 else { return }
        
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
    
    private func drawTextStroke(_ stroke: DrawingStroke) {
        guard let text = stroke.text, let point = stroke.points.first else { return }
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: max(12, stroke.lineWidth * 3)),
            .foregroundColor: stroke.color
        ]
        
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        attributedString.draw(at: point)
    }
    
    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        
        if selectedTool == .text {
            onTextTap?(point)
            return
        }
        
        isDrawing = true
        currentStroke = [point]
        needsDisplay = true
    }
    
    override func mouseDragged(with event: NSEvent) {
        guard isDrawing else { return }
        
        let point = convert(event.locationInWindow, from: nil)
        
        switch selectedTool {
        case .pen, .highlighter:
            currentStroke.append(point)
        case .arrow, .rectangle, .ellipse:
            if currentStroke.count >= 2 {
                currentStroke[1] = point
            } else {
                currentStroke.append(point)
            }
        case .text:
            break
        }
        
        needsDisplay = true
    }
    
    override func mouseUp(with event: NSEvent) {
        guard isDrawing && !currentStroke.isEmpty else { return }
        
        isDrawing = false
        
        let stroke = DrawingStroke(
            tool: selectedTool,
            points: currentStroke,
            color: selectedColor,
            lineWidth: lineWidth
        )
        
        coordinator?.parent.drawingStrokes.append(stroke)
        coordinator?.parent.currentStroke = []
        currentStroke = []
        needsDisplay = true
    }
}

// MARK: - Screenshot Canvas View (SwiftUI Canvas-based)
struct ScreenshotCanvasView: View {
    let screenshot: Screenshot
    let selectedTool: DrawingTool
    let selectedColor: Color
    let lineWidth: CGFloat
    let backgroundColor: Color
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

// MARK: - Preferences View
struct PreferencesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var defaultSaveLocation = "Pictures/Screenz"
    @State private var defaultFormat = "PNG"
    @State private var includeTimestamp = true
    @State private var showCaptureFlash = true
    @State private var playShutterSound = false
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Preferences")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            
            Form {
                Section("Capture Settings") {
                    HStack {
                        Text("Default Save Location:")
                        Spacer()
                        Text(defaultSaveLocation)
                            .foregroundColor(.secondary)
                        Button("Change...") {
                            // Open folder picker
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    HStack {
                        Text("Default Format:")
                        Spacer()
                        Picker("Format", selection: $defaultFormat) {
                            Text("PNG").tag("PNG")
                            Text("JPEG").tag("JPEG")
                            Text("TIFF").tag("TIFF")
                        }
                        .pickerStyle(.menu)
                        .frame(width: 100)
                    }
                    
                    Toggle("Include timestamp in filename", isOn: $includeTimestamp)
                    Toggle("Show capture flash", isOn: $showCaptureFlash)
                    Toggle("Play shutter sound", isOn: $playShutterSound)
                }
                
                Section("Keyboard Shortcuts") {
                    HStack {
                        Text("Capture Full Screen:")
                        Spacer()
                        Text("⌘⇧3")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Capture Window:")
                        Spacer()
                        Text("⌘⇧4")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Capture Selection:")
                        Spacer()
                        Text("⌘⇧5")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version:")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build:")
                        Spacer()
                        Text("100")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .formStyle(.grouped)
        }
        .frame(width: 500, height: 400)
    }
}
