//
//  ContentViewModel.swift
//  SubRip Resync
//
//  Created by Mario Stief on 18.10.23.
//

import SwiftUI

class ContentViewModel: ObservableObject {
  @Published var subtitles: [Subtitle] = []
  @Published var showAlert = false
  var active: Set<Int> = []

  func parseSRTFile(url: URL) {
    do {
      let data = try Data(contentsOf: url)
      let str = String(data: data, encoding: .utf8)
      self.subtitles = parseSubtitles(str ?? "")
    } catch {
      print("Error: \(error)")
    }
  }

  private func parseSubtitles(_ str: String) -> [Subtitle] {
    let lines = str.components(separatedBy: "\r\n\r\n")
    var subtitles: [Subtitle] = []

    for line in lines {
      let components = line.components(separatedBy: "\r\n")
      if components.count >= 3,
         let index = Int(components[0]),
         let range = components[1].range(of: " --> ") {
        let startTime = Time(components[1][..<range.lowerBound])
        let endTime = Time(components[1][range.upperBound...])
        let text = components[2]
        let subtitle = Subtitle(id: index, startTime: startTime, endTime: endTime, text: text)
        subtitles.append(subtitle)
      }
    }
    return subtitles
  }

  func useOffset(from subtitle: Subtitle) {
    if active.count == 2 && !active.contains(subtitle.id) {
      showAlert = true
    }
    subtitle.useForResync = true
    active.insert(subtitle.id)
    updateOffsets()
    objectWillChange.send()
  }

  func removeOffset(subtitle: Subtitle) {
    subtitle.useForResync = false
    active.remove(subtitle.id)
    updateOffsets()
    objectWillChange.send()
  }

  func updateOffsets() {
    let filtered = subtitles
      .filter { $0.useForResync }
    //      .map { $0.id }

    switch filtered.count {
    case 0:
      return
    case 1:
      // only shift offset
      let offset = filtered.first!.startOffset
      for subtitle in subtitles where subtitle.id != filtered.first!.id {
        subtitle.startOffset = offset
      }
      objectWillChange.send()
    default:
      linearTransformation(selected: filtered)
    }
    //    guard let firstIndex = subtitles.first?.id, let lastIndex = subtitles.last?.id else { return }
    //    let range = Double(lastIndex - firstIndex)
    //    for i in 0..<subtitles.count {
    //      let linearOffset = ((Double(i) / range) * (offset - subtitles[firstIndex].startOffset)) + subtitles[firstIndex].startOffset
    //      subtitles[i].startOffset = linearOffset
    //    }
    //    objectWillChange.send()
  }

  private func linearTransformation(selected: [Subtitle]) {
    let sorted = selected.sorted()
    guard let first = sorted.first,
          let last = sorted.last else { return }

    let firstStartTime = first.startTime.doubleValue
    let firstOffset = first.startOffset
    let lastStartTime = last.startTime.doubleValue
    let lastOffset = last.startOffset
    let offsetOverTime = (lastOffset - firstOffset) / (lastStartTime - firstStartTime)

    for subtitle in subtitles {
      subtitle.startOffset = (subtitle.startTime.doubleValue - firstStartTime) * offsetOverTime + firstOffset
      subtitle.endOffset = (subtitle.endTime.doubleValue - firstStartTime) * offsetOverTime + firstOffset
    }
  }
}
