//
//  ext_HomeView.swift
//  Arc
//
//  Created by Ziyan Nadeem on 11/9/2026.
//

import SwiftUI

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

         var cardBody: some View {
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
         var poster: some View {
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
    
    func refreshFeed() async {
       suggestions.removeAll()
       suggestions = await fetchBatch()
   }
    func loadMoreIfNeeded() async {
       guard !isLoadingMore else { return }
       suggestions.append(contentsOf: await fetchBatch())
   }
   
    func fetchBatch() async -> [SuggestionItem] {
       isLoadingMore = true
       defer { isLoadingMore = false }

       let preferredGenres = user?.preferredGenres ?? []
       var newItems: [SuggestionItem] = []

       for _ in 0..<5 {
           let fetchTask = Task {
               try await APIService.shared.fetchRecommendedContent(preferredGenres: preferredGenres)
           }

           do {
               let content = try await fetchTask.value
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

       return newItems
   }
}
