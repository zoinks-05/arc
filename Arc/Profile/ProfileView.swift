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

    @State private var selectedType = "movie"

    private var userArcs: [ArcModel] {
        guard let userID = user?.id else {
            return []
        }

        return dataStore.arcs.filter {
            $0.userID == userID
        }
    }

    private var filteredArcs: [ArcModel] {
        userArcs.filter {
            $0.contentType == selectedType
        }
    }

    private let gridColumns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]

    var body: some View {

        if let user {
            NavigationStack{

            ZStack {

                Color.black
                    .ignoresSafeArea()

                ScrollView {
                    
                    VStack(spacing: 20) {
                        
                        VStack(spacing: 16) {
                            
                            HStack(
                                alignment: .center,
                                spacing: 24
                            ) {
                                
                                Circle()
                                    .fill(
                                        Color.gray.opacity(0.3)
                                    )
                                    .overlay(
                                        Image(
                                            systemName:
                                                "person.fill"
                                        )
                                        .font(
                                            .system(size: 32)
                                        )
                                        .foregroundStyle(
                                            .white.opacity(0.6)
                                        )
                                    )
                                    .frame(
                                        width: 86,
                                        height: 86
                                    )
                                
                                VStack(
                                    alignment: .leading,
                                    spacing: 4
                                ) {
                                    
                                    Text(user.username)
                                        .font(.title)
                                        .foregroundStyle(.white)
                                    
                                    if let bio = user.bio,
                                       !bio.isEmpty {
                                        
                                        Text(bio)
                                            .font(.subheadline)
                                            .foregroundStyle(
                                                .white.opacity(0.8)
                                            )
                                    }
                                    
                                    if !user.preferredGenres.isEmpty {
                                        
                                        Text(
                                            user.preferredGenres.joined(
                                                separator: " · "
                                            )
                                        )
                                        .font(.caption)
                                        .foregroundStyle(
                                            .white.opacity(0.5)
                                        )
                                    }
                                    
                                    HStack(spacing: 0) {
                                        
                                        statColumn(
                                            value: userArcs.count,
                                            label: "Arcs"
                                        )
                                        
                                        Spacer()
                                        
                                        statColumn(
                                            value: user.followers,
                                            label: "Followers"
                                        )
                                        
                                        Spacer()
                                        
                                        statColumn(
                                            value: user.following,
                                            label: "Following"
                                        )
                                    }
                                }
                                .frame(
                                    maxWidth: .infinity,
                                    alignment: .leading
                                )
                            }
                            
                            // MARK: Movie / TV Tabs
                            
                            HStack(spacing: 8) {
                                
                                Button {
                                    selectedType = "movie"
                                } label: {
                                    
                                    Text("Movies")
                                        .foregroundStyle(
                                            selectedType == "movie"
                                            ? .purple
                                            : .white
                                        )
                                        .frame(
                                            maxWidth: .infinity
                                        )
                                        .padding(.vertical, 10)
                                        .background(
                                            selectedType == "movie"
                                            ? Color.white.opacity(0.12)
                                            : Color.clear
                                        )
                                        .clipShape(
                                            RoundedRectangle(
                                                cornerRadius: 12
                                            )
                                        )
                                }
                                
                                Button {
                                    selectedType = "tv"
                                } label: {
                                    
                                    Text("TV")
                                        .foregroundStyle(
                                            selectedType == "tv"
                                            ? .purple
                                            : .white
                                        )
                                        .frame(
                                            maxWidth: .infinity
                                        )
                                        .padding(.vertical, 10)
                                        .background(
                                            selectedType == "tv"
                                            ? Color.white.opacity(0.12)
                                            : Color.clear
                                        )
                                        .clipShape(
                                            RoundedRectangle(
                                                cornerRadius: 12
                                            )
                                        )
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                        
                        // MARK: Arc Grid
                        
                        if filteredArcs.isEmpty {
                            
                            Text("No Arcs yet")
                                .font(.subheadline)
                                .foregroundStyle(
                                    .white.opacity(0.5)
                                )
                                .padding(.top, 40)
                            
                        } else {
                            
                            LazyVGrid(
                                columns: gridColumns,
                                spacing: 2
                            ) {
                                
                                ForEach(filteredArcs) { arc in
                                    
                                    ProfileArcGridItem(
                                        arc: arc,
                                        dataStore: dataStore
                                    )
                                }
                            }
                        }
                    }
                }
                }
            }

        } else {

            VStack {

                ProgressView()

                Text("Loading profile...")
                    .foregroundStyle(
                        .white.opacity(0.6)
                    )
                    .padding(.top, 8)
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            .background(
                Color.black.ignoresSafeArea()
            )
        }
    }

    @ViewBuilder
    private func statColumn(value: Int, label: String) -> some View {
        VStack(spacing: 2) {
            Text("\(value)").font(.headline).foregroundStyle(.white)
            Text(label).font(.caption).foregroundStyle(.white.opacity(0.6))
        }
    }
}

extension ProfileView {
    private struct ProfileArcGridItem: View {

        let arc: ArcModel
        let dataStore: DummyDataStore

        @State private var posterPath: String?
        @State private var showDeleteConfirmation = false
        @State private var showEditPlaceholder = false

        private let deleteArc = ArcDeleteUseCase()

        private var isOwnArc: Bool {
            dataStore.users.first(where: { $0.username == "localUser" })?.id == arc.userID
        }

        var body: some View {

            NavigationLink {
                ScrollPageView(
                    dataStore: dataStore,
                    mode: .profile(
                        userID: arc.userID,
                        contentType: arc.contentType,
                        startingArcID: arc.id
                    )
                )
            } label: {
                ZStack {
                    if let url = APIService.shared.imageURL(path: posterPath) {
                        AsyncImage(url: url) { state in
                            switch state {
                            case .success(let image):
                                image.resizable().scaledToFill()
                            case .failure, .empty:
                                Color.gray.opacity(0.3)
                            @unknown default:
                                Color.gray.opacity(0.3)
                            }
                        }
                    } else {
                        Color.gray.opacity(0.3)
                    }
                }
                .aspectRatio(2 / 3, contentMode: .fill)
                .clipped()
            }
            .buttonStyle(.plain)
            .contextMenu {
                if isOwnArc {
                    Button {
                        showEditPlaceholder = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }

                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .confirmationDialog(
                "Delete this Arc?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    deleteArc.execute(arcID: arc.id, dataStore: dataStore)
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This can't be undone.")
            }
            .navigationDestination(isPresented: $showEditPlaceholder) {
                CreateArc(contentID: arc.contentID, contentType: arc.contentType, mode: .edit(arc), dataStore: dataStore)
            }
            .task {
                do {
                    let details = try await APIService.shared.fetchContentDetails(
                        ContentID: arc.contentID,
                        type: arc.contentType
                    )
                    posterPath = details["poster_path"] as? String
                } catch {
                    print("Failed to load poster: \(error)")
                }
            }
        }
    }
}
