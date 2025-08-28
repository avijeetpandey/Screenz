//
//  CaptureHomeView.swift
//  Screenz
//
//  Created by Avijeet Pandey on 28/08/25.
//

import SwiftUI

struct CaptureHomeView: View {
    @ObservedObject var screenshotService: ScreenshotService
    @State private var showingSelectionCapture = false
    
    var body: some View {
        VStack(spacing: 40) {
            if screenshotService.isCapturing {
                // Elegant countdown view
                VStack(spacing: 24) {
                    Text("Capturing in...")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Text("\(screenshotService.countdown)")
                        .font(.system(size: 80, weight: .bold, design: .rounded))
                        .foregroundColor(.accentColor)
                        .scaleEffect(screenshotService.countdown > 0 ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: screenshotService.countdown)
                    
                    Text("Get ready!")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(40)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
            } else {
                // Welcome section
                VStack(spacing: 16) {
                    Image(systemName: "camera.macro")
                        .font(.system(size: 60, weight: .ultraLight))
                        .foregroundColor(.accentColor)
                    
                    VStack(spacing: 8) {
                        Text("Ready to Capture")
                            .font(.title)
                            .fontWeight(.semibold)
                        
                        Text("Choose your capture method below")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Permission warning if needed
                if !screenshotService.hasScreenRecordingPermission {
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Screen Recording Permission Required")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text("Please grant screen recording permission in System Preferences > Privacy & Security")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button("Open Settings") {
                            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture")!)
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(16)
                    .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.orange.opacity(0.3), lineWidth: 1)
                    )
                }
                
                // Capture options in elegant grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                    CaptureCard(
                        title: "Full Screen",
                        subtitle: "⌘⇧3",
                        icon: "display",
                        color: .blue
                    ) {
                        Task {
                            await screenshotService.captureFullScreen()
                        }
                    }
                    
                    CaptureCard(
                        title: "Selection",
                        subtitle: "⌘⇧4",
                        icon: "viewfinder.rectangular",
                        color: .green
                    ) {
                        showingSelectionCapture = true
                    }
                    
                    CaptureCard(
                        title: "Window",
                        subtitle: "⌘⇧5",
                        icon: "macwindow",
                        color: .orange
                    ) {
                        Task {
                            await screenshotService.captureWindow()
                        }
                    }
                    
                    // Updated Timed Capture Card with proper menu integration
                    TimedCaptureCard(screenshotService: screenshotService)
                }
                .frame(maxWidth: 500)
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.regularMaterial)
        .sheet(isPresented: $showingSelectionCapture) {
            SelectionCaptureView(screenshotService: screenshotService)
        }
    }
}

struct CaptureCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 32, weight: .light))
                    .foregroundColor(.white)
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .frame(height: 120)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [color, color.opacity(0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.1), value: false)
    }
}

struct TimedCaptureCard: View {
    @ObservedObject var screenshotService: ScreenshotService
    
    var body: some View {
        Menu {
            Button("3 seconds") {
                screenshotService.captureWithTimer(seconds: 3, mode: .fullScreen)
            }
            Button("5 seconds") {
                screenshotService.captureWithTimer(seconds: 5, mode: .fullScreen)
            }
            Button("10 seconds") {
                screenshotService.captureWithTimer(seconds: 10, mode: .fullScreen)
            }
        } label: {
            CaptureCard(
                title: "Timed",
                subtitle: "⌘⇧T",
                icon: "timer",
                color: .purple
            ) { }
        }
    }
}
