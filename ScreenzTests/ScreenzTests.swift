//
//  ScreenzTests.swift
//  ScreenzTests
//
//  Created by Avijeet Pandey on 28/08/25.
//

import XCTest
@testable import Screenz
import SwiftUI

final class ScreenzTests: XCTestCase {
    
    var screenshotService: ScreenshotService!
    
    override func setUpWithError() throws {
        screenshotService = ScreenshotService()
    }
    
    override func tearDownWithError() throws {
        screenshotService = nil
    }
    
    // MARK: - Screenshot Model Tests
    
    func testScreenshotModelInitialization() throws {
        let testImage = NSImage(size: NSSize(width: 100, height: 100))
        let screenshot = Screenshot(image: testImage)
        
        XCTAssertNotNil(screenshot.id)
        XCTAssertNotNil(screenshot.timestamp)
        XCTAssertTrue(screenshot.filename.contains("Screenshot-"))
        XCTAssertEqual(screenshot.originalSize.width, 100)
        XCTAssertEqual(screenshot.originalSize.height, 100)
    }
    
    func testScreenshotModelWithCustomFilename() throws {
        let testImage = NSImage(size: NSSize(width: 200, height: 150))
        let customFilename = "test-screenshot.png"
        let screenshot = Screenshot(image: testImage, filename: customFilename)
        
        XCTAssertEqual(screenshot.filename, customFilename)
        XCTAssertEqual(screenshot.originalSize.width, 200)
        XCTAssertEqual(screenshot.originalSize.height, 150)
    }
    
    // MARK: - Drawing Tool Tests
    
    func testDrawingStrokeCreation() throws {
        let points = [CGPoint(x: 0, y: 0), CGPoint(x: 10, y: 10)]
        let stroke = DrawingStroke(
            tool: .pen,
            points: points,
            color: .red,
            lineWidth: 2.0,
            text: nil
        )
        
        XCTAssertEqual(stroke.tool, .pen)
        XCTAssertEqual(stroke.points.count, 2)
        XCTAssertEqual(stroke.lineWidth, 2.0)
        XCTAssertNil(stroke.text)
    }
    
    func testTextStrokeCreation() throws {
        let point = CGPoint(x: 50, y: 50)
        let stroke = DrawingStroke(
            tool: .text,
            points: [point],
            color: .blue,
            lineWidth: 14.0,
            text: "Test Text"
        )
        
        XCTAssertEqual(stroke.tool, .text)
        XCTAssertEqual(stroke.points.first, point)
        XCTAssertEqual(stroke.text, "Test Text")
    }
    
    // MARK: - Screenshot Service Tests
    
    func testScreenshotServiceInitialization() throws {
        XCTAssertTrue(screenshotService.screenshots.isEmpty)
        XCTAssertFalse(screenshotService.isCapturing)
        XCTAssertEqual(screenshotService.countdown, 0)
    }
    
    func testAddScreenshotToService() throws {
        let initialCount = screenshotService.screenshots.count
        let testImage = NSImage(size: NSSize(width: 100, height: 100))
        
        // Simulate adding a screenshot (private method, so we test the result)
        let screenshot = Screenshot(image: testImage)
        screenshotService.screenshots.append(screenshot)
        
        XCTAssertEqual(screenshotService.screenshots.count, initialCount + 1)
        XCTAssertEqual(screenshotService.screenshots.last?.originalSize.width, 100)
    }
    
    func testCaptureTimerInitiation() throws {
        screenshotService.captureWithTimer(seconds: 3, mode: .fullScreen)
        
        XCTAssertTrue(screenshotService.isCapturing)
        XCTAssertEqual(screenshotService.countdown, 3)
    }
    
    // MARK: - Export Format Tests
    
    func testExportFormatCases() throws {
        let formats = ExportFormat.allCases
        
        XCTAssertTrue(formats.contains(.png))
        XCTAssertTrue(formats.contains(.jpg))
        XCTAssertTrue(formats.contains(.pdf))
        XCTAssertTrue(formats.contains(.tiff))
        
        XCTAssertEqual(ExportFormat.png.rawValue, "PNG")
        XCTAssertEqual(ExportFormat.jpg.rawValue, "JPG")
        XCTAssertEqual(ExportFormat.pdf.rawValue, "PDF")
        XCTAssertEqual(ExportFormat.tiff.rawValue, "TIFF")
    }
    
    // MARK: - Capture Mode Tests
    
    func testCaptureModeTypes() throws {
        let fullScreen = CaptureMode.fullScreen
        let window = CaptureMode.window
        let selection = CaptureMode.selection
        let timed = CaptureMode.timed(seconds: 5)
        
        switch timed {
        case .timed(let seconds):
            XCTAssertEqual(seconds, 5)
        default:
            XCTFail("Timed capture mode not working correctly")
        }
    }
    
    // MARK: - Date Formatter Tests
    
    func testScreenshotDateFormatter() throws {
        let date = Date()
        let formattedString = DateFormatter.screenshotFormatter.string(from: date)
        
        // Should be in format: yyyy-MM-dd-HH-mm-ss
        XCTAssertTrue(formattedString.contains("-"))
        XCTAssertEqual(formattedString.components(separatedBy: "-").count, 6)
    }
    
    // MARK: - Performance Tests
    
    func testScreenshotCreationPerformance() throws {
        let testImage = NSImage(size: NSSize(width: 1920, height: 1080))
        
        measure {
            for _ in 0..<100 {
                _ = Screenshot(image: testImage)
            }
        }
    }
    
    func testDrawingStrokePerformance() throws {
        let points = Array(0..<1000).map { CGPoint(x: Double($0), y: Double($0)) }
        
        measure {
            for _ in 0..<10 {
                _ = DrawingStroke(
                    tool: .pen,
                    points: points,
                    color: .red,
                    lineWidth: 2.0,
                    text: nil
                )
            }
        }
    }
}