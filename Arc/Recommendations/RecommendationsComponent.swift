//
//  RecommendationsComponent.swift
//  Arc
//
//  Created by Ziyan Nadeem on 8/9/2026.
//

import SwiftUI

struct RecommendationsComponent: View {

    var dataStore: DummyDataStore
    let user: UserModel?

    @State private var availableGenres: [String] = []
    @State private var selectedGenres: Set<String> = []
    @State private var isLoading = true
    @State private var didSave = false

    private let updateGenres = UserUpdatesGenresUseCase()

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("What do you like watching?")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                Text("Pick as many as you want, this shapes what Arc recommends you.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
            }

            if isLoading {
                ProgressView()
                    .tint(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
            } else {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 100), spacing: 10)],
                    spacing: 10
                ) {
                    ForEach(availableGenres, id: \.self) { genre in
                        let isSelected = selectedGenres.contains(genre)
                        Text(genre)
                            .font(.subheadline)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 15)
                            .glassEffect(isSelected ? .regular.tint(.white) : .regular, in: RoundedRectangle(cornerRadius: CGFloat(8)))
                            .opacity(isSelected ? 0.8 : 0.6)
                            .onTapGesture {
                                withAnimation(.bouncy()) {
                                    toggleGenre(genre)
                                }
                            }
                    }
                }
            }

            Button {
                save()
            } label: {
                Text(didSave ? "Saved" : "Save preferences")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        selectedGenres.isEmpty
                        ? AnyShapeStyle(Color.gray.opacity(0.4))
                        : AnyShapeStyle(
                            LinearGradient(
                                colors: [.purple, .red],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                          )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(selectedGenres.isEmpty)
            .animation(.easeInOut, value: selectedGenres.isEmpty)
        }
        .padding()
        .task {
            await loadGenres()
        }
    }

    private func toggleGenre(_ genre: String) {
        didSave = false
        if selectedGenres.contains(genre) {
            selectedGenres.remove(genre)
        } else {
            selectedGenres.insert(genre)
        }
    }

    private func save() {
        guard let user else { return }
        updateGenres.execute(
            userID: user.id,
            dataStore: dataStore,
            updatedGenres: Array(selectedGenres)
        )
        withAnimation(.easeInOut) { didSave = true }
    }

    private func loadGenres() async {
        do {
            async let movieGenresResult = APIService.shared.fetchGenreList(type: "movies")
            async let tvGenresResult = APIService.shared.fetchGenreList(type: "tv")

            let (movieResult, tvResult) = try await (movieGenresResult, tvGenresResult)

            let movieNames = (movieResult["genres"] as? [[String: Any]] ?? [])
                .compactMap { $0["name"] as? String }
            let tvNames = (tvResult["genres"] as? [[String: Any]] ?? [])
                .compactMap { $0["name"] as? String }
            let combined = Array(Set(movieNames + tvNames)).sorted()

            await MainActor.run {
                availableGenres = combined
                if let user {
                    selectedGenres = Set(user.preferredGenres)
                }
                isLoading = false
            }
        } catch {
            print("Failed to load genres: \(error)")
            await MainActor.run { isLoading = false }
        }
    }
}
