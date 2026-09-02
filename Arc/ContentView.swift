//
//  ContentView.swift
//  Arc
//
//  Created by Ziyan Nadeem on 23/8/2026.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        TabView {
            
            Text("Home")
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            //ScrollPageView(arcs: ArcModel.sampleData)
                .tabItem {
                    Label("Feed", systemImage: "play.rectangle")
                }
            
            Text("Profile")
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}

#Preview {
    ContentView()
}
