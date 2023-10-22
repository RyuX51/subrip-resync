//
//  SubRip_ResyncApp.swift
//  SubRip Resync
//
//  Created by Mario Stief on 18.10.23.
//

import SwiftUI

@main
struct SubRip_ResyncApp: App {
  @StateObject private var settings = Settings()

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(settings)
    }
  }
}
