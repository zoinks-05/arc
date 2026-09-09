//
//  SearchComponent.swift
//  Arc
//
//  Created by Ziyan Nadeem on 29/8/2026.
//

import SwiftUI

struct SearchView: View {
    @State private var title = ""
    @State private var results: [[String: Any]] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var type = "movie"
    @State private var showResults = false

    @State var dataStore: DummyDataStore = DummyDataStore()

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                HStack {
                    TextField("Search", text: $title)
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .glassEffect(.regular, in: Capsule())

                    Button {
                        type = type == "movie" ? "tv" : "movie"
                    } label: {
                        Image(systemName: type == "movie" ? "film" : "tv")
                            .foregroundStyle(.primary)
                            .padding(10)
                            .glassEffect(.regular, in: Circle())
                    }

                    Button {
                        Task {
                            await search()
                        }
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.primary)
                            .padding(10)
                            .glassEffect(.regular, in: Circle())
                    }
                    .disabled(isLoading)
                }

                if isLoading {
                    ProgressView()
                }

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
        }
        .sheet(isPresented: $showResults) {
            NavigationStack {
                ScrollView {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ],
                        spacing: 16
                    ) {
                        ForEach(
                            results.compactMap { result -> (id: Int, data: [String: Any])? in
                                guard let id = result["id"] as? Int else {
                                    return nil
                                }

                                return (id: id, data: result)
                            },
                            id: \.id
                        ) { item in
                            let result = item.data
                            let contentID = item.id

                            let title = type == "movie"
                                ? (result["title"] as? String ?? "Unknown")
                                : (result["name"] as? String ?? "Unknown")

                            NavigationLink {
                                ContentDetailView(
                                    contentID: contentID,
                                    type: type,
                                    dataStore: dataStore
                                )
                            } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    AsyncImage(
                                        url: APIService.shared.imageURL(
                                            path: result["poster_path"] as? String
                                        )
                                    ) { state in
                                        switch state {
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()

                                        case .failure:
                                            Color.gray.opacity(0.3)

                                        case .empty:
                                            ProgressView()

                                        @unknown default:
                                            Color.gray.opacity(0.3)
                                        }
                                    }
                                    .frame(width: 120, height: 165)
                                    .clipped()
                                    .cornerRadius(8)

                                    Text(title)
                                        .font(.caption)
                                        .foregroundStyle(.primary)
                                        .lineLimit(2)
                                }
                                .frame(width: 110)
                                .padding(10)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(12)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 12)
                }
                .navigationTitle("Results")
            }
            .presentationDetents([.medium, .large])
        }
    }

    private func search() async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            results = try await SearchContentUseCase().execute(
                query: title,
                type: type
            )

            showResults = !results.isEmpty
        } catch let error as ContentError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "We couldn't complete the search. Please try again."
        }
    }
}
