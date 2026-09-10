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

    @State private var errorMessage: String?
    @State private var showError = false

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
            }  else {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10)
                    ],
                    spacing: 10
                ) {
                    ForEach(availableGenres, id: \.self) { genre in
                        let isSelected = selectedGenres.contains(genre)

                        Text(genre)
                            .font(.subheadline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .glassEffect(
                                isSelected ? .regular.tint(.white) : .regular,
                                in: RoundedRectangle(cornerRadius: 8)
                            )
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
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 16,
                            style: .continuous
                        )
                    )
            }
            .buttonStyle(.plain)
            .disabled(selectedGenres.isEmpty)
            .animation(.easeInOut, value: selectedGenres.isEmpty)
        }
        .padding()
        .task {
            await loadGenres()
        }
        .alert("Unable to save preferences", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(
                errorMessage
                ?? "Your genre preferences could not be saved. Please try again."
            )
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
        guard let user else {
            showErrorMessage(UserError.localUserNotFound.localizedDescription)
            return
        }

        do {
            try updateGenres.execute(
                userID: user.id,
                dataStore: dataStore,
                updatedGenres: Array(selectedGenres)
            )

            withAnimation(.easeInOut) {
                didSave = true
            }
        } catch let error as UserError {
            showErrorMessage(error.localizedDescription)
        } catch {
            showErrorMessage(
                "Your genre preferences could not be saved. Please try again."
            )
        }
    }

    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }

    private func loadGenres() async {
        do {
            async let movieGenresResult = APIService.shared.fetchGenreList(type: "movies")
            async let tvGenresResult = APIService.shared.fetchGenreList(type: "tv")

            let (movieResult, tvResult) = try await (
                movieGenresResult,
                tvGenresResult
            )

            let movieNames = (movieResult["genres"] as? [[String: Any]] ?? [])
                .compactMap { $0["name"] as? String }

            let tvNames = (tvResult["genres"] as? [[String: Any]] ?? [])
                .compactMap { $0["name"] as? String }

            let combined = Array(Set(movieNames + tvNames)).sorted()

            await MainActor.run {
                availableGenres = combined
                selectedGenres = Set(user?.preferredGenres ?? [])
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
                showErrorMessage(
                    "We couldn't load the available genres. Please try again."
                )
            }
        }
    }
}
