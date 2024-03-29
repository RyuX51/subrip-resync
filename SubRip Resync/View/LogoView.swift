//
//  LogoView.swift
//  SubRip Resync
//
//  Created by Mario Stief on 18.10.23.
//

import SwiftUI

struct LogoView: View {
  var body: some View {
    ZStack {
      LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.5), Color.blue]), startPoint: .top, endPoint: .bottom)
        .edgesIgnoringSafeArea(.all)

      VStack(alignment: .leading) {
        ZStack {
          Text("00:11:00.101 --> 00:11:01.337")
          Text("00:11:02.101 --> 00:11:03.337")
            .foregroundColor(Color.white.opacity(0.2))
            .offset(x: 12, y: 12)
        }
        ZStack {
          Text("SubRip Resync")
          Text("SubRip Resync")
            .foregroundColor(Color.white.opacity(0.2))
            .offset(x: 12, y: 12)
        }
      }
      .font(.system(.largeTitle, design: .monospaced).weight(.black))
      .foregroundColor(.white)
      .shadow(color: .gray, radius: 10, x: 0, y: 10)
      .minimumScaleFactor(0.1)
      .padding()
    }
  }
}

#Preview {
  LogoView()
}
