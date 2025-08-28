//
//  ScreenshotService.swift
//  Screenz
//
//  Created by Avijeet Pandey on 28/08/25.
//

import Foundation
import AppKit
import SwiftUI
import ScreenCaptureKit

@MainActor
class ScreenshotService: ObservableObject {
    @Published var screenshots: [Screenshot] = []
    @Published var isCapturing = false
    @Published var countdown: Int = 0
    @Published var hasScreenRecordingPermission = false
    
    private var countdownTimer: Timer?
    
    init() {
        checkScreenRecordingPermission()
    }
    
    func checkScreenRecordingPermission() {
        // For macOS 12.3+ use ScreenCaptureKit
        if #available(macOS 12.3, *) {
            Task {
                do {
                    _ = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
                    hasScreenRecordingPermission = true
                } catch {
                    hasScreenRecordingPermission = false
                }
            }
        } else {
            // For older macOS versions, assume permission is granted
            hasScreenRecordingPermission = true
        }
    }
    
    func captureFullScreen() async -> NSImage? {
        guard hasScreenRecordingPermission else {
            checkScreenRecordingPermission()
            return nil
        }
        
        if #available(macOS 12.3, *) {
            return await captureFullScreenWithScreenCaptureKit()
        } else {
            return await captureFullScreenLegacy()
        }
    }
    
    @available(macOS 12.3, *)
    private func captureFullScreenWithScreenCaptureKit() async -> NSImage? {
        do {
            let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
            
            guard let display = content.displays.first else { return nil }
            
            let filter = SCContentFilter(display: display, excludingApplications: [], exceptingWindows: [])
            let configuration = SCStreamConfiguration()
            configuration.width = Int(display.width)
            configuration.height = Int(display.height)
            
            let image = try await SCScreenshotManager.captureImage(contentFilter: filter, configuration: configuration)
            let nsImage = NSImage(cgImage: image, size: NSSize(width: image.width, height: image.height))
            saveScreenshot(image: nsImage)
            return nsImage
        } catch {
            print("Screen capture failed: \(error)")
            hasScreenRecordingPermission = false
            return nil
        }
    }
    
    private func captureFullScreenLegacy() async -> NSImage? {
        // For older macOS versions, use ScreenCaptureKit if available, otherwise return nil
        guard let screen = NSScreen.main else { return nil }
        
        // Since CGWindowListCreateImage is deprecated, we'll just return nil
        // This forces the app to use ScreenCaptureKit on modern systems
        print("Legacy screen capture not available on this macOS version")
        return nil
    }
    
    func captureWindow() async -> NSImage? {
        guard hasScreenRecordingPermission else {
            checkScreenRecordingPermission()
            return nil
        }
        
        if #available(macOS 12.3, *) {
            return await captureWindowWithScreenCaptureKit()
        } else {
            return await captureWindowLegacy()
        }
    }
    
    @available(macOS 12.3, *)
    private func captureWindowWithScreenCaptureKit() async -> NSImage? {
        do {
            let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
            
            // Get the frontmost window
            guard let window = content.windows.first else { return nil }
            
            let filter = SCContentFilter(desktopIndependentWindow: window)
            let configuration = SCStreamConfiguration()
            configuration.width = Int(window.frame.width)
            configuration.height = Int(window.frame.height)
            
            let image = try await SCScreenshotManager.captureImage(contentFilter: filter, configuration: configuration)
            let nsImage = NSImage(cgImage: image, size: NSSize(width: image.width, height: image.height))
            saveScreenshot(image: nsImage)
            return nsImage
        } catch {
            print("Window capture failed: \(error)")
            return nil
        }
    }
    
    private func captureWindowLegacy() async -> NSImage? {
        // For older macOS versions, since CGWindowListCreateImage is deprecated,
        // we'll return nil to force use of ScreenCaptureKit on modern systems
        print("Legacy window capture not available on this macOS version")
        return nil
    }
    
    func captureSelection(rect: CGRect) async {
        // For now, fall back to full screen capture and crop
        guard let fullScreenImage = await captureFullScreen() else { return }
        
        // Crop the image to the selection
        guard let cgImage = fullScreenImage.cgImage(forProposedRect: nil, context: nil, hints: nil),
              let croppedImage = cgImage.cropping(to: rect) else {
            return
        }
        
        let image = NSImage(cgImage: croppedImage, size: rect.size)
        saveScreenshot(image: image)
    }
    
    func captureWithTimer(seconds: Int, mode: CaptureMode) {
        countdown = seconds
        isCapturing = true
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            Task { @MainActor in
                guard let self = self else {
                    timer.invalidate()
                    return
                }
                
                self.countdown -= 1
                
                if self.countdown <= 0 {
                    timer.invalidate()
                    self.isCapturing = false
                    
                    switch mode {
                    case .fullScreen:
                        _ = await self.captureFullScreen()
                    case .window:
                        _ = await self.captureWindow()
                    default:
                        break
                    }
                }
            }
        }
    }
    
    private func saveScreenshot(image: NSImage) {
        let filename = "Screenshot_\(DateFormatter.filenameDateFormatter.string(from: Date())).png"
        let screenshot = Screenshot(image: image, filename: filename)
        screenshots.insert(screenshot, at: 0) // Insert at beginning for newest first
        
        // Save to Pictures/Screenz folder for better organization
        saveToPicturesFolder(image: image, filename: screenshot.filename)
    }
    
    private func saveToPicturesFolder(image: NSImage, filename: String) {
        guard let picturesURL = FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask).first else {
            return
        }
        
        // Create Screenz folder in Pictures
        let screenzURL = picturesURL.appendingPathComponent("Screenz")
        try? FileManager.default.createDirectory(at: screenzURL, withIntermediateDirectories: true)
        
        let fileURL = screenzURL.appendingPathComponent(filename)
        
        if let tiffData = image.tiffRepresentation,
           let bitmapRep = NSBitmapImageRep(data: tiffData),
           let pngData = bitmapRep.representation(using: .png, properties: [:]) {
            
            try? pngData.write(to: fileURL)
        }
    }
    
    func exportScreenshot(_ screenshot: Screenshot, format: ExportFormat, to url: URL) {
        // Implementation for exporting in different formats
        // This would handle PNG, JPG, PDF, TIFF exports
    }
}

enum ExportFormat: String, CaseIterable {
    case png = "PNG"
    case jpg = "JPG"
    case pdf = "PDF"
    case tiff = "TIFF"
}

// MARK: - DateFormatter Extension
extension DateFormatter {
    static let filenameDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return formatter
    }()
}
