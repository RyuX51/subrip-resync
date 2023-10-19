//
//  Subtitle.swift
//  SubRip Resync
//
//  Created by Mario Stief on 18.10.23.
//

import SwiftUI

class Subtitle: ObservableObject, Identifiable {

  let id: Int
  let startTime: Time
  let endTime: Time
  let text: String
  @Published var startOffset: Double = 0.0
  @Published var endOffset: Double = 0.0
  @Published var useForResync = false

  init(id: Int, startTime: Time, endTime: Time, text: String, offset: Double = 0.0) {
    self.id = id
    self.startTime = startTime
    self.endTime = endTime
    self.text = text
    self.startOffset = offset
  }
}

extension Subtitle: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  static func == (lhs: Subtitle, rhs: Subtitle) -> Bool {
    lhs.id == rhs.id
  }
}

extension Subtitle: Comparable {
  static func < (lhs: Subtitle, rhs: Subtitle) -> Bool {
    lhs.id < rhs.id
  }
}
