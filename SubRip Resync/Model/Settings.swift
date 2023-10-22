//
//  Settings.swift
//  SubRip Resync
//
//  Created by Mario Stief on 21.10.23.
//

import Combine
import SwiftUI

class Settings: ObservableObject {
  @Published var onlyShowText: Bool {
    didSet {
      UserDefaults.standard.set(onlyShowText, forKey: "onlyShowText")
    }
  }

  init() {
    self.onlyShowText = UserDefaults.standard.bool(forKey: "onlyShowText")
  }
}
