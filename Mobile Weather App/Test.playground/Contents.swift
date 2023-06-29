import UIKit
import PlaygroundSupport
import SwiftUI



struct  ContentView: View {
    var body: some View {
        VStack {
            Text("Hello \(Image(systemName: "star")) World")
            
        }
    }
}

PlaygroundPage.current.setLiveView(ContentView())
