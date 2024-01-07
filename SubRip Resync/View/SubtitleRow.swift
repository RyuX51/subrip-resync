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
          Text("Offset:")
          TextField("Offset", text: $offsetString, onEditingChanged: { editing in
            isTextFieldActive = editing
          }, onCommit: {
            if let newOffset = Double(offsetString.replacingOccurrences(of: ",", with: ".")) {
              subtitle.startOffset = newOffset
              subtitle.endOffset = newOffset
              viewModel.useOffset(from: subtitle)
            }
          })
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .font(.system(.body, design: .monospaced))
          .frame(width: 80)
          .onReceive(Just(subtitle.startOffset)) { newValue in
            //        print("onReceive \(subtitle.id) (textfield): \(newValue)")
            if !isTextFieldActive {
              offsetString = String(round(newValue * 10) / 10)
            }
          }
          Text("s")

          Stepper("", onIncrement: {
            subtitle.startOffset += 0.1
            subtitle.endOffset += 0.1
            viewModel.useOffset(from: subtitle)
          }, onDecrement: {
            subtitle.startOffset -= 0.1
            subtitle.endOffset -= 0.1
            viewModel.useOffset(from: subtitle)
          }).labelsHidden()
        }
        Text("\(subtitle.start.string(adding: subtitle.startOffset)) --> \(subtitle.end.string(adding: subtitle.startOffset))")
          .font(.system(.footnote, design: .monospaced))
      }
      .frame(width: 200)

      HStack {
        if subtitle.useForResync {
          Button {
            viewModel.removeOffset(subtitle: subtitle)
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
