//
//  ContentView.swift
//  SimpleForm
//
//  Created by Woodrow Melling on 2/3/23.
//

import SwiftUI
import ComposableArchitectureForms
import ComposableArchitecture

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
