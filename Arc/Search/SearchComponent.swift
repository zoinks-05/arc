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
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                HStack {
                    TextField("Search", text: $Title)
                        .textFieldStyle(.roundedBorder)
                    Spacer()
                    Button {
                        type = (type == "movie" ? "tv" : "movie")
                    } label: {
                        Image(systemName: type == "movie" ? "film" : "tv")
                            .foregroundColor(.primary)
                    }
                    Button {
                        Task {
                            await search()
                        }
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.primary)
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
                List(Results.indices, id: \.self) { index in
                    let res = Results[index]
                    let resID = res["id"] as? Int ?? 0
                    let title = (type == "movie")
                        ? (res["title"] as? String ?? "Unknown")
                        : (res["name"] as? String ?? "Unknown")
                    
                    NavigationLink(
                        destination: ContentDetailView(contentID: resID, type: type)
                    ) {
                        VStack(alignment: .leading) {
                            Text(title)
                                .font(.headline)
                            Text(res["release_date"] as? String ?? res["first_air_date"] as? String ?? "Unknown")
                                .font(.caption)
                        }
                    }
                }
                .navigationTitle("Results")
            }
            .presentationDetents([.medium, .large])
        }
    }
    
    func search() async {
        guard !Title.isEmpty else {
            return
        }
        
        isLoading = true
        errorMessage = ""
        defer { isLoading = false }
        
        do {
            let result = try await APIService.shared.searchContent(
                query: Title,
                type: type
            )
            Results = result["results"] as? [[String: Any]] ?? []
            showResults = !Results.isEmpty
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    SearchView()
}
