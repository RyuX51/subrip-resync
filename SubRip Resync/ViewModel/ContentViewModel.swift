//
//  ContentViewModel.swift
//  SubRip Resync
//
//  Created by Mario Stief on 18.10.23.
//

import SwiftUI
import UniformTypeIdentifiers

class ContentViewModel: ObservableObject {
  @Published var subtitles: [Subtitle] = []
  @Published var warningMessage: String?
  @Published var alertInfo: AlertInfo?
  @Published var isListVisible = false
  @Published var searchText = ""
  @Published var showSettings = false
  var activeSubtitle: Subtitle?
  var updateOffsetString: (() -> Void)?

  var fileName = ""
  var fileExtension = ""
  var active: Set<Int> = [] {
    didSet {
      switch active.count {
      case 3...:
        withAnimation {
          warningMessage = "If more then 2 subtitles are active, the offsets will be calculated linearly between the first and the last one to archive the best result."
        }
      default:
        withAnimation {
          warningMessage = nil
        }
      }
    }
  }
  var subtitleService: SubtitleService!
  var keyDownMonitor: Any?

  func parseFile(url: URL) {
    let fileExtension = url.pathExtension
    var subtitleService: SubtitleService
    switch fileExtension {
    case "srt":
      subtitleService = SRTService()
    case "ass":
      subtitleService = ASSService()
    default:
      alertInfo = .init(.info, message: "This version supports SRT and ASS files only.")
      return
    }

    subtitleService.parseFile(
      url: url,
      completion: { fileName, subtitles, service in
        self.subtitleService = service
        self.fileName = fileName
        self.fileExtension = fileExtension
        self.subtitles = subtitles
        self.enableKeyDownMonitor()
      }, failure: {
        alertInfo = .init(.info, message: "The file could not be read or is empty. Did you use a valid subtitle file?")
      })
  }

  func convertToSRT() {
    if let assService = subtitleService as? ASSService {
      let subtitles = assService.convertToSRT(assSubs: subtitles)
      let assembled = SRTService().assemble(from: subtitles)
      saveToFile(assembled: assembled, fileExtension: "srt")
    }
  }

  func assemble(from subtitles: [Subtitle]) {
    let assembled = subtitleService.assemble(from: subtitles)
    saveToFile(assembled: assembled, fileExtension: fileExtension)
  }

  private func saveToFile(assembled: String, fileExtension: String) {
    let savePanel = NSSavePanel()
    savePanel.allowedContentTypes = [UTType(filenameExtension: fileExtension)!]

    let nameAddition: String
    switch active.count {
    case 0: nameAddition = ""
    case 1: nameAddition = "-shifted"
    default: nameAddition = "-resync"
    }

    savePanel.nameFieldStringValue = "\(fileName)\(nameAddition)." + fileExtension
    savePanel.isExtensionHidden = false
    savePanel.begin { result in
      if result.rawValue == NSApplication.ModalResponse.OK.rawValue,
         let url = savePanel.url {
        do {
          try assembled.write(to: url, atomically: true, encoding: .utf8)
        } catch {
          print("Error saving file: \(error)")
        }
      }
    }
  }

  func useOffset(from subtitle: Subtitle, completion: @escaping () -> Void) {
    active.insert(subtitle.id)
    updateOffsets(ignore: subtitle, completion: completion)
  }

  func removeOffset(subtitle: Subtitle, completion: @escaping () -> Void) {
    withAnimation {
      subtitle.useForResync = false
    }
    active.remove(subtitle.id)
    updateOffsets(completion: completion)
  }

  func updateOffsets(ignore: Subtitle? = nil, completion: @escaping () -> Void) {
    DispatchQueue.global(qos: .userInteractive).async {

      defer {
        completion()
      }

      let filtered = self.subtitles
        .filter { $0.useForResync }

      switch filtered.count {
      case 0:
        return
      case 1:
        // only shift offset
        let offset = filtered.first!.startOffset
        for subtitle in self.subtitles where subtitle.id != filtered.first!.id && subtitle.id != ignore?.id {
          DispatchQueue.main.async {
            subtitle.startOffset = offset
            subtitle.endOffset = offset
          }
        }
      default:
        self.linearTransformation(ignore: ignore, selected: filtered)
      }
    }
  }

  private func linearTransformation(ignore: Subtitle? = nil, selected: [Subtitle]) {
    let sorted = selected.sorted()
    guard let first = sorted.first,
          let last = sorted.last else { return }

    let firstStartTime = first.start.doubleValue
    let firstOffset = first.startOffset
    let lastStartTime = last.start.doubleValue
    let lastOffset = last.startOffset
    let offsetOverTime = (lastOffset - firstOffset) / (lastStartTime - firstStartTime)

    for subtitle in subtitles where subtitle.id != ignore?.id {
      DispatchQueue.main.async {
        subtitle.startOffset = (subtitle.start.doubleValue - firstStartTime) * offsetOverTime + firstOffset
        subtitle.endOffset = (subtitle.end.doubleValue - firstStartTime) * offsetOverTime + firstOffset
      }
    }
  }

  private func enableKeyDownMonitor() {
    keyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event -> NSEvent? in

      guard let subtitle = self?.activeSubtitle else { return event }

      switch event.keyCode {
      case 126: // Arrow up key code
        subtitle.startOffset += 0.1
        subtitle.endOffset += 0.1
        self?.updateOffsetString?()
        self?.useOffset(from: subtitle) {
          DispatchQueue.main.async {
            withAnimation {
              subtitle.useForResync = true
              self?.objectWillChange.send()
            }
          }
        }
      case 125: // Arrow down key code
        subtitle.startOffset -= 0.1
        subtitle.endOffset -= 0.1
        self?.updateOffsetString?()
        self?.useOffset(from: subtitle) {
          DispatchQueue.main.async {
            withAnimation {
              subtitle.useForResync = true
              self?.objectWillChange.send()
            }
          }
        }
      default:
        break
      }
      return event
    }
  }

  private func disableKeyDownMonitor() {
    keyDownMonitor = nil
  }
}
