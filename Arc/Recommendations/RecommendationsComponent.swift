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

    @State  var availableGenres: [String] = []
    @State  var selectedGenres: Set<String> = []
    @State  var isLoading = true
    @State  var didSave = false

    @State  var errorMessage: String?
    @State  var showError = false

     let updateGenres = UserUpdatesGenresUseCase()

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


}
