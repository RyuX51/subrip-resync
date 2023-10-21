//
//  Time.swift
//  SubRip Resync
//
//  Created by Mario Stief on 19.10.23.
//

import Foundation

protocol Time: Hashable {
  var stringValue: String { get }
  var doubleValue: Double { get }

  func string(adding offset: Double) -> String

  init(_ stringValue: String)
  init(_ substring: Substring)
}
