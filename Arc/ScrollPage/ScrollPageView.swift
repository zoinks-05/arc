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
    @State private var type = "movie"
    @State private var spoilerRevealed: Set<UUID> = []

    @State var dataStore: DummyDataStore
    @State var mode: ScrollMode = .feed

    @State private var scrollPosition: UUID?
    @State private var showRecommendation = false
    @State private var showCreateArc = false
    @State private var showComments = false
    @State private var detailsCache: [UUID: [String: Any]] = [:]
    @State private var feedOrder: [UUID] = []

    @State private var errorMessage: String?
    @State private var showError = false

    private let toggleArcLike = ArcLikesUseCase()
    private let toggleRepostUseCase = ArcRepostUseCase()

    private var users: [UserModel] {
        dataStore.users
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

    private var viewerRef: UserModel? {
        users.first {
            $0.username.lowercased() == "localuser"
        }
    }

    private var currentArc: ArcModel? {
        guard !filteredArcs.isEmpty else {
            return nil
        }

        guard let scrollPosition else {
            return filteredArcs.first
        }

        return filteredArcs.first {
            $0.id == scrollPosition
        } ?? filteredArcs.first
    }

    private var currentPosterPath: String? {
        guard let arc = currentArc else {
            return nil
        }

        return detailsCache[arc.id]?["poster_path"] as? String
    }

    var body: some View {
        NavigationStack {
            ZStack {
                backdrop(path: currentPosterPath)

                if case .feed = mode, selectedTab == "search" {
                    VStack {
                        Spacer()
                            .frame(height: 80)

                        SearchView(dataStore: dataStore)
                            .transition(.scale)

                        Spacer()
                    }
                } else if filteredArcs.isEmpty {
                    emptyState
                } else {
                    arcScrollView
                }

                if case .feed = mode {
                    feedControls
                }
            }
            .sheet(isPresented: $showComments) {
                commentsSheet
            }
            .alert("Something needs attention", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(
                    errorMessage
                    ?? "Something went wrong. Please try again."
                )
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(
                systemName: selectedTab == "movie"
                ? "film.stack"
                : "tv"
            )
            .font(.system(size: 45))
            .foregroundStyle(.secondary)

            Text("No Arcs here yet")
                .font(.headline)

            Text("Be the first to leave your mark and create an Arc.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    private var arcScrollView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(filteredArcs) { arc in
                    arcPage(arc: arc)
                        .containerRelativeFrame([.horizontal, .vertical])
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
        .onChange(of: type) { _, newType in
            feedOrder = []
            buildFeedOrder()
            scrollPosition = nil
            spoilerRevealed.removeAll()
        }
        .onChange(of: viewerRef?.preferredGenres) { _, _ in
            buildFeedOrder()
        }
    }

    private var feedControls: some View {
        VStack(spacing: 0) {
            HStack {
                scrollPageButton(
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

                scrollPageButton(
                    tab: "movie",
                    newType: "movie",
                    image: "film"
                )

                scrollPageButton(
                    tab: "tv",
                    newType: "tv",
                    image: "tv"
                )

                scrollPageButton(
                    tab: "search",
                    image: "magnifyingglass"
                )

                Spacer()

                scrollPageButton(
                    image: "slider.horizontal.3",
                    present: $showRecommendation
                )
                .navigationDestination(isPresented: $showRecommendation) {
                    RecommendationsComponent(
                        dataStore: dataStore,
                        user: viewerRef
                    )
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
            .padding(.bottom, 12)
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

    private var commentsSheet: some View {
        Group {
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

    @ViewBuilder
    private func arcPage(arc: ArcModel) -> some View {
        let details = detailsCache[arc.id]
        let title = contentTitle(for: arc, details: details)
        let posterPath = details?["poster_path"] as? String
        let user = users.first { $0.id == arc.userID }
        let commentCount = commentsForArcCount(arc)
        let isRevealed = spoilerRevealed.contains(arc.id)

        VStack(spacing: 0) {
            Color.clear
                .frame(height: 100)

            Text(title)
                .font(.title.bold())
                .padding(.horizontal)
                .padding(.vertical, 5)
                .glassEffect(.regular, in: Capsule())
                .lineLimit(1)
                .padding(.top)
                .truncationMode(.tail)
                .frame(maxWidth: 250)
                .padding(.top)

            HStack {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading, spacing: 10) {
                        NavigationLink {
                            ProfileView(
                                dataStore: dataStore,
                                user: user
                            )
                        } label: {
                            HStack {
                                Text(
                                    user.map {
                                        "\($0.username) \(arc.sentiment)"
                                    } ?? arc.sentiment
                                )
                                .font(.title.bold())
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .padding(.horizontal)
                                .padding(.vertical, 5)
                                .glassEffect(.regular, in: Capsule())

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
                                        .blur(
                                            radius: arc.isSpoiler && !isRevealed
                                            ? 20
                                            : 0
                                        )
                                }
                                .frame(
                                    maxWidth: .infinity,
                                    alignment: .topLeading
                                )
                                .frame(
                                    height: geo.size.height * 0.8,
                                    alignment: .topLeading
                                )

                                Divider()
                                    .padding(.horizontal)

                                HStack {
                                    Text("\(arc.rating)")
                                        .font(.caption.bold())

                                    Image(systemName: "star.fill")
                                        .foregroundStyle(.yellow)

                                    if arc.isSpoiler {
                                        Image(
                                            systemName: isRevealed
                                            ? "eye"
                                            : "eye.slash"
                                        )
                                        .onTapGesture {
                                            withAnimation {
                                                toggleSpoiler(for: arc.id)
                                            }
                                        }
                                    }

                                    Spacer()

                                    if !arc.themes.isEmpty {
                                        HStack(spacing: 6) {
                                            ForEach(
                                                arc.themes,
                                                id: \.self
                                            ) { theme in
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
                        .glassEffect(
                            .regular,
                            in: RoundedRectangle(cornerRadius: 20)
                        )
                    }
                }
                .padding()

                VStack {
                    scrollPageSocialButton(
                        image: arc.hasLiked
                        ? "heart.fill"
                        : "heart",
                        useCase: .like,
                        arcID: arc.id,
                        count: arc.likes
                    )

                    scrollPageSocialButton(
                        image: "message",
                        count: commentCount,
                        present: $showComments
                    )

                    scrollPageSocialButton(
                        image: arc.hasReposted
                        ? "repeat.1"
                        : "repeat",
                        useCase: .repost,
                        arcID: arc.id,
                        count: arc.reposts
                    )
                }
                .padding(.horizontal, 5)
            }

            HStack {
                VStack(alignment: .leading) {
                    if let description = arc.desription,
                       !description.isEmpty {
                        Text(description)
                            .font(.subheadline)
                            .lineLimit(3)
                            .truncationMode(.tail)
                            .padding(.horizontal, 8)
                            .frame(maxWidth: 250, alignment: .leading)
                            .blur(
                                radius: arc.isSpoiler && !isRevealed
                                ? 20
                                : 0
                            )
                    } else {
                        Text("No description provided")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8)
                    }

                    Text(arc.createdAt, style: .date)
                        .font(.subheadline)
                        .padding(.horizontal, 8)
                }
                .frame(height: 144, alignment: .bottom)

                Spacer()

                if let url = APIService.shared.imageURL(path: posterPath) {
                    NavigationLink {
                        ContentDetailView(
                            contentID: arc.contentID,
                            type: arc.contentType,
                            dataStore: dataStore
                        )
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
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 14,
                                style: .continuous
                            )
                        )
                        .overlay(
                            RoundedRectangle(
                                cornerRadius: 14,
                                style: .continuous
                            )
                            .stroke(
                                .white.opacity(0.5),
                                lineWidth: 1.5
                            )
                        )
                        .shadow(radius: 6)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .padding(.bottom, 72)
        }
        .onTapGesture(count: 2) {
            handleArcLike(arc)
        }
    }
}

extension ScrollPageView {

    enum SocialUseCase {
        case like
        case repost
    }

    private func contentTitle(
        for arc: ArcModel,
        details: [String: Any]?
    ) -> String {
        guard let details else {
            return "Loading..."
        }

        if arc.contentType == "movie" {
            return details["title"] as? String ?? "Unknown Title"
        }

        return details["name"] as? String ?? "Unknown Title"
    }

    private func commentsForArcCount(_ arc: ArcModel) -> Int {
        let arcComments = comments.filter {
            $0.arcID == arc.id
        }

        let commentIDs = Set(arcComments.map(\.id))

        let replyCount = replies.filter {
            commentIDs.contains($0.commentID)
        }.count

        return arcComments.count + replyCount
    }

    private func toggleSpoiler(for arcID: UUID) {
        if spoilerRevealed.contains(arcID) {
            spoilerRevealed.remove(arcID)
        } else {
            spoilerRevealed.insert(arcID)
        }
    }

    private func handleArcLike(_ arc: ArcModel) {
        do {
            try toggleArcLike.execute(
                arcID: arc.id,
                dataStore: dataStore
            )
        } catch let error as ArcError {
            showErrorMessage(error.localizedDescription)
        } catch {
            showErrorMessage(
                "Your like could not be updated. Please try again."
            )
        }
    }

    @ViewBuilder
    private func scrollPageButton(
        tab: String? = nil,
        newType: String? = nil,
        image: String,
        present: Binding<Bool>? = nil
    ) -> some View {
        Button {
            withAnimation(.bouncy()) {
                if let tab {
                    selectedTab = tab
                }

                if let newType, type != newType {
                    type = newType
                    scrollPosition = nil
                }
            }

            present?.wrappedValue = true
        } label: {
            Image(systemName: image)
                .font(.title)
                .foregroundStyle(.white)
                .padding(10)
        }
    }

    private func scrollPageSocialButton(
        image: String,
        useCase: SocialUseCase? = nil,
        arcID: UUID? = nil,
        count: Int = 0,
        present: Binding<Bool>? = nil
    ) -> some View {
        VStack {
            Button {
                withAnimation(.bouncy()) {
                    switch useCase {
                    case .like:
                        if let arcID {
                            handleArcLike(
                                ArcModel(
                                    id: arcID,
                                    userID: UUID(),
                                    contentID: 0,
                                    contentType: "",
                                    reflection: "",
                                    sentiment: "",
                                    desription: nil,
                                    themes: [],
                                    rating: 0,
                                    likes: 0,
                                    reposts: 0,
                                    createdAt: Date(),
                                    isSpoiler: false,
                                    hasLiked: false,
                                    hasReposted: false,
                                    hasSeen: false
                                )
                            )
                        }

                    case .repost:
                        if let arcID {
                            handleArcRepost(arcID: arcID)
                        }

                    case .none:
                        break
                    }
                }

                present?.wrappedValue = true
            } label: {
                Image(systemName: image)
                    .font(.title)
                    .foregroundStyle(.white)
                    .padding(3)
            }

            if count > 0 {
                Text(formatSocial(count: count))
            }
        }
    }

    private func handleArcRepost(arcID: UUID) {
        do {
            try toggleRepostUseCase.execute(
                arcID: arcID,
                dataStore: dataStore
            )
        } catch let error as ArcError {
            showErrorMessage(error.localizedDescription)
        } catch {
            showErrorMessage(
                "Your repost could not be updated. Please try again."
            )
        }
    }

    private func formatSocial(count: Int) -> String {
        let number = Double(count)

        switch number {
        case 1_000_000_000...:
            return String(format: "%.1fb", number / 1_000_000_000)

        case 1_000_000...:
            return String(format: "%.1fm", number / 1_000_000)

        case 1_000...:
            return String(format: "%.1fk", number / 1_000)

        default:
            return "\(count)"
        }
    }

    private func loadDetailsIfNeeded(for arc: ArcModel) async {
        guard detailsCache[arc.id] == nil else {
            return
        }

        do {
            let details = try await APIService.shared.fetchContentDetails(
                ContentID: arc.contentID,
                type: arc.contentType
            )

            guard !Task.isCancelled else {
                return
            }

            await MainActor.run {
                detailsCache[arc.id] = details
            }
        } catch {
            guard !Task.isCancelled else {
                return
            }

            await MainActor.run {
                guard arc.contentType == type else {
                    return
                }

                showErrorMessage(
                    "We couldn't load this movie or TV show. Please try again."
                )
            }
        }
    }

    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }

    private func backdrop(path: String?) -> some View {
        GeometryReader { geo in
            AsyncImage(
                url: APIService.shared.imageURL(path: path)
            ) { state in
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
            .frame(
                width: geo.size.width,
                height: geo.size.height * 1.5
            )
            .clipped()
            .blur(radius: 10)
            .overlay(
                LinearGradient(
                    colors: [
                        .black.opacity(0),
                        .black.opacity(1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(
                maxWidth: .infinity,
                alignment: .top
            )
            .animation(
                .easeInOut(duration: 0.3),
                value: path
            )
        }
        .ignoresSafeArea()
    }

    private func buildFeedOrder() {
        let preferredGenres = Set(
            viewerRef?.preferredGenres ?? []
        )

        let base = dataStore.arcs.filter {
            $0.contentType == type &&
            $0.userID != viewerRef?.id
        }

        let matching = preferredGenres.isEmpty
            ? []
            : base.filter {
                !Set($0.themes).isDisjoint(with: preferredGenres)
            }

        let matchingIDs = Set(matching.map(\.id))

        let rest = base.filter {
            !matchingIDs.contains($0.id)
        }

        feedOrder = (
            matching.shuffled() +
            rest.shuffled()
        ).map(\.id)
    }

    private func filteredArcs(for mode: ScrollMode) -> [ArcModel] {
        switch mode {
        case .feed:
            let base = dataStore.arcs.filter {
                $0.contentType == type &&
                $0.userID != viewerRef?.id
            }

            let baseByID = Dictionary(
                uniqueKeysWithValues: base.map {
                    ($0.id, $0)
                }
            )

            var result = feedOrder.compactMap {
                baseByID[$0]
            }

            let knownIDs = Set(feedOrder)

            let newArcs = base.filter {
                !knownIDs.contains($0.id)
            }

            result.append(contentsOf: newArcs)

            return result

        case .focused(let contentID):
            return dataStore.arcs.filter {
                $0.contentID == contentID
            }

        case .profile(let userID, let contentType, _):
            return dataStore.arcs.filter {
                $0.userID == userID &&
                $0.contentType == contentType
            }
        }
    }
}
 
