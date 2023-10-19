//
//  ContentView.swift
//  SubRip Resync
//
//  Created by Mario Stief on 18.10.23.
//

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
        listView
        saveButton
      }
    }
    .background(Color.cyan)
    .onDrop(of: [.fileURL], delegate: self)
    .alert(isPresented: $viewModel.showAlert, content: {
      Alert(title: Text("Information"), message: Text("If more then 2 subtitles are active, the offsets will be calculated linearly between the first and the last one to archive the best result."), dismissButton: .default(Text("OK")))
    })
  }

  private var listView: some View {
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
  }

  private var saveButton: some View {
    Button(action: {
      let assembledSRT = viewModel.assembleSRT(from: viewModel.subtitles)
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

#Preview {
  ContentView()
}
