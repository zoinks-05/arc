//
//  Home.swift
//  Arc
//
//  Created by Ziyan Nadeem on 23/8/2026.
//

import SwiftUI

struct Home: View {

    @State var dataStore: DummyDataStore
    @State private var suggestions: [SuggestionItem] = []
    @State private var isLoadingMore = false

    // Short, quiet framing lines — the title carries the weight now, not this.
    private let suggestionPhrases = [
        "Arc thinks you'll like this",
        "Picked for you",
        "Arc has a feeling about this one",
        "Worth a look, Arc says",
        "Arc's next pick for you"
    ]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color.black.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 24) {
                        Color.clear.frame(height: 90)

                        ForEach(Array(suggestions.enumerated()), id: \.element.id) { index, item in
                            SuggestionCard(item: item, dataStore: dataStore)
                                .onAppear {
                                    if index == suggestions.count - 1 {
                                        Task { await loadMoreIfNeeded() }
                                    }
                                }
                        }

                        if isLoadingMore {
                            ProgressView()
                                .tint(.white)
                                .padding()
                        }
                    }
                    .padding()
                }

                VStack(spacing: 0) {
                    HStack {
                        Text("Arc")
                            .font(.system(size: 52, weight: .semibold, design: .serif))
                            .italic()
                            .foregroundStyle(.white)
                    }
                    .frame(width: 200)
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .padding(.bottom, 12)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 140)
                .background(
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .mask(
                            LinearGradient(
                                stops: [
                                    .init(color: .white, location: 0.3),
                                    .init(color: .white, location: 0.7),
                                    .init(color: .clear, location: 1)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
                .ignoresSafeArea(edges: .top)
            }
        }
        .task {
            await loadBatch()
        }
    }

    private func loadMoreIfNeeded() async {
        guard !isLoadingMore else { return }
        await loadBatch()
    }

    private func loadBatch() async {
        isLoadingMore = true

        var newItems: [SuggestionItem] = []
        for _ in 0..<5 {
            do {
                let content = try await APIService.shared.fetchRandomHomeContent()
                let type = (content["media_type"] as? String) ?? "movie"
                let contentID = content["id"] as? Int
                let title = type == "movie"
                    ? (content["title"] as? String ?? "Unknown Title")
                    : (content["name"] as? String ?? "Unknown Title")
                let posterPath = content["poster_path"] as? String
                let phrase = suggestionPhrases.randomElement() ?? "Arc thinks you'll like this"

                newItems.append(SuggestionItem(id: UUID(), title: title, posterPath: posterPath, phrase: phrase, contentID: contentID, contentType: type))
            } catch {
                print("Failed to fetch suggestion: \(error)")
            }
        }

        suggestions.append(contentsOf: newItems)
        isLoadingMore = false
    }
}

extension Home {

    struct SuggestionItem: Identifiable, Hashable {
        let id: UUID
        let title: String
        let posterPath: String?
        let phrase: String
        let contentID: Int?
        let contentType: String
    }

    struct SuggestionCard: View {
        let item: SuggestionItem
        let dataStore: DummyDataStore

        var body: some View {
            Group {
                if let contentID = item.contentID {
                    NavigationLink {
                        ContentDetailView(contentID: contentID, type: item.contentType, dataStore: dataStore)
                    } label: {
                        cardBody
                    }
                    .buttonStyle(.plain)
                } else {
                    cardBody
                }
            }
        }

        private var cardBody: some View {
            ZStack(alignment: .bottom) {
                poster

                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0.45),
                        .init(color: .black.opacity(0.92), location: 1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(item.contentType == "movie" ? "Movie" : "Series")
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .glassEffect(.regular, in: Capsule())
                        Spacer()
                    }

                    Spacer()

                    Text(item.phrase)
                        .font(.system(size: 12, weight: .semibold, design: .serif))
                        .foregroundStyle(.white.opacity(0.7))

                    Text(item.title)
                        .font(.title.bold())
                        .foregroundStyle(.white)
                        .lineLimit(2)
                }
                .padding(20)
            }
            .frame(height: 520)
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(.white.opacity(0.15), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.5), radius: 20, y: 10)
        }

        @ViewBuilder
        private var poster: some View {
            if let url = APIService.shared.imageURL(path: item.posterPath) {
                AsyncImage(url: url) { state in
                    switch state {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .failure, .empty:
                        Color.gray
                    @unknown default:
                        Color.gray
                    }
                }
            } else {
                Color.gray.opacity(0.4)
            }
        }
    }
}
