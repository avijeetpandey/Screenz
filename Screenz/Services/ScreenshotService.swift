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
        
        // Always use ScreenCaptureKit for macOS 15.2+
        return await captureFullScreenWithScreenCaptureKit()
    }
    
    @available(macOS 12.3, *)
    private func captureFullScreenWithScreenCaptureKit() async -> NSImage? {
        do {
            let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
            guard let display = content.displays.first else { return nil }
            
            let filter = SCContentFilter(display: display, excludingWindows: [])
            let configuration = SCStreamConfiguration()
            configuration.width = Int(display.width)
            configuration.height = Int(display.height)
            configuration.captureResolution = .best
            
            let image = try await SCScreenshotManager.captureImage(contentFilter: filter, configuration: configuration)
            return NSImage(cgImage: image, size: NSSize(width: image.width, height: image.height))
        } catch {
            print("Failed to capture screen: \(error)")
            return nil
        }
    }
    
    func captureWindow() async -> NSImage? {
        // Implementation for window capture using ScreenCaptureKit
        guard hasScreenRecordingPermission else {
            checkScreenRecordingPermission()
            return nil
        }
        
        do {
            let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
            guard let window = content.windows.first else { return await captureFullScreen() }
            
            let filter = SCContentFilter(desktopIndependentWindow: window)
            let configuration = SCStreamConfiguration()
            configuration.captureResolution = .best
            
            let image = try await SCScreenshotManager.captureImage(contentFilter: filter, configuration: configuration)
            return NSImage(cgImage: image, size: NSSize(width: image.width, height: image.height))
        } catch {
            print("Failed to capture window: \(error)")
            return await captureFullScreen() // Fallback to full screen
        }
    }
    
    func captureSelection(rect: CGRect) async -> NSImage? {
        guard let fullScreenImage = await captureFullScreen() else { return nil }
        
        // Crop the image to the selection rectangle
        guard let cgImage = fullScreenImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }
        
        let croppedCGImage = cgImage.cropping(to: rect)
        guard let croppedImage = croppedCGImage else { return nil }
        
        return NSImage(cgImage: croppedImage, size: rect.size)
    }
    
    func captureSelection() async -> NSImage? {
        guard hasScreenRecordingPermission else {
            checkScreenRecordingPermission()
            return nil
        }
        
        // Use the native macOS screencapture tool for selection
        return await withCheckedContinuation { continuation in
            let task = Process()
            task.launchPath = "/usr/sbin/screencapture"
            
            // Create temporary file path
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("temp_selection.png")
            
            // Arguments: -s for selection, -x for no sound, path to save
            task.arguments = ["-s", "-x", tempURL.path]
            
            task.terminationHandler = { process in
                DispatchQueue.main.async {
                    if process.terminationStatus == 0 {
                        // Successfully captured, load the image
                        if let image = NSImage(contentsOf: tempURL) {
                            // Clean up temp file
                            try? FileManager.default.removeItem(at: tempURL)
                            continuation.resume(returning: image)
                        } else {
                            continuation.resume(returning: nil)
                        }
                    } else {
                        // User cancelled or failed
                        continuation.resume(returning: nil)
                    }
                }
            }
            
            task.launch()
        }
    }
    
    func addScreenshot(_ image: NSImage) {
        let timestamp = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let filename = "Screenshot-\(formatter.string(from: timestamp)).png"
        
        let screenshot = Screenshot(image: image, filename: filename)
        screenshots.insert(screenshot, at: 0)
    }
    
    func deleteScreenshot(_ screenshot: Screenshot) {
        screenshots.removeAll { $0.id == screenshot.id }
    }
    
    func deleteAllScreenshots() {
        screenshots.removeAll()
    }
    
    // Add timed capture functionality
    func captureWithTimer(seconds: Int, mode: CaptureMode) {
        guard !isCapturing else { return }
        
        isCapturing = true
        countdown = seconds
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            if self.countdown > 1 {
                self.countdown -= 1
            } else {
                timer.invalidate()
                self.countdown = 0
                self.isCapturing = false
                
                // Perform the capture based on mode
                Task {
                    let image: NSImage?
                    switch mode {
                    case .fullScreen:
                        image = await self.captureFullScreen()
                    case .window:
                        image = await self.captureWindow()
                    case .selection:
                        // For selection, we'll just do full screen as default
                        image = await self.captureFullScreen()
                    }
                    
                    if let capturedImage = image {
                        self.addScreenshot(capturedImage)
                    }
                }
            }
        }
    }
    
    func saveScreenshotToDisk(_ screenshot: Screenshot, to url: URL) async throws {
        guard let image = screenshot.image else {
            throw ScreenshotError.invalidImage
        }
        
        guard let tiffData = image.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiffData) else {
            throw ScreenshotError.conversionFailed
        }
        
        let fileType: NSBitmapImageRep.FileType = url.pathExtension.lowercased() == "jpg" || url.pathExtension.lowercased() == "jpeg" ? .jpeg : .png
        let properties: [NSBitmapImageRep.PropertyKey: Any] = fileType == .jpeg ? [.compressionFactor: 0.9] : [:]
        
        guard let imageData = bitmapRep.representation(using: fileType, properties: properties) else {
            throw ScreenshotError.conversionFailed
        }
        
        try imageData.write(to: url)
    }
}

enum ScreenshotError: Error {
    case invalidImage
    case conversionFailed
    case saveFailed
    
    var localizedDescription: String {
        switch self {
        case .invalidImage:
            return "Invalid image data"
        case .conversionFailed:
            return "Failed to convert image"
        case .saveFailed:
            return "Failed to save image"
        }
    }
}

// MARK: - DateFormatter Extension
extension DateFormatter {
    static let filenameDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return formatter
    }()
}
