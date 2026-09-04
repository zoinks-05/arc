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
    @State private var commentCounts = 0

    @State var dataStore: DummyDataStore

    @State private var scrollPosition: Int?
    @State private var showDetail = false
    @State private var showRecommendation = false
    @State private var showCreateArc = false
    @State private var showComments = false

    @State private var detailsCache: [UUID: [String: Any]] = [:]

    private var users: [UserModel] {
        dataStore.users
    }

    private var arcs: [ArcModel] {
        dataStore.arcs
    }

    private var comments: [CommentModel] {
        dataStore.comments
    }

    private var replies: [ReplyModel] {
        dataStore.replies
    }

    private var filteredArcs: [ArcModel] {
        dataStore.arcs.filter { $0.contentType == type }
    }
    
    private func commentsForArcCount(_ arc: ArcModel) -> Int {
        var res = 0
        let filtered = comments.filter { $0.arcID == arc.id}
        for reply in replies {
            if filtered.contains(where: { $0.id == reply.commentID }) {
                res += 1
            }
        }
        return res + filtered.count
    }
    
    private func userDetails(_ arc: ArcModel) -> UserModel? {
        users.first { $0.id == arc.userID }
    }
    
    private var currentArc: ArcModel? {
        guard !filteredArcs.isEmpty else { return nil }
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
    private let toggleArcLike = ArcLikesUseCase()
    
    private let toggleRepostUseCase = ArcRepostUseCase()
        
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
                            Text("No items for \(type.uppercased())")
                                .font(.headline)
                                .padding()
                        } else {
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
                            .id(type)
                            .transition(.scale .combined(with: .opacity))
                            .onChange(of: scrollPosition) { _, _ in
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
            // Sheet must apply detents on the sheet content
            .sheet(isPresented: $showComments) {
                if let arc = currentArc {
                    CommentComponet(
                        description: arc.desription,
                        createdAt: arc.createdAt,
                        dataStore: dataStore,
                        arcID: arc.id
                    )
                    .presentationDetents([.medium, .large], selection: .constant(.medium))
                    .presentationDragIndicator(.visible)
                } else {
                    // Fallback content
                    Text("No comments")
                        .padding()
                        .presentationDetents([.fraction(0.35), .large], selection: .constant(.fraction(0.35)))
                        .presentationDragIndicator(.visible)
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
        let user = users.first { $0.id == arc.userID }
        let localCommentCount = commentsForArcCount(arc)
        
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
                                if let user {
                                    Text("\(user.username) \(arc.sentiment)")
                                        .font(.title.bold())
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                        .padding(.horizontal)
                                        .padding(.vertical, 5)
                                        .glassEffect(.regular, in: Capsule())
                                } else {
                                    Text(arc.sentiment)
                                        .font(.title.bold())
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                        .padding(.horizontal)
                                        .padding(.vertical, 5)
                                        .glassEffect(.regular, in: Capsule())
                                }
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
                        scrollPage_social_button(image: "message", count: localCommentCount, present: $showComments)
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
            toggleArcLike.execute(arcID: arc.id, dataStore: dataStore)
        }
    }
}

// Extension at file scope
extension ScrollPageView {
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
                    present?.wrappedValue = true
                }
                if let newtype {
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
    
    func scrollPage_social_button(tab: String? = nil, image: String, conditional: Binding<Bool>? = nil, usecase: SocialUseCases? = nil, arcID: UUID? = nil, count: Int = 0, present: Binding<Bool>? = nil) -> some View {
        VStack {
            Button {
                withAnimation(.bouncy()) {
                    if let tab { selectedTab = tab }
                    if let conditional { conditional.wrappedValue.toggle() }
                    present?.wrappedValue = true
                    switch usecase {
                    case .like:
                        if let arcID { toggleArcLike.execute(arcID: arcID, dataStore: dataStore) }
                    case .repost:
                        if let arcID { toggleRepostUseCase.execute(arcID: arcID, dataStore: dataStore) }
                    case .none, .some(.view):
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
            .id(path)
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
}
