import PlaygroundSupport
import SwiftUI

struct ContentView: View {
  var body: some View {
    ZStack {
      LinearGradient(gradient: Gradient(colors: [Color.blue, Color.cyan]), startPoint: .top, endPoint: .bottom)
        .edgesIgnoringSafeArea(.all)

      LinearGradient(gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.4), Color.clear]), startPoint: .top, endPoint: .bottom)
        .edgesIgnoringSafeArea(.all)

      Image(systemName: "film")
        .font(.system(size: 384))
        .foregroundColor(.gray)
        .shadow(color: .black, radius: 10, x: 0, y: 10)

      Image(systemName: "movieclapper.fill")
        .font(.system(size: 128))
        .foregroundColor(.white.opacity(0.7))
        .offset(x: 128, y: 128)
        .shadow(color: .black, radius: 10, x: 0, y: 10)

      VStack(alignment: .leading, spacing: 24) {
        VStack(alignment: .leading, spacing: 8) {
          ZStack {
            Text("1")
            Text("1")
              .foregroundColor(Color.white.opacity(0.5))
              .offset(x: 12, y: 12)
          }
          ZStack {
            Text("00:00:01.337 --> 00:00:06.337")
            Text("00:00:02.337 --> 00:00:07.337")
              .foregroundColor(Color.white.opacity(0.5))
              .offset(x: 12, y: 12)
          }
          ZStack {
            Text("SubRip Resync")
            Text("SubRip Resync")
              .foregroundColor(Color.white.opacity(0.5))
              .offset(x: 12, y: 12)
          }
        }
        VStack(alignment: .leading, spacing: 8) {
          ZStack {
            Text("2")
            Text("2")
              .foregroundColor(Color.white.opacity(0.5))
              .offset(x: 12, y: 12)
          }
          ZStack {
            Text("00:00:10.042 --> 00:00:15.042")
            Text("00:00:11.542 --> 00:00:16.542")
              .foregroundColor(Color.white.opacity(0.5))
              .offset(x: 12, y: 12)
          }
          ZStack {
            Text("Shift offset")
            Text("Shift offset")
              .foregroundColor(Color.white.opacity(0.5))
              .offset(x: 12, y: 12)
          }
        }
        VStack(alignment: .leading, spacing: 8) {
          ZStack {
            Text("3")
            Text("3")
              .foregroundColor(Color.white.opacity(0.5))
              .offset(x: 12, y: 12)
          }
          ZStack {
            Text("00:00:19.101 --> 00:00:24.101")
            Text("00:00:21.121 --> 00:00:26.121")
              .foregroundColor(Color.white.opacity(0.5))
              .offset(x: 12, y: 12)
          }
          ZStack {
            Text("Linear resync")
            Text("Linear resync")
              .foregroundColor(Color.white.opacity(0.5))
              .offset(x: 12, y: 12)
          }
        }
      }
      .font(.largeTitle)
      .fontWeight(.black)
      .fontDesign(.monospaced)
      .foregroundColor(.white)
      .shadow(color: .gray, radius: 10, x: 0, y: 10)
      .minimumScaleFactor(0.1)
      .padding()
    }.frame(width: 512, height: 512)
  }
}

PlaygroundPage.current.setLiveView(ContentView())
