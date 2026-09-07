//
//  ContentView.swift
//  Arc
//
//  Created by Ziyan Nadeem on 23/8/2026.
//

import SwiftUI

struct ContentView: View {
    
    @State private var dataStore = DummyDataStore()
    private var localUser: UserModel? {
        dataStore.users.first(where: { $0.username == "localUser" })
    }
    
    var body: some View {
        TabView {
            
            Home(dataStore: dataStore)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            ScrollPageView(
                dataStore: dataStore
            )
            .tabItem {
                Label("Feed", systemImage: "play.rectangle")
            }
            
            ProfileView(
                dataStore: dataStore,
                user: localUser
            )
            .tabItem {
                Label("Profile", systemImage: "person")
            }
        }
        .onAppear {
            dataStore.loadData()
        }
    }
}

#Preview {
    ContentView()
}

