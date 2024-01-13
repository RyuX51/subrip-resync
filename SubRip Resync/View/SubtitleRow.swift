//
//  SubtitleRow.swift
//  SubRip Resync
//
//  Created by Mario Stief on 20.10.23.
//

import Combine
import SwiftUI

struct SubtitleRow: View {
  @ObservedObject var subtitle: Subtitle
  @ObservedObject var viewModel: ContentViewModel
  @EnvironmentObject var settings: Settings

  @State private var offsetString = ""
  @State private var isTextFieldActive = false
  @State private var isStepperActive = false

  var body: some View {
    HStack {
      Text("\(subtitle.id)")
        .font(.system(.footnote, design: .monospaced))
        .frame(width: 50)
      Text(viewModel.subtitleService.printTime(subtitle: subtitle))
        .font(.system(.body, design: .monospaced))
        .frame(width: 300)
      if settings.onlyShowText {
        Text(viewModel.subtitleService.printTextComponents(subtitle: subtitle))
          .font(.system(.body, design: .monospaced))
          .multilineTextAlignment(.leading)
      } else {
        Text(viewModel.subtitleService.printAllComponents(subtitle: subtitle))
          .font(.system(.body, design: .monospaced))
          .multilineTextAlignment(.leading)
      }
      Spacer()

      VStack {
        HStack {
          ResponderTextField(
            text: $offsetString,
            isFirstResponder: $isTextFieldActive,
            onEditingChanged: { _ in
              viewModel.useOffset(from: subtitle) {}
            },
            onCommit: {
              if let newOffset = Double(offsetString.replacingOccurrences(of: ",", with: ".")) {
                if abs(newOffset - subtitle.startOffset) > 0.01 {
                  subtitle.startOffset = newOffset
                  subtitle.endOffset = newOffset
                  withAnimation {
                    subtitle.useForResync = true
                    viewModel.objectWillChange.send()
                  }
                }
              }
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .font(.system(.body, design: .monospaced))
            .frame(width: 80)
            .onReceive(Just(subtitle.startOffset)) { newValue in
              if !isTextFieldActive {
                offsetString = String(round(newValue * 10) / 10)
              }
            }
            .onChange(of: isTextFieldActive) { isActive in
              print("subtitle \(subtitle.id) is active: \(isActive)")
              if isActive {
                viewModel.activeSubtitle = subtitle
                viewModel.updateOffsetString = {
                  offsetString = String(round(subtitle.startOffset * 10) / 10)
                }
                // broadcast to the other text views that this one has the focus now
                NotificationCenter.default.post(name: .textFieldHasFocus, object: subtitle.id)
              }
            }
            .onReceive(NotificationCenter.default.publisher(for: .textFieldHasFocus)) { data in
              guard let subtitleId = data.object as? Int else { return }
              if subtitle.id != subtitleId {
                // this TextField doesn't have focus anymore
                isTextFieldActive = false
              }
            }

          Text("s")

          Stepper("", onIncrement: {
            isTextFieldActive = false
            subtitle.startOffset += 0.1
            subtitle.endOffset += 0.1
            viewModel.activeSubtitle = nil
            viewModel.updateOffsetString = nil
            viewModel.useOffset(from: subtitle) {
              DispatchQueue.main.async {
                withAnimation {
                  subtitle.useForResync = true
                  viewModel.objectWillChange.send()
                }
              }
            }
          }, onDecrement: {
            isTextFieldActive = false
            subtitle.startOffset -= 0.1
            subtitle.endOffset -= 0.1
            viewModel.activeSubtitle = nil
            viewModel.updateOffsetString = nil
            viewModel.useOffset(from: subtitle) {
              DispatchQueue.main.async {
                withAnimation {
                  subtitle.useForResync = true
                  viewModel.objectWillChange.send()
                }
              }
            }
          }).labelsHidden()
        }
        Text("\(subtitle.start.string(adding: subtitle.startOffset)) --> \(subtitle.end.string(adding: subtitle.startOffset))")
          .font(.system(.footnote, design: .monospaced))
      }
      .frame(width: 200)

      HStack {
        if subtitle.useForResync {
          Button {
            viewModel.removeOffset(subtitle: subtitle) {
              DispatchQueue.main.async {
                viewModel.objectWillChange.send()
              }
            }
          } label: {
            Image(systemName: "x.circle.fill")
              .resizable()
              .foregroundColor(.red)
              .frame(width: 20, height: 20)
          }.buttonStyle(BorderlessButtonStyle())
        }
      }.frame(width: 40)

    }
    .onAppear {
      offsetString = String(subtitle.startOffset)
    }
  }
}

#Preview {
  SubtitleRow(subtitle: .init(id: 1, start: SRTTime("00:11:00.101"), end: SRTTime("00:11:01.337"), components: []), viewModel: .init())
}
