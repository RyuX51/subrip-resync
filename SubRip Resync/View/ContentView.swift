//
//  ContentView.swift
//  SubRip Resync
//
//  Created by Mario Stief on 18.10.23.
//

import Combine
import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
  @StateObject var viewModel = ContentViewModel()
  @State private var isListVisible = false
  @State private var searchText = ""

  var body: some View {
    VStack(spacing: 0) {
      LogoView().frame(height: 100)
      if viewModel.subtitles.isEmpty {
        DropHereView()
      } else {
        List {
          TextField("Search", text: $searchText)
            .padding(4)
          ForEach(viewModel.subtitles.filter { subtitle in
            self.searchText.isEmpty ? true : subtitle.text.contains(self.searchText)
          }) { subtitle in
            ZStack {
              subtitle.useForResync ? Color.green.opacity(0.2) : Color.clear
              SubtitleRow(subtitle: subtitle, viewModel: viewModel)
                .padding(6)
            }
          }
        }.listStyle(PlainListStyle())

        Button(action: {
          let assembledSRT = assembleSRT(from: viewModel.subtitles)
          let savePanel = NSSavePanel()
          savePanel.allowedContentTypes = [UTType(filenameExtension: "srt")!]
          savePanel.nameFieldStringValue = "\(viewModel.fileName)-resync.srt"
          savePanel.isExtensionHidden = false
          savePanel.begin { result in
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue,
               let url = savePanel.url {
              do {
                try assembledSRT.write(to: url, atomically: true, encoding: .utf8)
              } catch {
                print("Error saving file: \(error)")
              }
            }
          }
        }, label: {
          Label("Save", systemImage: "opticaldiscdrive.fill")
            .font(.title)
            .fontDesign(.monospaced)
            .fontWeight(.bold)
            .padding(8)
            .frame(minWidth: 200)
        })
        .buttonStyle(.borderedProminent)
        .clipShape(.capsule)
        .padding(8)
      }
    }
    .background(Color.cyan)
    .onDrop(of: [.fileURL], delegate: self)
    .alert(isPresented: $viewModel.showAlert, content: {
      Alert(title: Text("Information"), message: Text("If more then 2 subtitles are active, the offsets will be calculated linearly between the first and the last one to archive the best result."), dismissButton: .default(Text("OK")))
    })
  }

  private func assembleSRT(from subtitles: [Subtitle]) -> String {
    var srtString = ""
    for subtitle in subtitles {
      let start = subtitle.startTime.stringValue
      let end = subtitle.endTime.stringValue
      let text = subtitle.text
      srtString += "\(subtitle.id)\r\n\(start) --> \(end)\r\n\(text)\r\n\r\n"
    }
    return srtString
  }
}

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

extension ContentView: DropDelegate {

  func performDrop(info: DropInfo) -> Bool {
    guard let itemProvider = info.itemProviders(for: [.fileURL]).first else { return false }
    itemProvider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { urlData, _ in
      DispatchQueue.main.async {
        guard let urlData = urlData as? Data, let url = NSURL(absoluteURLWithDataRepresentation: urlData, relativeTo: nil) as URL? else { return }
        self.viewModel.parseSRTFile(url: url)
      }
    }
    return true
  }
}

#Preview {
  ContentView()
}
