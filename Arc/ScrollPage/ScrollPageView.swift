//
//  ScrollPageView.swift
//  Arc
//
//  Created by Ziyan Nadeem on 30/8/2026.
//

import SwiftUI

struct ScrollPageView: View {
    
    enum ScrollMode {
        case feed
        case focused(contentID: Int)
        case profile(userID: UUID, contentType: String, startingArcID: UUID?)
    }

    @State private var selectedTab = "movie"
    @State private var prevTab: String?
    @State private var type = "movie"
    @State private var commentCounts = 0

    @State private var spoilerRevealed: Set<UUID> = []

    @State var dataStore: DummyDataStore
    @State var mode: ScrollMode = .feed


    @State private var scrollPosition: UUID?

    @State private var showDetail = false
    @State private var showRecommendation = false
    @State private var showCreateArc = false
    @State private var showComments = false

    @State private var detailsCache: [UUID: [String: Any]] = [:]
    @State private var feedOrder: [UUID] = []
    

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
        filteredArcs(for: mode)
    }
    
    private var startingArcID: UUID? {

        switch mode {

        case .profile(_, _, let startingArcID):
            return startingArcID

        default:
            return nil
        }
    }
    
    private var viewerRef : UserModel? {
        users.first {$0.username == "localUser"}
    }

    private func commentsForArcCount(_ arc: ArcModel) -> Int {
        var res = 0
        let filtered = comments.filter { $0.arcID == arc.id }
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
        // Look the arc up by its own id rather than by index.
        guard let scrollPosition,
              let match = filteredArcs.first(where: { $0.id == scrollPosition }) else {
            return filteredArcs.first
        }
        return match
    }

    private var currentTitle: String {
        guard let arc = currentArc,
              let details = detailsCache[arc.id] else {
            return "Loading..."
        }
        if arc.contentType == "movie" {
            let ids = filteredArcs.map(\.id)
            let duplicates = Dictionary(grouping: ids, by: { $0 }).filter { $0.value.count > 1 }
            if !duplicates.isEmpty {
                print("Duplicate arc IDs found:", duplicates.keys)
            }
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

    private let toggleArcLike = ArcLikesUseCase()
    private let toggleRepostUseCase = ArcRepostUseCase()

    var body: some View {
        NavigationStack {
            ZStack {
                backdrop(path: currentPosterPath)
                
                if selectedTab == "movie" || selectedTab == "tv" {
                    if filteredArcs.isEmpty {
                        Text("No items for \(type.uppercased())")
                            .font(.headline)
                            .padding()
                    } else {
                        ScrollView(
                            .vertical,
                            showsIndicators: false
                        ) {

                            LazyVStack(spacing: 0) {

                                ForEach(filteredArcs) { arc in

                                    arcPage(arc: arc)
                                        .containerRelativeFrame(
                                            [.horizontal, .vertical]
                                        )
                                        .id(arc.id)
                                        .task {
                                            await loadDetailsIfNeeded(for: arc)
                                        }
                                }
                            }
                            .scrollTargetLayout()
                        }
                        .scrollTargetBehavior(.paging)
                        .scrollPosition(id: $scrollPosition)
                        .onAppear {
                            if feedOrder.isEmpty {
                                buildFeedOrder()
                            }
                            if scrollPosition == nil {
                                scrollPosition = startingArcID
                            }
                        }
                        .onChange(of: type) { _, _ in
                            buildFeedOrder()
                        }
                        .onChange(of: viewerRef?.preferredGenres) { _, _ in
                            buildFeedOrder()
                        }
                    }
                }
                
                if case .feed = mode {

                    VStack(spacing: 0) {

                        HStack {

                            scrollPage_button(
                                newtype: nil,
                                image: "plus",
                                present: $showCreateArc
                            )
                            .navigationDestination(isPresented: $showCreateArc) {

                                if let arc = currentArc {

                                    CreateArc(
                                        contentID: arc.contentID,
                                        contentType: arc.contentType,
                                        mode: .new,
                                        dataStore: dataStore
                                    )
                                }
                            }

                            Spacer()

                            scrollPage_button(
                                tab: "movie",
                                newtype: "movie",
                                image: "film"
                            )

                            scrollPage_button(
                                tab: "tv",
                                newtype: "tv",
                                image: "tv"
                            )

                            scrollPage_button(
                                tab: "search",
                                newtype: nil,
                                image: "magnifyingglass"
                            )

                            Spacer()

                            scrollPage_button(
                                newtype: nil,
                                image: "slider.horizontal.3",
                                present: $showRecommendation
                            )
                            .navigationDestination(
                                isPresented: $showRecommendation
                            ) {
                                // Find the local user (dataset uses "localUser")
                                let localUser = users.first { $0.username == "localUser" }
                                RecommendationsComponent(dataStore: dataStore, user: localUser)
                            }
                        }

                        .padding(.horizontal)
                        .padding(.top, 20)
                        .padding(.bottom, 12)

                        if selectedTab == "search" {

                            SearchView(dataStore: dataStore)
                                .transition(.scale)
                        }

                        Spacer()
                    }

                    .background(
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .mask(
                                LinearGradient(
                                    stops: [
                                        .init(color: .black, location: 0.3),
                                        .init(color: .clear, location: 1)
                                    ],
                                    startPoint: .top,
                                    endPoint: .center
                                )
                            )
                            .frame(height: 140)
                            .frame(
                                maxHeight: .infinity,
                                alignment: .top
                            )
                            .ignoresSafeArea(edges: .top)
                    )
                }
            }
            .sheet(isPresented: $showComments) {
                if let arc = currentArc {
                    CommentComponent(
                        description: arc.desription,
                        createdAt: arc.createdAt,
                        dataStore: dataStore,
                        arcID: arc.id
                    )
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                } else {
                    Text("No comments")
                        .padding()
                        .presentationDetents([.fraction(0.35), .large])
                        .presentationDragIndicator(.visible)
                }
            }
        }
    }

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
        let isRevealed = spoilerRevealed.contains(arc.id)

        VStack(spacing: 0) {
            Color.clear.frame(height:100)
            HStack {
                Text(title)
                    .font(.title.bold())
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    .glassEffect(.regular, in: Capsule())
                    .lineLimit(1)
                    .padding(.top)
                    .truncationMode(.tail)
                    .frame(maxWidth: 250)
            }
            .padding(.top)


            HStack {
                Group {
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading, spacing: 10) {
                            // Username + sentiment row becomes tappable to push ProfileView
                            NavigationLink {
                                ProfileView(dataStore: dataStore, user: user)
                            } label: {
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
                            }
                            .buttonStyle(.plain)

                            GeometryReader { geo in
                                VStack(spacing: 0) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(arc.reflection)
                                            .font(.title)
                                            .padding()
                                            .blur(radius: arc.isSpoiler && !isRevealed ? 20 : 0)
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
                                            Image(systemName: isRevealed ? "eye" : "eye.slash")
                                                .onTapGesture {
                                                    withAnimation {
                                                        if isRevealed {
                                                            spoilerRevealed.remove(arc.id)
                                                        } else {
                                                            spoilerRevealed.insert(arc.id)
                                                        }
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
                            .frame(height: 300)
                            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20))
                        }
                    }
                    .padding()

                    VStack {
                        scrollPage_social_button(image: arc.hasLiked ? "heart.fill" : "heart", usecase: .like, arcID: arc.id, count: arc.likes)
                        scrollPage_social_button(image: "message", count: localCommentCount, present: $showComments)
                        scrollPage_social_button(
                            image: arc.hasReposted ? "repeat.1" : "repeat", usecase: .repost, arcID: arc.id, count: arc.reposts
                        )
                    }
                    .padding(.horizontal, 5)
                }
            }

            HStack {
                VStack(alignment: .leading) {
                    Text(arc.desription ?? "")
                        .font(.subheadline)
                        .lineLimit(3)
                        .truncationMode(.tail)
                        .padding(.horizontal, 8)
                        .frame(maxWidth: 250, alignment: .leading)
                        .blur(radius: arc.isSpoiler && !isRevealed ? 20 : 0)

                    Text(arc.createdAt, style: .date)
                        .font(.subheadline)
                        .lineLimit(3)
                        .truncationMode(.tail)
                        .padding(.horizontal, 8)
                        .frame(maxWidth: 150, alignment: .leading)
                }
                .frame(height: 144, alignment: .bottom)
                Spacer()
                VStack {
                    Spacer()
                    if let url = APIService.shared.imageURL(path: posterPath) {
                        NavigationLink {
                            ContentDetailView(contentID: arc.contentID, type: arc.contentType, dataStore: dataStore)
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
            .padding(.bottom, 72)
            
        }
        .onTapGesture(count: 2) {
            toggleArcLike.execute(arcID: arc.id, dataStore: dataStore)
        }
    }
}

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
                }
                if let newtype {
                    if type != newtype {
                        type = newtype
                        scrollPosition = nil
                    }
                }
            }
            present?.wrappedValue = true
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
                    switch usecase {
                    case .like:
                        if let arcID { toggleArcLike.execute(arcID: arcID, dataStore: dataStore) }
                    case .repost:
                        if let arcID { toggleRepostUseCase.execute(arcID: arcID, dataStore: dataStore) }
                    case .none, .some(.view):
                        break
                    }
                }
                present?.wrappedValue = true
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
    
    private func buildFeedOrder() {
        let preferredGenres = Set(viewerRef?.preferredGenres ?? [])

        let base = dataStore.arcs.filter {
            $0.contentType == type && $0.userID != viewerRef?.id
        }

        let matching = preferredGenres.isEmpty
            ? []
            : base.filter { !Set($0.themes).isDisjoint(with: preferredGenres) }

        let matchingIDs = Set(matching.map(\.id))
        let rest = base.filter { !matchingIDs.contains($0.id) }

        feedOrder = (matching.shuffled() + rest.shuffled()).map(\.id)
    }
    
    private func filteredArcs(for mode: ScrollMode) -> [ArcModel] {
        switch mode {
            
        case .feed:
            let base = dataStore.arcs.filter {
                $0.contentType == type && $0.userID != viewerRef?.id
            }
            let baseByID = Dictionary(uniqueKeysWithValues: base.map { ($0.id, $0) })

            var result = feedOrder.compactMap { baseByID[$0] }

            let knownIDs = Set(feedOrder)
            let newArcs = base.filter { !knownIDs.contains($0.id) }
            if !newArcs.isEmpty {
                result.append(contentsOf: newArcs)
            }

            return result
            
        case .focused(let contentID):
            return dataStore.arcs.filter {
                $0.contentID == contentID
            }
        
        case .profile(
            let userID,
            let contentType,
            _
        ):

            return dataStore.arcs.filter {

                $0.userID == userID &&
                $0.contentType == contentType
            }
        }
        
    }
}

#Preview {
}
