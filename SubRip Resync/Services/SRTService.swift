//
//  SRTService.swift
//  SubRip Resync
//
//  Created by Mario Stief on 20.10.23.
//

import SwiftUI

struct SRTService: SubtitleService {

  mutating func parseFile(url: URL, completion: (String, [Subtitle], SubtitleService) -> Void, failure: () -> Void) {
    let fileName = url.deletingPathExtension().lastPathComponent
    do {
      let data = try Data(contentsOf: url)
      let str = String(data: data, encoding: .utf8) ?? ""
      guard !str.isEmpty else {
        failure()
        return
      }
      completion(fileName, parseSubtitles(str), self)
    } catch {
      print("Error: \(error)")
    }
  }

  internal mutating func parseSubtitles(_ str: String) -> [Subtitle] {
    let all = str.replacingOccurrences(of: "\r\n", with: "\n")
    let lines = all.components(separatedBy: "\n\n")
    var subtitles: [Subtitle] = []

    for line in lines {
      let components = line.components(separatedBy: "\n")
      if components.count >= 3,
         let index = Int(components[0]),
         let range = components[1].range(of: " --> ") {
        let start = SRTTime(components[1][..<range.lowerBound])
        let end = SRTTime(components[1][range.upperBound...])
        let text = components[2...].joined(separator: "\n")
        let subtitle = Subtitle(id: index, start: start, end: end, components: [text])
        subtitles.append(subtitle)
      }
    }
    return subtitles
  }

  func printTime(subtitle: Subtitle) -> String {
    "\(subtitle.start.stringValue) --> \(subtitle.end.stringValue)"
  }

  func printAllComponents(subtitle: Subtitle) -> String {
    subtitle
      .components
      .joined()
      .replacingOccurrences(of: "\\\\[nN]", with: "\n", options: .regularExpression, range: nil)
  }

  func printTextComponents(subtitle: Subtitle) -> String {
    printAllComponents(subtitle: subtitle)
  }

  func assemble(from subtitles: [Subtitle]) -> String {
    subtitles.map {
      let start = $0.start.string(adding: $0.startOffset)
      let end = $0.end.string(adding: $0.endOffset)
      let text = $0.components.joined()
      return "\($0.id)\n\(start) --> \(end)\n\(text)"
    }.joined(separator: "\n\n")
  }
}
