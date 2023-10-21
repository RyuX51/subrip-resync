//
//  ContentViewModel.swift
//  SubRip Resync
//
//  Created by Mario Stief on 18.10.23.
//

import SwiftUI

class ContentViewModel: ObservableObject {
  @Published var subtitles: [Subtitle] = []
  @Published var showMoreThanTwoSelectedAlert = false
  @Published var showInvalidFileAlert = false
  var fileName = ""
  var fileExtension = ""
  var active: Set<Int> = []
  var subtitleService: SubtitleService!

  func parseFile(url: URL) {

    fileExtension = url.pathExtension
    switch fileExtension {
    case "srt":
      subtitleService = SRTService()
    case "ass":
      subtitleService = ASSService()
    default:
      showInvalidFileAlert = true
      return
    }

    subtitleService.parseFile(url: url) { fileName, subtitles in
      self.fileName = fileName
      self.fileExtension = fileExtension
      self.subtitles = subtitles
    }
  }

  func assemble(from subtitles: [Subtitle]) -> String {
    subtitleService.assemble(from: subtitles)
  }

  func useOffset(from subtitle: Subtitle) {
    if active.count == 2 && !active.contains(subtitle.id) {
      showMoreThanTwoSelectedAlert = true
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
  }

  private func linearTransformation(selected: [Subtitle]) {
    let sorted = selected.sorted()
    guard let first = sorted.first,
          let last = sorted.last else { return }

    let firstStartTime = first.start.doubleValue
    let firstOffset = first.startOffset
    let lastStartTime = last.start.doubleValue
    let lastOffset = last.startOffset
    let offsetOverTime = (lastOffset - firstOffset) / (lastStartTime - firstStartTime)

    for subtitle in subtitles {
      subtitle.startOffset = (subtitle.start.doubleValue - firstStartTime) * offsetOverTime + firstOffset
      subtitle.endOffset = (subtitle.end.doubleValue - firstStartTime) * offsetOverTime + firstOffset
    }
  }
}
