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
  @Published var noLineBreaks: Bool {
    didSet {
      UserDefaults.standard.set(noLineBreaks, forKey: "noLineBreaks")
    }
  }

  init() {
    self.onlyShowText = UserDefaults.standard.bool(forKey: "onlyShowText")
    self.noLineBreaks = UserDefaults.standard.bool(forKey: "noLineBreaks")
  }
}
