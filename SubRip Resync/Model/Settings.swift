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
  @Published var convertASSLineBreaks: Bool {
    didSet {
      UserDefaults.standard.set(convertASSLineBreaks, forKey: "convertASSLineBreaks")
    }
  }

  init() {
    self.onlyShowText = UserDefaults.standard.bool(forKey: "onlyShowText")
    self.convertASSLineBreaks = UserDefaults.standard.bool(forKey: "convertASSLineBreaks")
  }
}
