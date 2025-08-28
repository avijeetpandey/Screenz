//
//  EditorToolbar.swift
//  Screenz
//
//  Created by Avijeet Pandey on 28/08/25.
//

import SwiftUI

struct EditorToolbar: View {
    @Binding var selectedTool: DrawingTool
    @Binding var selectedColor: Color
    @Binding var lineWidth: CGFloat
    @Binding var canvasScale: CGFloat
    @Binding var backgroundColor: Color
    @Binding var showingColorPicker: Bool
    @Binding var showingBackgroundOptions: Bool
    
    let onUndo: () -> Void
    let onRedo: () -> Void
    let onSave: () -> Void
    let onExport: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Drawing Tools Section
            Group {
                ToolButton(
                    icon: "pencil",
                    title: "Pen",
                    isSelected: selectedTool == .pen
                ) { selectedTool = .pen }
                
                ToolButton(
                    icon: "highlighter",
                    title: "Highlight",
                    isSelected: selectedTool == .highlighter
                ) { selectedTool = .highlighter }
                
                ToolButton(
                    icon: "arrow.up.right",
                    title: "Arrow",
                    isSelected: selectedTool == .arrow
                ) { selectedTool = .arrow }
                
                ToolButton(
                    icon: "rectangle",
                    title: "Rectangle",
                    isSelected: selectedTool == .rectangle
                ) { selectedTool = .rectangle }
                
                ToolButton(
                    icon: "circle",
                    title: "Circle",
                    isSelected: selectedTool == .ellipse
                ) { selectedTool = .ellipse }
                
                ToolButton(
                    icon: "textformat",
                    title: "Text",
                    isSelected: selectedTool == .text
                ) { selectedTool = .text }
            }
            
            Divider()
                .frame(height: 24)
            
            // Color and Style Controls
            Group {
                Button(action: { showingColorPicker = true }) {
                    Circle()
                        .fill(selectedColor)
                        .frame(width: 28, height: 28)
                        .overlay(
                            Circle()
                                .stroke(.primary, lineWidth: 2)
                        )
                }
                .buttonStyle(.plain)
                .help("Color Picker")
                
                VStack(spacing: 2) {
                    Text("Size")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Slider(value: $lineWidth, in: 1...20, step: 1)
                        .frame(width: 80)
                }
                
                Button(action: { showingBackgroundOptions = true }) {
                    Rectangle()
                        .fill(backgroundColor == .clear ?
                              LinearGradient(colors: [.clear], startPoint: .leading, endPoint: .trailing) :
                              LinearGradient(colors: [backgroundColor], startPoint: .leading, endPoint: .trailing))
                        .frame(width: 28, height: 28)
                        .overlay(
                            Rectangle()
                                .stroke(.primary, lineWidth: 2)
                        )
                        .cornerRadius(4)
                }
                .buttonStyle(.plain)
                .help("Background")
            }
            
            Divider()
                .frame(height: 24)
            
            // Zoom Controls
            Group {
                Button(action: { canvasScale = max(0.5, canvasScale - 0.25) }) {
                    Image(systemName: "minus.magnifyingglass")
                        .foregroundColor(.primary)
                }
                .buttonStyle(.bordered)
                .help("Zoom Out")
                
                Text("\(Int(canvasScale * 100))%")
                    .font(.caption)
                    .frame(width: 40)
                
                Button(action: { canvasScale = min(3.0, canvasScale + 0.25) }) {
                    Image(systemName: "plus.magnifyingglass")
                        .foregroundColor(.primary)
                }
                .buttonStyle(.bordered)
                .help("Zoom In")
                
                Button(action: { canvasScale = 1.0 }) {
                    Text("100%")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .help("Reset Zoom")
            }
            
            Divider()
                .frame(height: 24)
            
            // Undo/Redo
            Group {
                Button(action: onUndo) {
                    Image(systemName: "arrow.uturn.backward")
                        .foregroundColor(.primary)
                }
                .buttonStyle(.bordered)
                .help("Undo")
                
                Button(action: onRedo) {
                    Image(systemName: "arrow.uturn.forward")
                        .foregroundColor(.primary)
                }
                .buttonStyle(.bordered)
                .help("Redo")
            }
            
            Spacer()
            
            // Action Buttons
            Group {
                Button("Save", action: onSave)
                    .buttonStyle(.bordered)
                    .help("Save Edited Screenshot")
                
                Button("Export", action: onExport)
                    .buttonStyle(.borderedProminent)
                    .help("Export Screenshot")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.regularMaterial)
        .overlay(
            Rectangle()
                .stroke(.separator, lineWidth: 0.5),
            alignment: .bottom
        )
    }
}

struct CaptureToolbarView: View {
    @ObservedObject var screenshotService: ScreenshotService
    
    var body: some View {
        HStack {
            Button(action: {
                Task {
                    await screenshotService.captureFullScreen()
                }
            }) {
                Image(systemName: "display")
            }
            .help("Capture Full Screen (⌘⇧3)")
            
            Button(action: {
                Task {
                    await screenshotService.captureWindow()
                }
            }) {
                Image(systemName: "macwindow")
            }
            .help("Capture Window (⌘⇧4)")
        }
    }
}
