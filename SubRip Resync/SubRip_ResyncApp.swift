//
//  SubRip_ResyncApp.swift
//  SubRip Resync
//
//  Created by Mario Stief on 18.10.23.
//

import SwiftUI

@main
struct SubRipResyncApp: App {
  @StateObject private var settings = Settings()
  @StateObject var selectedFile = SelectedFile()

  var body: some Scene {
    WindowGroup {
      ContentView(selectedFile: selectedFile)
        .environmentObject(settings)
    }
    .commands {
      CommandGroup(replacing: CommandGroupPlacement.newItem) {
        Button(action: openFile, label: {
          Text("Open...")
        })
        .keyboardShortcut("o", modifiers: .command)
      }
    }
  }

  func openFile() {
    let panel = NSOpenPanel()
    panel.allowsMultipleSelection = false
    panel.canChooseDirectories = false
    panel.canCreateDirectories = false
    panel.canChooseFiles = true
    panel.allowedFileTypes = ["srt", "ass"]

    if panel.runModal() == NSApplication.ModalResponse.OK {
      selectedFile.url = panel.url
    }
  }
}
