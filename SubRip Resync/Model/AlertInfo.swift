//
//  AlertInfo.swift
//  SubRip Resync
//
//  Created by Mario Stief on 12.01.24.
//

import Foundation

struct AlertInfo: Identifiable {

  enum AlertType {
    case info
    case error
  }

  let id: AlertType
  var title: String {
    switch id {
    case .info: return "Information"
    case .error: return "Error"
    }
  }
  let message: String

  init(_ id: AlertType, message: String) {
    self.id = id
    self.message = message
  }
}
