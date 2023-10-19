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
  @State private var offsetString = ""
  @State private var isTextFieldActive = false
  @State private var isStepperActive = false

  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        Text("\(subtitle.id)")
        Text("\(subtitle.startTime.stringValue) --> \(subtitle.endTime.stringValue)")
        Text("\(subtitle.text)")
      }.fontDesign(.monospaced)
      Spacer()

      VStack {
        HStack {
          Text("Offset:")
          TextField("Offset", text: $offsetString, onEditingChanged: { editing in
            isTextFieldActive = editing
          }, onCommit: {
            if let newOffset = Double(offsetString.replacingOccurrences(of: ",", with: ".")) {
              subtitle.startOffset = newOffset
              viewModel.useOffset(from: subtitle)
            }
          })
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .fontDesign(.monospaced)
          .frame(width: 80)
          .onReceive(Just(subtitle.startOffset)) { newValue in
            //        print("onReceive \(subtitle.id) (textfield): \(newValue)")
            if !isTextFieldActive {
              offsetString = String(round(newValue * 10) / 10)
            }
          }
          Text("ms")

          Stepper("", onIncrement: {
            subtitle.startOffset += 0.1
            viewModel.useOffset(from: subtitle)
          }, onDecrement: {
            subtitle.startOffset -= 0.1
            viewModel.useOffset(from: subtitle)
          }).labelsHidden()
        }
        Text("\(subtitle.startTime.string(adding: subtitle.startOffset)) --> \(subtitle.endTime.string(adding: subtitle.startOffset))")
          .font(.footnote)
          .fontDesign(.monospaced)
      }

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
  SubtitleRow(subtitle: .init(id: 1, startTime: .init("00:11:00.101"), endTime: .init("00:11:01.337"), text: "SubRip Resync"), viewModel: .init())
}
