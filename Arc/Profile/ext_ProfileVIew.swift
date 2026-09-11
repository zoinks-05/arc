//
//  ext_ProfileVIew.swift
//  Arc
//
//  Created by Ziyan Nadeem on 11/9/2026.
//

import SwiftUI

extension ProfileView {
    
    func profileHeader(user: UserModel) -> some View {
       VStack(spacing: 16) {
           HStack(alignment: .center, spacing: 24) {
               Circle()
                   .fill(Color.gray.opacity(0.3))
                   .overlay {
                       Image(systemName: "person.fill")
                           .font(.system(size: 32))
                           .foregroundStyle(.white.opacity(0.6))
                   }
                   .frame(width: 86, height: 86)

               VStack(alignment: .leading, spacing: 4) {
                   Text(user.username)
                       .font(.title)
                       .foregroundStyle(.white)

                   if let bio = user.bio, !bio.isEmpty {
                       Text(bio)
                           .font(.subheadline)
                           .foregroundStyle(.white.opacity(0.8))
                   }

                   if !user.preferredGenres.isEmpty {
                       Text(user.preferredGenres.joined(separator: " · "))
                           .font(.caption)
                           .foregroundStyle(.white.opacity(0.5))
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
               .frame(maxWidth: .infinity, alignment: .leading)
           }
       }
       .padding(.horizontal)
       .padding(.top, 12)
   }

    var typeTabs: some View {
       HStack(spacing: 8) {
           typeTab(
               title: "Movies",
               type: "movie"
           )

           typeTab(
               title: "TV",
               type: "tv"
           )
       }
       .padding(.horizontal)
   }

    func typeTab(title: String, type: String) -> some View {
       Button {
           selectedType = type
       } label: {
           Text(title)
               .foregroundStyle(
                   selectedType == type ? .purple : .white
               )
               .frame(maxWidth: .infinity)
               .padding(.vertical, 10)
               .background(
                   selectedType == type
                   ? Color.white.opacity(0.12)
                   : Color.clear
               )
               .clipShape(
                   RoundedRectangle(cornerRadius: 12)
               )
       }
       .buttonStyle(.plain)
   }

   @ViewBuilder
    var arcGrid: some View {
       if filteredArcs.isEmpty {
           VStack(spacing: 12) {
               Image(
                   systemName: selectedType == "movie"
                   ? "film.stack"
                   : "tv"
               )
               .font(.system(size: 42))
               .foregroundStyle(.secondary)

               Text("No Arcs yet")
                   .font(.headline)
                   .foregroundStyle(.white)

               Text(
                   selectedType == "movie"
                   ? "This user hasn't shared any movie Arcs yet."
                   : "This user hasn't shared any TV Arcs yet."
               )
               .font(.subheadline)
               .foregroundStyle(.white.opacity(0.5))
               .multilineTextAlignment(.center)
           }
           .frame(maxWidth: .infinity)
           .padding(.top, 40)
       } else {
           LazyVGrid(
               columns: gridColumns,
               spacing: 2
           ) {
               ForEach(filteredArcs) { arc in
                   ProfileArcGridItem(
                       arc: arc,
                       dataStore: dataStore,
                       onError: showErrorMessage
                   )
               }
           }
       }
   }

    var loadingView: some View {
       VStack {
           ProgressView()

           Text("Loading profile...")
               .foregroundStyle(.white.opacity(0.6))
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

   @ViewBuilder
    func statColumn(
       value: Int,
       label: String
   ) -> some View {
       VStack(spacing: 2) {
           Text("\(value)")
               .font(.headline)
               .foregroundStyle(.white)

           Text(label)
               .font(.caption)
               .foregroundStyle(.white.opacity(0.6))
       }
   }

    func showErrorMessage(_ message: String) {
       errorMessage = message
       showError = true
   }


     struct ProfileArcGridItem: View {

        let arc: ArcModel
        let dataStore: DummyDataStore
        let onError: (String) -> Void

        @State  var posterPath: String?
        @State  var showDeleteConfirmation = false
        @State  var showEdit = false

         let deleteArc = ArcDeleteUseCase()

         var isOwnArc: Bool {
            dataStore.users.first(where: {
                $0.username.lowercased() == "localuser"
            })?.id == arc.userID
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
                poster
            }
            .buttonStyle(.plain)
            .contextMenu {
                if isOwnArc {
                    Button {
                        showEdit = true
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
                    delete()
                }

                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This can't be undone.")
            }
            .navigationDestination(isPresented: $showEdit) {
                CreateArc(
                    contentID: arc.contentID,
                    contentType: arc.contentType,
                    mode: .edit(arc),
                    dataStore: dataStore
                )
            }
            .task {
                await loadPoster()
            }
        }

         var poster: some View {
            ZStack {
                if let url = APIService.shared.imageURL(path: posterPath) {
                    AsyncImage(url: url) { state in
                        switch state {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()

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

         func delete() {
            do {
                try deleteArc.execute(
                    arcID: arc.id,
                    dataStore: dataStore
                )
            } catch let error as ArcError {
                onError(error.localizedDescription)
            } catch let error as UserError {
                onError(error.localizedDescription)
            } catch {
                onError(
                    "This Arc could not be deleted. Please try again."
                )
            }
        }

         func loadPoster() async {
            do {
                let details = try await APIService.shared.fetchContentDetails(
                    ContentID: arc.contentID,
                    type: arc.contentType
                )

                await MainActor.run {
                    posterPath = details["poster_path"] as? String
                }
            } catch {
                // The poster is supplementary UI, so don't interrupt
                // the user with an error just because it failed to load.
                print("Failed to load poster: \(error)")
            }
        }
    }
}
