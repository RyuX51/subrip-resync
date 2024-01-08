//
//  AppViewModel.swift
//  SubRip Resync
//
//  Created by Mario Stief on 08.01.24.
//

import Foundation

class AppViewModel: ObservableObject {

  @Published var isSaveEnabled: Bool = false // Condition to enable/disable save commands

  func saveASS() {
    // Implement save ASS logic here
  }

  func saveSRT() {
    // Implement save SRT logic here
  }
}
