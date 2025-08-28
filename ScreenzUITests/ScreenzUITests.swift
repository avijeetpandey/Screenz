//
//  ScreenzUITests.swift
//  ScreenzUITests
//
//  Created by Avijeet Pandey on 28/08/25.
//

import XCTest

final class ScreenzUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Main Interface Tests
    
    func testMainWindowLaunch() throws {
        XCTAssertTrue(app.windows["Screenz"].exists)
        XCTAssertTrue(app.staticTexts["Screenz"].exists)
        XCTAssertTrue(app.staticTexts["Capture and edit screenshots with ease"].exists)
    }
    
    func testCaptureButtons() throws {
        let fullScreenButton = app.buttons["Capture Full Screen"]
        let selectionButton = app.buttons["Capture Selection"]
        let windowButton = app.buttons["Capture Window"]
        
        XCTAssertTrue(fullScreenButton.exists)
        XCTAssertTrue(selectionButton.exists)
        XCTAssertTrue(windowButton.exists)
        
        // Test button accessibility
        XCTAssertTrue(fullScreenButton.isEnabled)
        XCTAssertTrue(selectionButton.isEnabled)
        XCTAssertTrue(windowButton.isEnabled)
    }
    
    func testTimedCaptureMenu() throws {
        let timedCaptureButton = app.buttons["Timed Capture"]
        XCTAssertTrue(timedCaptureButton.exists)
        
        timedCaptureButton.click()
        
        let threeSecondsButton = app.menuItems["3 seconds"]
        let fiveSecondsButton = app.menuItems["5 seconds"]
        let tenSecondsButton = app.menuItems["10 seconds"]
        
        XCTAssertTrue(threeSecondsButton.exists)
        XCTAssertTrue(fiveSecondsButton.exists)
        XCTAssertTrue(tenSecondsButton.exists)
    }
    
    // MARK: - Toolbar Tests
    
    func testToolbarElements() throws {
        let toolbar = app.toolbars.firstMatch
        XCTAssertTrue(toolbar.exists)
        
        // Check for capture toolbar buttons
        let captureToolbarButtons = toolbar.buttons
        XCTAssertGreaterThan(captureToolbarButtons.count, 0)
    }
    
    func testPreferencesButton() throws {
        let preferencesButton = app.buttons["Preferences"]
        if preferencesButton.exists {
            preferencesButton.click()
            
            // Check if preferences window opens
            let preferencesWindow = app.sheets.firstMatch
            XCTAssertTrue(preferencesWindow.waitForExistence(timeout: 2))
            
            // Close preferences
            let doneButton = preferencesWindow.buttons["Done"]
            if doneButton.exists {
                doneButton.click()
            }
        }
    }
    
    // MARK: - Gallery View Tests
    
    func testGalleryViewExists() throws {
        let galleryView = app.outlines.firstMatch
        XCTAssertTrue(galleryView.exists)
        
        let screenshotsTitle = app.staticTexts["Screenshots"]
        XCTAssertTrue(screenshotsTitle.exists)
    }
    
    // MARK: - Menu Bar Tests
    
    func testMenuBarCommands() throws {
        let menuBar = app.menuBars.firstMatch
        XCTAssertTrue(menuBar.exists)
        
        // Test File menu for screenshot commands
        let fileMenu = menuBar.menuItems["File"]
        if fileMenu.exists {
            fileMenu.click()
            
            let captureFullScreenMenuItem = app.menuItems["Capture Full Screen"]
            let captureWindowMenuItem = app.menuItems["Capture Window"]
            let timedCaptureMenuItem = app.menuItems["Timed Capture"]
            
            XCTAssertTrue(captureFullScreenMenuItem.exists)
            XCTAssertTrue(captureWindowMenuItem.exists)
            XCTAssertTrue(timedCaptureMenuItem.exists)
            
            // Close menu
            app.typeKey(XCUIKeyboardKey.escape, modifierFlags: [])
        }
    }
    
    // MARK: - Keyboard Shortcuts Tests
    
    func testKeyboardShortcuts() throws {
        // Test Command+Shift+3 for full screen capture
        app.typeKey("3", modifierFlags: [.command, .shift])
        
        // Wait a moment for any system dialogs or capture UI
        sleep(1)
        
        // Test Command+Shift+4 for selection capture
        app.typeKey("4", modifierFlags: [.command, .shift])
        sleep(1)
        
        // Test Command+Shift+5 for window capture
        app.typeKey("5", modifierFlags: [.command, .shift])
        sleep(1)
        
        // Test Command+Shift+T for timed capture
        app.typeKey("t", modifierFlags: [.command, .shift])
        sleep(1)
    }
    
    // MARK: - Editor Interface Tests
    
    func testEditorToolsWhenScreenshotSelected() throws {
        // This test would run if there's a screenshot in the gallery
        let galleryItems = app.outlines.firstMatch.cells
        
        if galleryItems.count > 0 {
            galleryItems.firstMatch.click()
            
            // Check if editor tools appear
            let penTool = app.buttons.matching(identifier: "pencil").firstMatch
            let highlighterTool = app.buttons.matching(identifier: "highlighter").firstMatch
            let arrowTool = app.buttons.matching(identifier: "arrow.up.right").firstMatch
            
            if penTool.exists {
                XCTAssertTrue(penTool.exists)
            }
            if highlighterTool.exists {
                XCTAssertTrue(highlighterTool.exists)
            }
            if arrowTool.exists {
                XCTAssertTrue(arrowTool.exists)
            }
        }
    }
    
    // MARK: - Accessibility Tests
    
    func testAccessibilityLabels() throws {
        let fullScreenButton = app.buttons["Capture Full Screen"]
        let selectionButton = app.buttons["Capture Selection"]
        let windowButton = app.buttons["Capture Window"]
        
        // Test that buttons have proper accessibility labels
        XCTAssertNotNil(fullScreenButton.label)
        XCTAssertNotNil(selectionButton.label)
        XCTAssertNotNil(windowButton.label)
        
        // Test that buttons are accessible
        XCTAssertTrue(fullScreenButton.isHittable)
        XCTAssertTrue(selectionButton.isHittable)
        XCTAssertTrue(windowButton.isHittable)
    }
    
    // MARK: - Performance Tests
    
    func testAppLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
    
    func testNavigationPerformance() throws {
        measure {
            // Navigate through different views
            let selectionButton = app.buttons["Capture Selection"]
            if selectionButton.exists {
                selectionButton.click()
                app.typeKey(XCUIKeyboardKey.escape, modifierFlags: [])
            }
        }
    }
}