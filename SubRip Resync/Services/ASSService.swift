//
//  ASSService.swift
//  SubRip Resync
//
//  Created by Mario Stief on 20.10.23.
//

import SwiftUI

struct ASSService: SubtitleService {

  @EnvironmentObject var settings: Settings
  private var startIndex: Int = -1
  private var endIndex: Int = -1
  private var textIndex: Int = -1
  private var textBeforeEvents: String = ""
  private var textAfterEvents: String = ""
  private var format: [String] = []

  mutating func parseFile(url: URL, completion: (String, [Subtitle]) -> Void) {
    let fileName = url.deletingPathExtension().lastPathComponent
    do {
      let data = try Data(contentsOf: url)
      let str = String(data: data, encoding: .utf8) ?? ""
      completion(fileName, parseSubtitles(str))
    } catch {
      print("Error: \(error)")
    }
  }

  internal mutating func parseSubtitles(_ str: String) -> [Subtitle] {
    let all = str.replacingOccurrences(of: "\r\n", with: "\n")
    guard let eventsStartRange = all.range(of: "[Events]\n") else { return [] }
    textBeforeEvents = String(all[..<eventsStartRange.upperBound])
    var eventsPart = String(all[eventsStartRange.upperBound...])
    eventsPart = extractTextAfterEvents(from: &eventsPart)
    var lines = eventsPart.components(separatedBy: "\n")
    guard let firstLine = lines.first else { return [] }
    textBeforeEvents += firstLine + "\n"
    guard parseDefinitionLine(firstLine) else { return [] }
    lines.removeFirst()
    return parseLinesToSubtitles(lines)
  }

  private mutating func extractTextAfterEvents(from eventsPart: inout String) -> String {
    if let eventsEndRange = eventsPart.range(of: "\n\n[") {
      textAfterEvents = String(eventsPart[eventsEndRange.lowerBound...])
      eventsPart = String(eventsPart[..<eventsEndRange.lowerBound])
    }
    return eventsPart
  }

  private mutating func parseDefinitionLine(_ line: String) -> Bool {
    let definitionLine = line
      .replacingOccurrences(of: " ", with: "")
      .components(separatedBy: ":")
    if definitionLine.count != 2 || definitionLine[0] != "Format" { return false }
    let definitionComponents = definitionLine[1].components(separatedBy: ",")
    guard let startIndex = definitionComponents.firstIndex(of: "Start"),
          let endIndex = definitionComponents.firstIndex(of: "End"),
          let textIndex = definitionComponents.firstIndex(of: "Text") else { return false }
    for i in 0..<definitionComponents.count {
      if i != startIndex && i != endIndex {
        format.append(definitionComponents[i])
      }
    }
    self.startIndex = startIndex
    self.endIndex = endIndex
    self.textIndex = textIndex
    for i in [startIndex, endIndex] {
      if i < textIndex {
        self.textIndex -= 1
      }
    }

    return true
  }

  private func parseLinesToSubtitles(_ lines: [String]) -> [Subtitle] {
    var subtitles: [Subtitle] = []
    var i = 1
    for line in lines {
      let lineParts = line.components(separatedBy: ",")
      guard lineParts.count > 2 else { continue }
      let start = ASSTime(lineParts[startIndex])
      let end = ASSTime(lineParts[endIndex])

      var components: [String] = []
      for i in 0..<lineParts.count {
        if i != startIndex && i != endIndex {
          components.append(lineParts[i])
        }
      }
      let subtitle = Subtitle(id: i, start: start, end: end, components: components)
      subtitles.append(subtitle)
      i += 1
    }
    return subtitles
  }

  func printTime(subtitle: Subtitle) -> String {
    "\(subtitle.start.stringValue) --> \(subtitle.end.stringValue)"
  }

  func printComponents(subtitle: Subtitle) -> String {
    if settings.onlyShowText, subtitle.components.count > textIndex {
      return subtitle.components[textIndex]
    } else {
      return zip(format, subtitle.components).compactMap {
        guard !$1.isEmpty else { return nil }
        return $0 + ": " + $1
      }.joined(separator: "\n")
    }
  }

  func printAllComponents(subtitle: Subtitle) -> String {
    zip(format, subtitle.components).compactMap {
      guard !$1.isEmpty else { return nil }
      return $0 + ": " + $1
    }.joined(separator: "\n")
  }

  func printTextComponents(subtitle: Subtitle) -> String {
    subtitle.components[textIndex]
  }

  func assemble(from subtitles: [Subtitle]) -> String {
    var result = textBeforeEvents
    result += subtitles.map {
      let start = $0.start.string(adding: $0.startOffset)
      let end = $0.end.string(adding: $0.endOffset)

      var components: [String] = []
      var i = 0
      var j = 0
      for _ in 0..<format.count + 2 {
        if i == startIndex {
          components.append(start)
        } else if i == endIndex {
          components.append(end)
        } else {
          components.append($0.components[j])
          j += 1
        }
        i += 1
      }

      return components.joined(separator: ",")
    }.joined(separator: "\n")
    result += textAfterEvents
    return result
  }

  func convertToSRT(assSubs: [Subtitle]) -> [Subtitle] {
    let srtSubs: [Subtitle] = assSubs.compactMap {
      let startTime = SRTTime($0.start.string(adding: 0))
      let endTime = SRTTime($0.end.string(adding: 0))
      let components: [String] = [$0.components[textIndex]]
      return Subtitle(id: $0.id, start: startTime, end: endTime, components: components)
    }
    return srtSubs
  }
}
