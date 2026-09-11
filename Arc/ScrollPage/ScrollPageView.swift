//
//  ScrollPageView.swift
//  Arc
//
//  Created by Ziyan Nadeem on 30/8/2026.
//

import SwiftUI

struct ScrollPageView: View {

    enum ScrollMode {
        case feed
        case focused(contentID: Int)
        case profile(userID: UUID, contentType: String, startingArcID: UUID?)
    }

    @State  var selectedTab = "movie"
    @State  var type = "movie"
    @State  var spoilerRevealed: Set<UUID> = []

    @State var dataStore: DummyDataStore
    @State var mode: ScrollMode = .feed

    @State  var scrollPosition: UUID?
    @State  var showRecommendation = false
    @State  var showCreateArc = false
    @State  var showComments = false
    @State  var detailsCache: [UUID: [String: Any]] = [:]
    @State  var feedOrder: [UUID] = []

    @State  var errorMessage: String?
    @State  var showError = false

     let toggleArcLike = ArcLikesUseCase()
     let toggleRepostUseCase = ArcRepostUseCase()

     var users: [UserModel] {
        dataStore.users
    }

     var comments: [CommentModel] {
        dataStore.comments
    }

     var replies: [ReplyModel] {
        dataStore.replies
    }

     var filteredArcs: [ArcModel] {
        filteredArcs(for: mode)
    }

     var startingArcID: UUID? {
        switch mode {
        case .profile(_, _, let startingArcID):
            return startingArcID
        default:
            return nil
        }
    }

     var viewerRef: UserModel? {
        users.first {
            $0.username.lowercased() == "localuser"
        }
    }

     var currentArc: ArcModel? {
        guard !filteredArcs.isEmpty else {
            return nil
        }

        guard let scrollPosition else {
            return filteredArcs.first
        }

        return filteredArcs.first {
            $0.id == scrollPosition
        } ?? filteredArcs.first
    }

     var currentPosterPath: String? {
        guard let arc = currentArc else {
            return nil
        }

        return detailsCache[arc.id]?["poster_path"] as? String
    }

    var body: some View {
        NavigationStack {
            ZStack {
                backdrop(path: currentPosterPath)

                if case .feed = mode, selectedTab == "search" {
                    VStack {
                        Spacer()
                            .frame(height: 80)

                        SearchView(dataStore: dataStore)
                            .transition(.scale)

                        Spacer()
                    }
                } else if filteredArcs.isEmpty {
                    emptyState
                } else {
                    arcScrollView
                }

                if case .feed = mode {
                    feedControls
                }
            }
            .sheet(isPresented: $showComments) {
                commentsSheet
            }
            .alert("Something needs attention", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(
                    errorMessage
                    ?? "Something went wrong. Please try again."
                )
            }
        }
    }


}


 
