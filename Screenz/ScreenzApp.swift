//
//  ScreenzApp.swift
//  Screenz
//
//  Created by Avijeet Pandey on 28/08/25.
//

import SwiftUI

@main
struct ScreenzApp: App {
    var body: some Scene {
        Window("Screenz", id: "main") {
            ContentView()
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 1000, height: 700)
        .windowToolbarStyle(.unified)
    }
}
