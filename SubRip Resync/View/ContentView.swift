//
//  ContentView.swift
//  SubRip Resync
//
//  Created by Mario Stief on 18.10.23.
//

import SwiftUI

struct ContentView: View {
  @StateObject var viewModel = ContentViewModel()
  @ObservedObject var selectedFile: SelectedFile

  var body: some View {
    VStack(spacing: 0) {
      LogoView().frame(height: 100)
      if viewModel.subtitles.isEmpty {
        DropHereView()
      } else {
        listView
      }
      HStack {
        Spacer()
        HStack {
          if !viewModel.fileExtension.isEmpty {
            saveButton
          }
          if viewModel.fileExtension == "ass" {
            convertButton
          }
        }
        Spacer()
        settingsButton
      }
    }
    .background(Color.blue)
    .onDrop(of: [.fileURL], delegate: self)
    .onChange(of: selectedFile.url) { newValue in
      if let url = newValue {
        viewModel.parseFile(url: url)
      }
    }
    .alert(isPresented: $viewModel.showMoreThanTwoSelectedAlert, content: {
      Alert(title: Text("Information"), message: Text("If more then 2 subtitles are active, the offsets will be calculated linearly between the first and the last one to archive the best result."), dismissButton: .default(Text("OK")))
    })
    .alert(isPresented: $viewModel.showInvalidFileAlert, content: {
      Alert(title: Text("Error"), message: Text("This version supports SRT and ASS files."), dismissButton: .default(Text("OK")))
    })
    .sheet(isPresented: $viewModel.showSettings) {
      SettingsView(isPresented: $viewModel.showSettings)
    }
  }

  private var listView: some View {
    List {
      TextField("Search", text: $viewModel.searchText)
        .padding(8)
      ForEach(viewModel.subtitles.filter { subtitle in
        let text = subtitle.components.joined()
        return viewModel.searchText.isEmpty ? true : text.contains(viewModel.searchText)
      }) { subtitle in
        ZStack {
          subtitle.useForResync ? Color.gray.opacity(0.2) : Color.clear
          SubtitleRow(subtitle: subtitle, viewModel: viewModel)
            .padding(6)
        }
      }
    }
    .listStyle(PlainListStyle())
    .cornerRadius(8)
    .padding(4)
  }

  private var saveButton: some View {
    Label("Save \(viewModel.fileExtension.uppercased())", systemImage: "opticaldiscdrive.fill")
      .font(.system(.title, design: .monospaced).bold())
      .padding(8)
      .frame(minWidth: 256)
      .onTapGesture {
        viewModel.assemble(from: viewModel.subtitles)
      }
      .background(Capsule().fill(Color.white.opacity(0.5)))
      .padding(8)
  }

  private var convertButton: some View {
    Label("Save as SRT", systemImage: "opticaldiscdrive.fill")
      .font(.system(.title, design: .monospaced).bold())
      .padding(8)
      .frame(minWidth: 256)
      .onTapGesture {
        viewModel.convertToSRT()
      }
      .background(Capsule().fill(Color.white.opacity(0.5)))
      .padding(8)
  }

  private var settingsButton: some View {
    Image(systemName: "gearshape.fill")
      .font(.system(.title, design: .monospaced).bold())
      .padding(8)
      .onTapGesture {
        viewModel.showSettings.toggle()
      }
      .background(Circle().fill(Color.white.opacity(0.5)))
      .padding(8)
  }
}

#Preview {
  ContentView(selectedFile: .init())
}
