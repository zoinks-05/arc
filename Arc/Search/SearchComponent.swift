//
//  SearchComponent.swift
//  Arc
//
//  Created by Ziyan Nadeem on 29/8/2026.
//

import SwiftUI

struct SearchView: View {
    
    @State private var Title = ""
    @State private var Results: [[String: Any]] = []
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var type = "movie"
    
    @State private var showResults = false

    // Provide a dataStore so we can navigate to ContentDetailView
    @State var dataStore: DummyDataStore = DummyDataStore()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                HStack {
                    TextField("Search", text: $Title)
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .glassEffect(.regular, in: Capsule())
                    
                    Spacer()
                    Button {
                        type = (type == "movie" ? "tv" : "movie")
                    } label: {
                        Image(systemName: type == "movie" ? "film" : "tv")
                            .foregroundColor(.primary)
                            .padding(10)
                            .glassEffect(.regular, in: Circle())
                    }
                    Button {
                        Task {
                            await search()
                        }
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.primary)
                            .padding(10)
                            .glassEffect(.regular, in: Circle())
                    }
                }
                
                if isLoading {
                    ProgressView()
                }
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
            .padding()
        }
        .sheet(isPresented: $showResults) {
            NavigationStack {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        // Build a collection with stable IDs from TMDB results
                        ForEach(Results.compactMap { res -> (id: Int, dict: [String: Any])? in
                            guard let id = res["id"] as? Int else { return nil }
                            return (id: id, dict: res)
                        }, id: \.id) { item in
                            let res = item.dict
                            let resID = item.id
                            let title = (type == "movie")
                                ? (res["title"] as? String ?? "Unknown")
                                : (res["name"] as? String ?? "Unknown")
                            
                            NavigationLink(
                                destination: ContentDetailView(contentID: resID, type: type, dataStore: dataStore)
                            ) {
                                VStack(alignment: .leading, spacing: 6) {
                                    // Poster
                                    AsyncImage(url: APIService.shared.imageURL(path: res["poster_path"] as? String)) { state in
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
                            .buttonStyle(PlainButtonStyle())
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
    
    func search() async {
        isLoading = true
        errorMessage = ""
        
        defer{
            isLoading = false
        }
        
        do {
            Results = try await SearchContentUseCase().execute(query: Title, type: type)
            showResults = !Results.isEmpty
        } catch {
            if let err = error as? SearchContentUseCase.SearchError {
                errorMessage = err.errorMessage
            } else {
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    SearchView()
}
