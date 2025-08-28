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

// MARK: - Supporting UI Components
struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            Spacer()
        }
    }
}

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
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(8)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

struct ColorSelectionGrid: View {
    @Binding var selectedColor: Color
    
    private let colors: [Color] = [
        .red, .orange, .yellow, .green, .mint, .teal,
        .cyan, .blue, .indigo, .purple, .pink, .brown,
        .black, .gray, .white
    ]
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 8) {
            ForEach(colors, id: \.self) { color in
                Button(action: { selectedColor = color }) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: 24, height: 24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(selectedColor == color ? Color.blue : Color.clear, lineWidth: 2)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct BackgroundSelectionGrid: View {
    @Binding var backgroundColor: Color
    
    private let backgroundColors: [Color] = [
        .clear, .white, .black, .gray,
        .red, .orange, .yellow, .green,
        .blue, .purple, .pink, .mint,
        .indigo, .brown
    ]
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
            ForEach(backgroundColors, id: \.self) { color in
                Button(action: { backgroundColor = color }) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color == .clear ? Color.white : color)
                        .frame(width: 28, height: 28)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(backgroundColor == color ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                        )
                        .overlay(
                            color == .clear ?
                            Image(systemName: "nosign")
                                .foregroundColor(.red)
                                .font(.caption) : nil
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Screenshot Canvas View
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
                // Screenshot image
                if let image = screenshot.image {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                
                // Drawing overlay
                Canvas { context, size in
                    // Draw completed strokes
                    for stroke in drawingStrokes {
                        drawStroke(context: context, stroke: stroke, canvasSize: size)
                    }
                    
                    // Draw current stroke
                    if !currentStroke.isEmpty {
                        let currentDrawingStroke = DrawingStroke(
                            tool: selectedTool,
                            points: currentStroke,
                            color: NSColor(selectedColor),
                            lineWidth: lineWidth
                        )
                        drawStroke(context: context, stroke: currentDrawingStroke, canvasSize: size)
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let point = value.location
                            
                            if selectedTool == .text {
                                return
                            }
                            
                            if currentStroke.isEmpty {
                                currentStroke.append(point)
                            } else {
                                currentStroke.append(point)
                            }
                        }
                        .onEnded { value in
                            if selectedTool == .text {
                                onTextTap(value.location)
                                return
                            }
                            
                            if !currentStroke.isEmpty {
                                let stroke = DrawingStroke(
                                    tool: selectedTool,
                                    points: currentStroke,
                                    color: NSColor(selectedColor),
                                    lineWidth: lineWidth
                                )
                                drawingStrokes.append(stroke)
                                currentStroke.removeAll()
                            }
                        }
                )
            }
        }
    }
    
    private func drawStroke(context: GraphicsContext, stroke: DrawingStroke, canvasSize: CGSize) {
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
        
        let color = Color(stroke.color)
        let strokeColor = stroke.tool == .highlighter ? color.opacity(0.5) : color
        
        context.stroke(path, with: .color(strokeColor), lineWidth: stroke.lineWidth)
    }
    
    private func drawArrow(context: GraphicsContext, stroke: DrawingStroke) {
        guard stroke.points.count >= 2 else { return }
        
        let start = stroke.points.first!
        let end = stroke.points.last!
        
        var path = Path()
        path.move(to: start)
        path.addLine(to: end)
        
        context.stroke(path, with: .color(Color(stroke.color)), lineWidth: stroke.lineWidth)
        
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
        
        var arrowPath = Path()
        arrowPath.move(to: end)
        arrowPath.addLine(to: arrowPoint1)
        arrowPath.move(to: end)
        arrowPath.addLine(to: arrowPoint2)
        
        context.stroke(arrowPath, with: .color(Color(stroke.color)), lineWidth: stroke.lineWidth)
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
        
        let path = Path(rect)
        context.stroke(path, with: .color(Color(stroke.color)), lineWidth: stroke.lineWidth)
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
        
        let path = Path(ellipseIn: rect)
        context.stroke(path, with: .color(Color(stroke.color)), lineWidth: stroke.lineWidth)
    }
    
    private func drawText(context: GraphicsContext, stroke: DrawingStroke) {
        guard let text = stroke.text, let point = stroke.points.first else { return }
        
        let fontSize = max(12, stroke.lineWidth * 3)
        context.draw(
            Text(text)
                .font(.system(size: fontSize))
                .foregroundColor(Color(stroke.color)),
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
