//
//  ProfileView.swift
//  Arc
//
//  Created by Ziyan Nadeem on 23/8/2026.
//

import SwiftUI

struct ProfileView: View {

    var dataStore: DummyDataStore
    let user: UserModel?

    @State  var selectedType = "movie"
    @State  var errorMessage: String?
    @State  var showError = false

     let gridColumns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]

     var userArcs: [ArcModel] {
        guard let userID = user?.id else {
            return []
        }

        return dataStore.arcs.filter {
            $0.userID == userID
        }
    }

     var filteredArcs: [ArcModel] {
        userArcs.filter {
            $0.contentType == selectedType
        }
    }

    var body: some View {
        if let user {
            NavigationStack {
                ZStack {
                    Color.black
                        .ignoresSafeArea()

                    ScrollView {
                        VStack(spacing: 20) {
                            profileHeader(user: user)
                            typeTabs
                            arcGrid
                        }
                    }
                }
                .alert("Unable to delete Arc", isPresented: $showError) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(errorMessage ?? "The Arc could not be deleted. Please try again.")
                }
            }
        } else {
            loadingView
        }
    }

}

