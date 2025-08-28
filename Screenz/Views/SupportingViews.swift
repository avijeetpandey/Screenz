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
                
                Button("Add Text") {
                    onSave(text)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(text.isEmpty)
            }
        }
        .padding(20)
        .frame(width: 350, height: 150)
    }
}

// MARK: - Color Picker View
struct ColorPickerView: View {
    @Binding var selectedColor: Color
    @Environment(\.dismiss) private var dismiss
    
    private let predefinedColors: [Color] = [
        .red, .orange, .yellow, .green, .blue, .purple, .pink,
        .black, .gray, .white, .brown, .cyan, .mint, .indigo
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Choose Color")
                .font(.headline)
            
            // Predefined colors grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(predefinedColors, id: \.self) { color in
                    ColorCircleView(
                        color: color,
                        isSelected: selectedColor == color,
                        onTap: { selectedColor = color }
                    )
                }
            }
            
            Divider()
            
            // Custom color picker
            ColorPicker("Custom Color", selection: $selectedColor)
                .labelsHidden()
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Button("Select") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(20)
        .frame(width: 350, height: 300)
    }
}

// MARK: - Color Circle View
struct ColorCircleView: View {
    let color: Color
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Circle()
                .fill(color)
                .frame(width: 30, height: 30)
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.primary : Color.secondary, lineWidth: isSelected ? 3 : 1)
                )
                .overlay(
                    // Add checkmark for selected color
                    isSelected ?
                    Image(systemName: "checkmark")
                        .foregroundColor(color == .white || color == .yellow ? .black : .white)
                        .font(.caption.bold()) : nil
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Background Options View
struct BackgroundOptionsView: View {
    @Binding var backgroundColor: Color
    @Environment(\.dismiss) private var dismiss
    
    private let predefinedBackgrounds: [Color] = [
        .clear, .white, .black, .gray, .red, .blue, .green, .purple, .orange, .yellow
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Background Options")
                .font(.headline)
            
            // Background options grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 8) {
                ForEach(predefinedBackgrounds, id: \.self) { color in
                    BackgroundOptionTile(
                        color: color,
                        isSelected: backgroundColor == color,
                        onTap: { backgroundColor = color }
                    )
                }
            }
            
            Divider()
            
            // Custom background color
            if backgroundColor != .clear {
                ColorPicker("Custom Background", selection: $backgroundColor)
            }
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Button("Apply") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(20)
        .frame(width: 350, height: 300)
    }
}

struct BackgroundOptionTile: View {
    let color: Color
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Rectangle()
                .fill(color == .clear ?
                      Color.white.opacity(0.1) :
                      color)
                .frame(width: 50, height: 40)
                .overlay(
                    color == .clear ?
                    Text("None")
                        .font(.caption2)
                        .foregroundColor(.primary) :
                    nil
                )
                .overlay(
                    Rectangle()
                        .stroke(isSelected ? .primary : .secondary, lineWidth: isSelected ? 3 : 1)
                )
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.blue)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Tool Button for Editor
struct ToolButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(title)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .white : .secondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue : Color.secondary.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Color Selection Grid
struct ColorSelectionGrid: View {
    @Binding var selectedColor: Color
    
    private let colors: [Color] = [
        .red, .orange, .yellow, .green, .blue, .purple, .pink,
        .black, .gray, .white, .brown, .cyan, .mint, .indigo
    ]
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 6) {
            ForEach(colors, id: \.self) { color in
                Button(action: { selectedColor = color }) {
                    Circle()
                        .fill(color)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Circle()
                                .stroke(selectedColor == color ? Color.primary : Color.secondary.opacity(0.3),
                                       lineWidth: selectedColor == color ? 2 : 1)
                        )
                        .overlay(
                            selectedColor == color ?
                            Image(systemName: "checkmark")
                                .font(.caption2.bold())
                                .foregroundColor(color == .white || color == .yellow ? .black : .white) : nil
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
    
    private let backgrounds: [Color] = [
        .clear, .white, .black, .gray.opacity(0.1), .gray.opacity(0.2),
        .blue.opacity(0.1), .green.opacity(0.1), .red.opacity(0.1), .yellow.opacity(0.1)
    ]
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 6) {
            ForEach(backgrounds, id: \.self) { color in
                Button(action: { backgroundColor = color }) {
                    Rectangle()
                        .fill(color == .clear ?
                              LinearGradient(colors: [.white, .gray.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                              LinearGradient(colors: [color], startPoint: .leading, endPoint: .trailing))
                        .frame(width: 32, height: 24)
                        .overlay(
                            color == .clear ?
                            Text("None")
                                .font(.caption2)
                                .foregroundColor(.primary) : nil
                        )
                        .overlay(
                            Rectangle()
                                .stroke(backgroundColor == color ? Color.primary : Color.secondary.opacity(0.3),
                                       lineWidth: backgroundColor == color ? 2 : 1)
                        )
                        .cornerRadius(4)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Preferences View
struct PreferencesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var defaultSaveLocation = ""
    @State private var autoOpenEditor = true
    @State private var captureSound = true
    @State private var defaultFormat = "PNG"
    
    private let formats = ["PNG", "JPEG", "TIFF"]
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with close button
            HStack {
                Text("Preferences")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Close")
            }
            .padding()
            
            Divider()
            
            // Settings content
            VStack(alignment: .leading, spacing: 16) {
                Group {
                    HStack {
                        Text("Default Save Location:")
                            .frame(width: 150, alignment: .leading)
                        
                        TextField("Choose folder", text: $defaultSaveLocation)
                            .textFieldStyle(.roundedBorder)
                        
                        Button("Browse") {
                            let panel = NSOpenPanel()
                            panel.canChooseDirectories = true
                            panel.canChooseFiles = false
                            panel.allowsMultipleSelection = false
                            
                            if panel.runModal() == .OK,
                               let url = panel.url {
                                defaultSaveLocation = url.path
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    HStack {
                        Text("Default Format:")
                            .frame(width: 150, alignment: .leading)
                        
                        Picker("Format", selection: $defaultFormat) {
                            ForEach(formats, id: \.self) { format in
                                Text(format).tag(format)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 100)
                        
                        Spacer()
                    }
                    
                    Toggle("Auto-open editor after capture", isOn: $autoOpenEditor)
                    
                    Toggle("Play capture sound", isOn: $captureSound)
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Action buttons
            HStack {
                Button("Reset to Defaults") {
                    defaultSaveLocation = ""
                    autoOpenEditor = true
                    captureSound = true
                    defaultFormat = "PNG"
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Save") {
                    // Save preferences logic here
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .frame(width: 500, height: 400)
        .background(.regularMaterial)
    }
}
