//
//  ScrollPageView.swift
//  Arc
//
//  Created by Ziyan Nadeem on 30/8/2026.
//

import SwiftUI

struct ScrollPageView: View {
    
    @State private var selectedTab = "movie"
    @State private var prevTab: String?
    @State private var type = "movie"
    @State private var showSpoiler = false
    
    // Strongly-typed feed using ArcModel sample data
    @State var arcs : [ArcModel]
    
    // Paging state
    @State private var scrollPosition: Int?
    @State private var showDetail = false
    @State private var showRecommendation = false
    @State private var showCreateArc = false
    
    // Lightweight details cache per Arc (title/name + poster_path)
    // Key by arc.id to avoid collisions if contentID repeats across types.
    @State private var detailsCache: [UUID: [String: Any]] = [:]
    
    // Only show arcs that match the currently selected content type
    private var filteredArcs: [ArcModel] {
        arcs.filter { $0.contentType == type }
    }
    
    private var currentArc: ArcModel? {
        // If nothing to show, return nil
        guard !filteredArcs.isEmpty else { return nil }
        // Use scrollPosition if valid, else fall back to first
        guard let scrollPosition,
              filteredArcs.indices.contains(scrollPosition) else {
            return filteredArcs.first
        }
        return filteredArcs[scrollPosition]
    }
    
    // Convenience accessors for current arc’s fetched details
    private var currentTitle: String {
        guard let arc = currentArc,
              let details = detailsCache[arc.id] else {
            return "Loading..."
        }
        if arc.contentType == "movie" {
            return (details["title"] as? String) ?? "Unknown Title"
        } else {
            return (details["name"] as? String) ?? "Unknown Title"
        }
    }
    
    private var currentPosterPath: String? {
        guard let arc = currentArc,
              let details = detailsCache[arc.id] else {
            return nil
        }
        return details["poster_path"] as? String
    }
    
    // Computed so we can call instance helpers (self is available)
    private let toggleArcLike = LikesUseCase()
    
    private let toggleRepostUseCase = RepostUseCase()
        
