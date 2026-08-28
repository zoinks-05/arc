//
//  ContentDetailView.swift
//  Arc
//
//  Created by Ziyan Nadeem on 23/8/2026.
//

import SwiftUI

struct ContentDetailView: View {
    
    let contentID: Int
    let type: String // "movie" or "tv"
    
    // Core data (dictionary to match current APIService)
    @State private var content: [String: Any] = [:]
    
    // UI State
    @State private var isLoading: Bool = false
    @State private var synopsisExpanded = false
    @State private var showMoreInfo = false
    @State private var showAddSheet = false
    
    // Display collections (stubs you can replace with real data)
    @State private var cast: [[String: Any]] = []
    @State private var related: [[String: Any]] = []
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            if isLoading || content.isEmpty {
                ProgressView()
                    .frame(maxHeight: .infinity, alignment: .center)
            } else {
                header()
                
                // Only a single "Main" section (no Reviews)
                ScrollView {
                    VStack(spacing: 12) {
                        // Synopsis (TMDB: "overview")
                        MainCard(
                            label: "Synopsis",
                            value: content["overview"] as? String ?? "N/A",
                            expanded: $synopsisExpanded
                        )
                        
                        // Characters (Cast)
                        if !cast.isEmpty {
                            charactersCard()
                        } else {
                            // Placeholder characters card
                            charactersPlaceholderCard()
                        }
                        
                        // Related (Recommendations)
                        if !related.isEmpty {
                            relatedCard(related: related)
                        } else {
                            // Placeholder related card
                            relatedPlaceholderCard()
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 10)
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .task {
            await loadAll()
        }
    }
}

// MARK: - Subviews
extension ContentDetailView {
    
    // Header with poster, title/name, basic actions, and backdrop background
    @ViewBuilder
    func header() -> some View {
        HStack(alignment: .bottom, spacing: 12) {
            // Poster stub (replace with AsyncImage and TMDB URL later)
            AsyncImage(url: posterUrl) { state in
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
            .frame(width: 120, height: 180)
            .clipped()
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 10) {
                    Text(displayTitle)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .sheet(isPresented: $showAddSheet) {
                        addToWatchlistSheet()
                    }
                }
                
                HStack(spacing: 10) {
                    // Score stub (TMDB vote_average)
                    let score = (content["vote_average"] as? Double) ?? 0.0
                    Text(String(format: "%.1f", score))
                        .font(.caption)
                        .foregroundColor(.white)
                    
                    // Studio/Network stub
                    Text(primaryCompanyOrNetwork)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(1)
                    
                    Button {
                        showMoreInfo = true
                    } label: {
                        Text("More Info")
                            .font(.caption)
                            .foregroundColor(.white)
                            .underline()
                    }
                    .sheet(isPresented: $showMoreInfo) {
                        moreInfoSheet()
                            .presentationDetents([.medium, .large])
                    }
                    
                    Spacer()
                }
            }
        }
        .padding()
        .frame(height: 250)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            // Backdrop stub (replace with AsyncImage and TMDB URL later)
            AsyncImage(url: BackDropUrl) { state in
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
            .frame(width: 480, height: 240)

            .clipped()
            .cornerRadius(8)
        )
    }
    
    // Main card view
    func MainCard(label: String, value: String, expanded: Binding<Bool>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundColor(.primary)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.primary)
                .lineLimit(expanded.wrappedValue ? nil : 4)
            Button {
                expanded.wrappedValue.toggle()
            } label: {
                Text(expanded.wrappedValue ? "Show Less" : "Show More")
                    .font(.caption)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    // Characters (cast) card
    func charactersCard() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cast")
                .font(.caption)
                .foregroundStyle(.primary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(cast.indices, id: \.self) { i in
                        let person = cast[i]
                        let name = person["name"] as? String ?? "Unknown"
                        let character = person["character"] as? String ?? ""
                        
                        VStack(alignment: .leading, spacing: 6) {
                            // Profile image stub
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 80, height: 120)
                                .overlay(
                                    Text("Img")
                                        .foregroundColor(.secondary)
                                        .font(.caption2)
                                )
                                .cornerRadius(8)
                            
                            Text(name)
                                .font(.caption)
                                .foregroundStyle(.primary)
                                .lineLimit(2)
                            
                            if !character.isEmpty {
                                Text(character)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        .frame(width: 100, height: 170)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                    }
                }
            }
        }
        .padding(10)
        .background(Color(.secondarySystemBackground))
        .frame(maxWidth: .infinity, alignment: .leading)
        .cornerRadius(12)
    }
    
