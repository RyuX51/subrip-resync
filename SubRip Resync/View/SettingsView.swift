//
//  SettingsView.swift
//  SubRip Resync
//
//  Created by Mario Stief on 21.10.23.
//

import SwiftUI

struct SettingsView: View {
  @EnvironmentObject var settings: Settings
  @Binding var isPresented: Bool
  @State private var isHovering: Bool = false

  var body: some View {
    ZStack(alignment: .topLeading) {
      VStack {
        Text("Settings")
          .font(.title)
          .padding()
        Form {
          Section(header: Text("Global").font(.headline.bold())) {
            Toggle(isOn: $settings.noLineBreaks) {
              Text("Don't convert \\N into line breaks")
            }
          }
          Section(header: Text("ASS").padding(.top, 4).font(.headline.bold())) {
            Toggle(isOn: $settings.onlyShowText) {
              Text("Show only text fields")
            }
          }
        }
      }
      .padding([.bottom, .horizontal])
      CloseButton(isPresented: $isPresented)
    }
  }
}

#Preview {
  SettingsView(isPresented: .constant(false))
}
