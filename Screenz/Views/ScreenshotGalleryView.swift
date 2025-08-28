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
    
    var body: some View {
        List(screenshots, selection: $selectedScreenshot) { screenshot in
            ScreenshotThumbnailView(screenshot: screenshot)
                .tag(screenshot)
        }
        .navigationTitle("Screenshots")
        .listStyle(SidebarListStyle())
    }
}

struct ScreenshotThumbnailView: View {
    let screenshot: Screenshot
    
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(.gray.opacity(0.3))
                .frame(width: 60, height: 40)
                .overlay(
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(screenshot.filename)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(screenshot.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(Int(screenshot.originalSize.width))×\(Int(screenshot.originalSize.height))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}