    var body: some View {
        NavigationStack {
            ZStack {
                backdrop(path: currentPosterPath)
                
                VStack(spacing: 0) {
                    // Header — stays fixed, does not scroll
                    HStack {
                        scrollPage_button(tab: "createarc", newtype: nil, image: "plus", present: $showCreateArc)
                            .navigationDestination(isPresented: $showCreateArc) {
                                Text("Creating Coming Soon...")
                                    .onDisappear{
                                        selectedTab = prevTab ?? type
                                    }
                            }
                        Spacer()
                        scrollPage_button(tab: "movie", newtype: "movie", image: "film")
                        scrollPage_button(tab: "tv", newtype: "tv", image: "tv")
                        scrollPage_button(tab: "search", newtype: nil, image: "magnifyingglass")
                        Spacer()
                        scrollPage_button(tab: "recommendation", newtype: nil, image: "slider.horizontal.3", present: $showRecommendation)
                            .navigationDestination(isPresented: $showRecommendation) {
                                Text("Recommendations Coming Soon...")
                                    .onDisappear{
                                        selectedTab = prevTab ?? type
                                    }
                            }
                    }
                    .padding(.horizontal)

                    
                    if selectedTab == "search" {
                        SearchView()
                            .transition(.scale)
                        Spacer()
                    }

                    
                    if selectedTab == "movie" || selectedTab == "tv" {
                        if filteredArcs.isEmpty {
                            // Safe fallback when no arcs for selected type
                            Text("No items for \(type.uppercased())")
                                .font(.headline)
                                .padding()
                        } else {
                            // Paging feed — TikTok style
                            GeometryReader { geo in
                                ScrollView(.vertical, showsIndicators: false) {
                                    LazyVStack(spacing: 0) {
                                        ForEach(filteredArcs.indices, id: \.self) { index in
                                            let arc = filteredArcs[index]
                                            arcPage(arc: arc)
                                                .frame(width: geo.size.width, height: geo.size.height)
                                                .clipped()
                                                .id(index)
                                                .task {
                                                    showSpoiler = false
                                                    await loadDetailsIfNeeded(for: arc)
                                                }
                                        }
                                    }
                                    .scrollTargetLayout()
                                }
                                .scrollTargetBehavior(.paging)
                                .scrollPosition(id: $scrollPosition)
                            }
                            .id(type) // fresh feed identity when switching movie <-> tv
                            .transition(.scale .combined(with: .opacity))
                            .onChange(of: scrollPosition) { _, _ in
                                // Preload current arc’s details for backdrop/title
                                if let arc = currentArc {
                                    Task { await loadDetailsIfNeeded(for: arc) }
                                }
                            }
                            .onAppear {
                                if let arc = currentArc {
                                    Task { await loadDetailsIfNeeded(for: arc) }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // One full-screen page of the feed
    @ViewBuilder
    func arcPage(arc: ArcModel) -> some View {
        let details = detailsCache[arc.id]
        let title: String = {
            if let d = details {
                return arc.contentType == "movie"
                ? (d["title"] as? String ?? "Unknown Title")
                : (d["name"] as? String ?? "Unknown Title")
            }
            return "Loading..."
        }()
        let posterPath = details?["poster_path"] as? String
        
        VStack(spacing: 0) {
            Text(title)
                .font(.title.bold())
                .padding(.horizontal)
                .padding(.vertical, 5)
                .glassEffect(.regular, in: Capsule())
                .lineLimit(1)
                .padding(.top)
                .truncationMode(.tail)
                .frame(maxWidth: 250)
            
            Spacer()
            
            // Content
            HStack {
                Group {
                    VStack(alignment: .leading) {
                        // ArcCard
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text(arc.sentiment)
                                    .font(.title.bold())
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .padding(.horizontal)
                                    .padding(.vertical, 5)
                                    .glassEffect(.regular, in: Capsule())
                                Spacer()
                            }
                            
                            GeometryReader { geo in
                                VStack(spacing: 0) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(arc.reflection)
                                            .font(.title)
                                            .padding()
                                            .blur(radius: arc.isSpoiler && !showSpoiler ? 20 : 0)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .topLeading)
                                    .frame(height: geo.size.height * 0.8, alignment: .topLeading)
                                    
                                    Divider()
                                        .padding(.horizontal)
                                    
                                    HStack {
                                        Text("\(arc.rating)")
                                            .font(.caption.bold())
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                        if arc.isSpoiler {
                                            Image(systemName: showSpoiler ? "eye" : "eye.slash")
                                                .onTapGesture {
                                                    withAnimation {
                                                        showSpoiler.toggle()
                                                    }
                                                }
                                        }
                                        Spacer()
                                        if !arc.themes.isEmpty {
                                            HStack(spacing: 6) {
                                                ForEach(arc.themes, id: \.self) { theme in
                                                    Text(theme)
                                                        .font(.caption)
                                                        .padding(.horizontal, 8)
                                                        .padding(.vertical, 4)
                                                        .lineLimit(1)
                                                }
                                            }
                                            .padding(.horizontal)
                                            .padding(.bottom, 6)
                                        }
                                    }
                                    .frame(height: geo.size.height * 0.2)
                                    .padding(.horizontal, 16)
                                }
                            }
                            .frame(height: 350)
                            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20))
                        }
                    }
                    .padding()
                    
                    // SocialFeatures
                    VStack {
                        scrollPage_social_button(image: arc.hasLiked ? "heart.fill" :  "heart" , usecase: .like, arcID: arc.id, count: arc.likes)
                        scrollPage_social_button(image: "message")
                        scrollPage_social_button(
                            image: arc.hasReposted ? "repeat.1" : "repeat", usecase: .repost, arcID: arc.id, count: arc.reposts
                        )
                    }
                    .padding(.horizontal,5)
                }
            }

            
            // Footer
            HStack {
                VStack {
                    Spacer()
                    Text(arc.desription ?? "")
                        .font(.subheadline)
                        .lineLimit(3)
                        .truncationMode(.tail)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .blur(radius: arc.isSpoiler && !showSpoiler ? 20 : 0)
                    
                    Text(arc.createdAt, style: .date)
                        .font(.subheadline)
                        .lineLimit(3)
                        .truncationMode(.tail)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                VStack{
                    Spacer()
                    if let url = APIService.shared.imageURL(path: posterPath) {
                        NavigationLink {
                            // Use the arc’s own contentType to avoid mismatches
                            ContentDetailView(contentID: arc.contentID, type: arc.contentType)
                        } label: {
                            AsyncImage(url: url) { state in
                                switch state {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                case .failure:
                                    Color.gray
                                case .empty:
                                    ProgressView()
                                @unknown default:
                                    Color.gray
                                }
                            }
                            .frame(width: 90, height: 144)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(.white.opacity(0.5), lineWidth: 1.5)
                            )
                            .shadow(radius: 6)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .padding(.bottom,  36)
        }
        .onTapGesture(count: 2) {
            toggleArcLike.execute(arcID: arc.id, arcs: &arcs)
        }
    }
}

// Extension at file scope
extension ScrollPageView {
    // Fetch minimal details for an arc and cache them
    enum SocialUseCases {
        case like
        case repost
        case view
    }
    func loadDetailsIfNeeded(for arc: ArcModel) async {
        if detailsCache[arc.id] != nil { return }
        do {
            let details = try await APIService.shared.fetchContentDetails(
                ContentID: arc.contentID,
                type: arc.contentType
            )
            await MainActor.run {
                detailsCache[arc.id] = details
            }
        } catch {
            print("Failed to load details for contentID \(arc.contentID): \(error)")
        }
    }
    
    
    @ViewBuilder
    func scrollPage_button(tab: String? = nil, newtype: String? = nil, image: String, present: Binding<Bool>? = nil) -> some View {
        Button {
            withAnimation(.bouncy()) {
                if let tab {
                    prevTab = selectedTab
                    selectedTab = tab
                    // If a presentation binding is supplied, toggle it on
                    present?.wrappedValue = true
                }
                if let newtype {
                    // Update type and reset paging index to avoid out-of-range
                    if type != newtype {
                        type = newtype
                        scrollPosition = 0
                    }
                }
            }
        } label: {
            Image(systemName: image)
                .font(.title)
                .foregroundColor(.white)
                .padding(10)
        }
    }
    
    func scrollPage_social_button(tab: String? = nil, image: String, conditional: Binding<Bool>? = nil, usecase: SocialUseCases? = nil, arcID: UUID? = nil, count: Int = 0) -> some View {
        VStack{
            Button {
                withAnimation(.bouncy()) {
                    if let tab {
                        selectedTab = tab
                    }
                    if let conditional{
                        conditional.wrappedValue.toggle()
                    }
                    
                    switch usecase {
                    case .like:
                        if let arcID {
                            toggleArcLike.execute(arcID: arcID, arcs: &arcs)
                        }
                    case .repost:
                        if let arcID {
                            toggleRepostUseCase.execute(arcID: arcID, arcs: &arcs)
                        }
                        break
                        
                    case .none:
                        break
                    case .some(.view):
                        break
                    }
                }
                
            } label: {
                Image(systemName: image)
                    .font(.title)
                    .foregroundColor(.white)
                    .padding(3)
            }
            
            if count > 0 {
                Text(String(formatSocial(count: count)))
            }
        }
    }
    
    func formatSocial(count: Int) -> String {
        let num = Double(count)
        
        switch num {
        case 1_000_000_000...:
            return String(format: "%.1fb", num / 1_000_000_000)
        case 1_000_000...:
            return String(format: "%.1fm", num / 1_000_000)
        case 1_000...:
            return String(format: "%.1fk", num / 1_000)
        default:
            return "\(count)"
        }
    }
    
    func backdrop(path: String?) -> some View {
        GeometryReader { geo in
            AsyncImage(url: APIService.shared.imageURL(path: path)) { state in
                switch state {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure, .empty:
                    Color.black
                @unknown default:
                    Color.black
                }
            }
            .id(path) // re-fades when the backdrop image changes
            .frame(width: geo.size.width, height: geo.size.height * 1.5)
            .clipped()
            .blur(radius: 10)
            .overlay(
                LinearGradient(
                    colors: [.black.opacity(0), .black.opacity(1)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(maxWidth: .infinity, alignment: .top)
            .animation(.easeInOut(duration: 0.3), value: path)
        }
        .ignoresSafeArea(edges: .all)
    }
}

#Preview {
    ScrollPageView(arcs: ArcModel.sampleData)
}
