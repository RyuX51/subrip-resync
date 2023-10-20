//
//  Time.swift
//  SubRip Resync
//
//  Created by Mario Stief on 19.10.23.
//

import Foundation

struct Time {
  let stringValue: String
  var doubleValue: Double {
    let timeParts = stringValue.components(separatedBy: [":", ".", ","])
    let hours = Double(timeParts[0]) ?? 0
    let minutes = Double(timeParts[1]) ?? 0
    let seconds = Double(timeParts[2]) ?? 0
    let milliseconds = Double(timeParts[3]) ?? 0
    return (hours * 60 * 60) + (minutes * 60) + seconds + (milliseconds / 1_000)
  }

  func string(adding offset: Double) -> String {
    let newValue = doubleValue + offset
    let hours = Int(newValue / (60 * 60))
    let minutes = Int((newValue / 60)) % 60
    let seconds = newValue.truncatingRemainder(dividingBy: 60)
    return String(format: "%02d:%02d:%06.3f", hours, minutes, seconds).replacingOccurrences(of: ".", with: ",")
  }

  init(_ stringValue: String) {
    self.stringValue = stringValue
  }

  init(_ substring: Substring) {
    self.stringValue = String(substring)
  }
}
