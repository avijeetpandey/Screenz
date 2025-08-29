//
//  ScreenshotGalleryView.swift
//  Screenz
//
//  Created by Avijeet Pandey on 28/08/25.
//

import SwiftUI

struct ScreenshotGalleryView: View {
    let screenshots: [Screenshot]
    @Binding var selectedScreenshot: Screenshot?
    let navigateToHome: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Enhanced Header with Home Button
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Gallery")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("\(screenshots.count) screenshot\(screenshots.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: navigateToHome) {
                    Image(systemName: "house.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
                .help("Go to Home")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.regularMaterial)
            
            Divider()
            
            // Enhanced Screenshot List
            if screenshots.isEmpty {
                // Empty State
                VStack(spacing: 16) {
                    Image(systemName: "photo.stack")
                        .font(.system(size: 48, weight: .ultraLight))
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 4) {
                        Text("No Screenshots")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Take your first screenshot to get started")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button("Start Capturing") {
                        navigateToHome()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.regularMaterial)
            } else {
                List(screenshots, selection: $selectedScreenshot) { screenshot in
                    EnhancedScreenshotThumbnailView(screenshot: screenshot)
                        .tag(screenshot)
                        .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                        .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .background(.regularMaterial)
                .scrollContentBackground(.hidden)
            }
        }
        .background(.regularMaterial)
    }
}

struct EnhancedScreenshotThumbnailView: View {
    let screenshot: Screenshot
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Enhanced Thumbnail with actual image
            Group {
                if let image = screenshot.image {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.primary.opacity(0.1), lineWidth: 1)
                        )
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.gray.opacity(0.2))
                        .frame(width: 60, height: 40)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                                .font(.caption)
                        )
                }
            }
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            
            // Enhanced Info Section
            VStack(alignment: .leading, spacing: 4) {
                // Filename with truncation
                Text(screenshot.filename)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                // Time and date
                HStack(spacing: 8) {
                    Label {
                        Text(screenshot.timestamp, style: .time)
                    } icon: {
                        Image(systemName: "clock")
                            .font(.caption2)
                    }
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text(screenshot.timestamp, style: .date)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                // Dimensions with icon
                HStack(spacing: 4) {
                    Image(systemName: "viewfinder")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text("\(Int(screenshot.originalSize.width)) × \(Int(screenshot.originalSize.height))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Action indicator on hover
            if isHovered {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .transition(.opacity.combined(with: .scale))
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isHovered ? .blue.opacity(0.05) : .clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isHovered ? .blue.opacity(0.2) : .clear, lineWidth: 1)
        )
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