    // Placeholder characters card (when no data yet)
    func charactersPlaceholderCard() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cast")
                .font(.caption)
                .foregroundStyle(.primary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<5, id: \.self) { _ in
                        VStack(alignment: .leading, spacing: 6) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.25))
                                .frame(width: 80, height: 120)
                                .cornerRadius(8)
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 80, height: 10)
                            Rectangle()
                                .fill(Color.gray.opacity(0.15))
                                .frame(width: 60, height: 8)
                        }
                        .frame(width: 100, height: 170)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                    }
                }
            }
        }
        .padding(10)
        .background(Color(.secondarySystemBackground))
        .frame(maxWidth: .infinity, alignment: .leading)
        .cornerRadius(12)
    }
    
    // Related card (recommendations)
    func relatedCard(related: [[String: Any]]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Related")
                .font(.caption)
                .foregroundStyle(.primary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(related.indices, id: \.self) { i in
                        let item = related[i]
                        let title = (type == "movie")
                            ? (item["title"] as? String ?? "N/A")
                            : (item["name"] as? String ?? "N/A")
                        let mediaType = item["media_type"] as? String ?? type
                        
                        VStack(alignment: .leading, spacing: 6) {
                            // Poster stub
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 100, height: 150)
                                .overlay(
                                    Text("Img")
                                        .foregroundColor(.secondary)
                                        .font(.caption2)
                                )
                                .cornerRadius(8)
                            
                            Text(title)
                                .font(.caption)
                                .foregroundStyle(.primary)
                                .lineLimit(2)
                            
                            Text(mediaType.uppercased())
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .frame(width: 110)
                        .padding(10)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                }
            }
        }
        .padding(10)
        .background(Color(.secondarySystemBackground))
        .frame(maxWidth: .infinity, alignment: .leading)
        .cornerRadius(12)
    }
    
    // Placeholder related card
    func relatedPlaceholderCard() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Related")
                .font(.caption)
                .foregroundStyle(.primary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<5, id: \.self) { _ in
                        VStack(alignment: .leading, spacing: 6) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.25))
                                .frame(width: 100, height: 150)
                                .cornerRadius(8)
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 90, height: 10)
                            Rectangle()
                                .fill(Color.gray.opacity(0.15))
                                .frame(width: 70, height: 8)
                        }
                        .frame(width: 110)
                        .padding(10)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                }
            }
        }
        .padding(10)
        .background(Color(.secondarySystemBackground))
        .frame(maxWidth: .infinity, alignment: .leading)
        .cornerRadius(12)
    }
    
    // Add to Watchlist sheet (styling only; you’ll wire logic and WatchStatus)
    func addToWatchlistSheet() -> some View {
        NavigationStack {
            
        }
    }
    
    // More Info sheet (styling with common TMDB fields)
    func moreInfoSheet() -> some View {
        VStack(spacing: 0) {
            Text(displayTitle)
                .font(.title.bold())
                .padding(.top, 10)
                .padding(.vertical, 10)
            
            Text(secondaryTitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Divider()
                .padding(.vertical, 4)
            
            ScrollView {
                VStack(spacing: 10) {
                    if !companyOrNetworkNames.isEmpty {
                        tagRow(label: type == "movie" ? "Production Companies" : "Networks",
                               tags: companyOrNetworkNames)
                            .padding(.horizontal, 10)
                    }
                    
                    if let genres = content["genres"] as? [[String: Any]] {
                        tagRow(label: "Genres",
                               tags: genres.compactMap { $0["name"] as? String })
                            .padding(.horizontal, 10)
                    }
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        stat(label: "Type", value: type.uppercased())
                        if type == "movie" {
                            let runtime = content["runtime"] as? Int ?? 0
                            stat(label: "Runtime", value: runtime > 0 ? "\(runtime) min" : "N/A")
                            let release = content["release_date"] as? String ?? "N/A"
                            stat(label: "Release", value: release)
                        } else {
                            let eps = content["number_of_episodes"] as? Int ?? 0
                            stat(label: "Episodes", value: eps > 0 ? "\(eps)" : "N/A")
                            let firstAir = content["first_air_date"] as? String ?? "N/A"
                            stat(label: "First Air", value: firstAir)
                        }
                        stat(label: "Status", value: (content["status"] as? String) ?? "N/A")
                        let score = (content["vote_average"] as? Double) ?? 0.0
                        stat(label: "Score", value: String(format: "%.1f", score))
                        let popularity = (content["popularity"] as? Double) ?? 0.0
                        stat(label: "Popularity", value: String(format: "%.0f", popularity))
                    }
                    .padding(.horizontal, 10)
                    
                    if let tagline = content["tagline"] as? String, !tagline.isEmpty {
                        stat(label: "Tagline", value: tagline)
                            .padding(.horizontal, 10)
                    }
                }
                .padding(.bottom, 12)
            }
        }
    }
    
    // Tag row
    func tagRow(label: String, tags: [String]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.primary)
            if tags.count > 4 {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(tags, id: \.self) { tag in
                        Text(tag)
                            .font(.subheadline)
                    }
                }
            } else {
                HStack(spacing: 6) {
                    ForEach(tags, id: \.self) { tag in
                        Text(tag)
                            .font(.subheadline)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    // Stat row
    func stat(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.primary)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Data loading (stubbed for styling; replace with real API calls when ready)
extension ContentDetailView {
    func loadAll() async {
        isLoading = true
        defer { isLoading = false }
        do {
            // Details via existing APIService
            content = try await APIService.shared.fetchContentDetails(
                ContentID: contentID,
                type: type
            )
            
            // Stub cast and related with empty arrays for now.
            // Replace with real API calls to:
            // - "\(tmdbBaseURL)/\(type)/\(contentID)/credits"
            // - "\(tmdbBaseURL)/\(type)/\(contentID)/recommendations"
            // Example: cast = result["cast"] as? [[String: Any]] ?? []
            // Example: related = result["results"] as? [[String: Any]] ?? []
            cast = []
            related = []
        } catch {
            print("Error loading content: \(error)")
        }
    }
}

// MARK: - Helpers
extension ContentDetailView {
    var displayTitle: String {
        if type == "movie" {
            return (content["title"] as? String) ?? "Unknown Title"
        } else {
            return (content["name"] as? String) ?? "Unknown Title"
        }
    }
    
    var secondaryTitle: String {
        if type == "movie" {
            return (content["original_title"] as? String) ?? ""
        } else {
            return (content["original_name"] as? String) ?? ""
        }
    }
    
    var companyOrNetworkNames: [String] {
        if type == "movie" {
            let companies = content["production_companies"] as? [[String: Any]] ?? []
            return companies.compactMap { $0["name"] as? String }
        } else {
            let networks = content["networks"] as? [[String: Any]] ?? []
            return networks.compactMap { $0["name"] as? String }
        }
    }
    
    var primaryCompanyOrNetwork: String {
        companyOrNetworkNames.first ?? "Unknown"
    }
    
    var posterUrl: URL? {
        guard let path = content["poster_path"] as? String else {
            return nil
        }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }
    
    var BackDropUrl: URL? {
        guard let path = content["backdrop_path"] as? String else {
            return nil
        }
        return URL(string: "https://image.tmdb.org/t/p/w780\(path)")
    }
    
    // Fix: cast is an array; use the first cast member (or adjust as needed)
    var profileUrl: URL? {
        guard let first = cast.first,
              let path = first["profile_path"] as? String else {
            return nil
        }
        return URL(string: "https://image.tmdb.org/t/p/w185\(path)")
    }
    
    // Fix: related is an array; use the first related item (or adjust as needed)
    var relatedUrl: URL? {
        guard let first = related.first,
              let path = first["poster_path"] as? String else {
            return nil
        }
        return URL(string: "https://image.tmdb.org/t/p/w300\(path)")
    }
}

#Preview {
    ContentDetailView(contentID: 157336, type: "movie")
}
