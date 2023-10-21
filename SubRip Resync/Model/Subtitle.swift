//
//  Subtitle.swift
//  SubRip Resync
//
//  Created by Mario Stief on 18.10.23.
//

import SwiftUI

class Subtitle: ObservableObject, Identifiable {

  let id: Int
  let start: any Time
  let end: any Time
  let components: [String]
  @Published var startOffset: Double = 0.0
  @Published var endOffset: Double = 0.0
  @Published var useForResync = false

  init(id: Int, start: any Time, end: any Time, components: [String], offset: Double = 0.0) {
    self.id = id
    self.start = start
    self.end = end
    self.components = components
    self.startOffset = offset
  }
}

extension Subtitle: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    hasher.combine(start)
    hasher.combine(end)
    hasher.combine(components)
  }
  static func == (lhs: Subtitle, rhs: Subtitle) -> Bool {
    lhs.id == rhs.id && lhs.start.stringValue == rhs.start.stringValue && lhs.end.stringValue == rhs.end.stringValue && lhs.components == rhs.components
  }
}

extension Subtitle: Comparable {
  static func < (lhs: Subtitle, rhs: Subtitle) -> Bool {
    lhs.id < rhs.id
  }
}
