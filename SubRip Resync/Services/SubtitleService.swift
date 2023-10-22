//
//  SubtitleService.swift
//  SubRip Resync
//
//  Created by Mario Stief on 20.10.23.
//

import SwiftUI

protocol SubtitleService {

  mutating func parseFile(url: URL, completion: (String, [Subtitle]) -> Void)
  mutating func parseSubtitles(_ str: String) -> [Subtitle]
  func printTime(subtitle: Subtitle) -> String
  func printAllComponents(subtitle: Subtitle) -> String
  func printTextComponents(subtitle: Subtitle) -> String
  func assemble(from subtitles: [Subtitle]) -> String
}
