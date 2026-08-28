//
//  ContentView.swift
//  Arc
//
//  Created by Ziyan Nadeem on 23/8/2026.
//

import SwiftUI

struct ContentView: View {
    
    @State private var movieTitle = ""
    @State private var movieResults: [[String: Any]] = []
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    var body: some View {
        
        VStack(spacing: 20) {
            
            TextField("Enter movie", text: $movieTitle)
                .textFieldStyle(.roundedBorder)
            
            Button("Search TMDB") {
                Task {
                    await searchMovie()
                }
            }
            
            if isLoading {
                ProgressView()
            }
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }
            
            List(movieResults.indices, id: \.self) { index in
                
                let movie = movieResults[index]
                
                VStack(alignment: .leading) {
                    Text(movie["title"] as? String ?? "Unknown")
                        .font(.headline)
                    
                    Text(movie["release_date"] as? String ?? "Unknown")
                        .font(.caption)
                }
            }
        }
        .padding()
    }
    
    func searchMovie() async {
        
        guard !movieTitle.isEmpty else {
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        do {
            let result = try await APIService.shared.searchContent(
                query: movieTitle
            )
            
            movieResults = result["results"] as? [[String: Any]] ?? []
            
            print("TMDB Results:", movieResults.count)
            
        } catch {
            errorMessage = error.localizedDescription
            print("TMDB Error:", error)
        }
        
        isLoading = false
    }
}
#Preview {
    ContentView()
}
