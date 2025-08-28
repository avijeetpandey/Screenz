//
//  ContentView.swift
//  Screenz
//
//  Created by Avijeet Pandey on 28/08/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var screenshotService = ScreenshotService()
    @State private var selectedScreenshot: Screenshot?
    @State private var showingPreferences = false
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            HSplitView {
                // Elegant sidebar
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 32, weight: .light))
                            .foregroundColor(.accentColor)
                        
                        Text("Screenz")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                    
                    // Gallery list
                    if screenshotService.screenshots.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "photo.stack")
                                .font(.system(size: 24))
                                .foregroundColor(.secondary)
                            Text("No screenshots yet")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List(screenshotService.screenshots, id: \.id, selection: $selectedScreenshot) { screenshot in
                            ScreenshotRow(screenshot: screenshot) {
                                // Double-click to edit - navigate to editor
                                navigationPath.append(screenshot)
                            }
                            .tag(screenshot)
                        }
                        .listStyle(.sidebar)
                    }
                    
                    Spacer()
                    
                    // Permission warning
                    if !screenshotService.hasScreenRecordingPermission {
                        VStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                            Text("Permission Required")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(8)
                        .background(.orange.opacity(0.1))
                        .cornerRadius(6)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 12)
                    }
                }
                .frame(minWidth: 250, idealWidth: 280, maxWidth: 320)
                .background(.regularMaterial)
                
                // Main content area
                Group {
                    if let selectedScreenshot = selectedScreenshot {
                        ScreenshotDetailView(screenshot: selectedScreenshot) {
                            // Edit button action - navigate to editor
                            navigationPath.append(selectedScreenshot)
                        }
                    } else {
                        CaptureHomeView(screenshotService: screenshotService)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(minWidth: 900, minHeight: 600)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Preferences") {
                        showingPreferences = true
                    }
                    .buttonStyle(.bordered)
                }
            }
            .navigationDestination(for: Screenshot.self) { screenshot in
                ScreenshotEditorView(screenshot: screenshot, screenshotService: screenshotService)
            }
        }
        .sheet(isPresented: $showingPreferences) {
            PreferencesView()
        }
        .onReceive(screenshotService.$screenshots) { screenshots in
            // Automatically open editor for newly captured screenshots
            if let latestScreenshot = screenshots.first {
                selectedScreenshot = latestScreenshot
                navigationPath.append(latestScreenshot)
            }
        }
    }
}

struct ScreenshotRow: View {
    let screenshot: Screenshot
    let onDoubleClick: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            if let image = screenshot.image {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 35)
                    .clipped()
                    .cornerRadius(6)
            } else {
                RoundedRectangle(cornerRadius: 6)
                    .fill(.gray.opacity(0.3))
                    .frame(width: 50, height: 35)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                            .font(.caption)
                    )
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(screenshot.timestamp, style: .time)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text("\(Int(screenshot.originalSize.width))×\(Int(screenshot.originalSize.height))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
        .onTapGesture(count: 2) {
            onDoubleClick()
        }
    }
}

struct ScreenshotDetailView: View {
    let screenshot: Screenshot
    let onEdit: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Edit button
            HStack {
                Spacer()
                Button("Edit Screenshot") {
                    onEdit()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)
            
            // Screenshot preview
            if let image = screenshot.image {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.black.opacity(0.05))
                    .cornerRadius(12)
                    .padding()
            }
        }
        .navigationTitle(screenshot.filename)
        .background(.regularMaterial)
    }
}
