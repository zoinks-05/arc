//
//  CreateArc.swift
//  Arc
//
//  Created by Ziyan Nadeem on 23/8/2026.
//
import SwiftUI

struct CreateArc: View {
    
enum CreateArcMode {
    case new
    case edit(ArcModel)
}

let contentID: Int
var contentType: String = "movie"
let mode: CreateArcMode

@State private var backdrop: String?
@State private var title: String?
@State private var id: String?
@State private var sentiment: String = "feels"
@State private var ReflectionText: String = ""
@State private var DescriptionText: String = ""
@State private var availableThemes: [String] = []
@State private var selectedThemes: [String] = []
@State private var isSpoiler: Bool = false
@State private var Score: Int = 0
@State var dataStore: DummyDataStore

private let publishArc = CreateArcUseCase()
private let editArc = ArcEditUseCase()

private var editingArc: ArcModel? {
    switch mode {
    case .new:
        return nil
    case .edit(let arc):
        return arc
    }
}

private var isEditing: Bool {
    editingArc != nil
}

var body: some View {

    ZStack {

        backdrop(path: backdrop)
            .task {
                loadExistingArcIfNeeded()
                await loadData()
            }

        VStack {

            Text(title ?? "Title Not Found")
                .font(.title.bold())
                .padding(.horizontal)
                .padding(.vertical, 5)
                .glassEffect(.regular, in: Capsule())
                .lineLimit(1)
                .padding(.top)
                .truncationMode(.tail)
                .frame(maxWidth: 250)

            VStack(spacing: 4) {

                TextField("Reflection", text: $ReflectionText, axis: .vertical)
                    .font(.title2.bold())
                    .padding()
                    .frame(width: 350, height: 200, alignment: .top)
                    .glassEffect(in: RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
                    .onChange(of: ReflectionText) { _, newValue in
                        if newValue.trimmingCharacters(in: .whitespacesAndNewlines).count > 75 {
                            ReflectionText = String(newValue.prefix(75))
                        }
                    }

                HStack(spacing: 8) {

                    ForEach(["feels", "believes", "thinks"], id: \.self) { option in

                        let isSelected = sentiment == option

                        Text(option)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .glassEffect(
                                isSelected ? .regular.tint(.white) : .regular,
                                in: Capsule()
                            )
                            .opacity(isSelected ? 0.8 : 0.6)
                            .onTapGesture {
                                withAnimation(.bouncy()) {
                                    sentiment = option
                                }
                            }
                    }
                }

                .padding(.horizontal, 4)

                Divider()
                    .padding(8)

                HStack {

                    Spacer()

                    Text("\(ReflectionText.trimmingCharacters(in: .whitespacesAndNewlines).count)/75")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                .frame(width: 300)
                .padding(.bottom, 4)
                .padding(.horizontal, 4)
            }

            .frame(width: 350)
            .glassEffect(in: RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))

            VStack(spacing: 4) {

                TextField(
                    "Optional Description",
                    text: $DescriptionText,
                    axis: .vertical
                )
                .padding()
                .frame(width: 350, height: 150, alignment: .top)
                .glassEffect(in: RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
                .onChange(of: DescriptionText) { _, newValue in
                    if newValue.trimmingCharacters(in: .whitespacesAndNewlines).count > 250 {
                        DescriptionText = String(newValue.prefix(250))
                    }
                }

                HStack {

                    Spacer()

                    Text("\(DescriptionText.trimmingCharacters(in: .whitespacesAndNewlines).count)/250")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                .frame(width: 350)
                .padding(.horizontal, 4)
            }

            if !availableThemes.isEmpty {

                VStack(spacing: 6) {

                    ScrollView(.horizontal, showsIndicators: false) {

                        HStack(spacing: 8) {

                            ForEach(availableThemes, id: \.self) { theme in

                                let isSelected = selectedThemes.contains(theme)

                                Text(theme)
                                    .font(.subheadline)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .glassEffect(
                                        isSelected ? .regular.tint(.white) : .regular,
                                        in: Capsule()
                                    )
                                    .opacity(!isSelected && selectedThemes.count >= 3 ? 0.4 : 0.7)
                                    .onTapGesture {
                                        toggleTheme(theme)
                                    }
                            }
                        }

                        .padding(.top)
                        .padding(.horizontal)
                    }

                    HStack {

                        Spacer()

                        Text("\(selectedThemes.count)/3")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    .padding(.horizontal)
                    .padding(.bottom)
                }

                .frame(width: 350)
                .glassEffect(in: RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
            }

            HStack {

                Toggle(isOn: $isSpoiler) {

                    Text("Spoiler")
                        .font(.subheadline)
                        .foregroundStyle(.white)
                }

                .tint(.red)
                .padding(10)

                Spacer()

                Stepper(value: $Score, in: 0...10) {

                    HStack {

                        Text("\(Score)/10")
                            .font(.subheadline.bold())
                            .foregroundStyle(.white)
                    }
                }

                .padding(10)
            }

            .frame(width: 350)
            .glassEffect(in: RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))

            Button {

                switch mode {

                case .new:

                    publishArc.execute(
                        reflection: ReflectionText,
                        description: DescriptionText,
                        sentiment: sentiment,
                        themes: selectedThemes,
                        rating: Score,
                        isSpoiler: isSpoiler,
                        contentID: contentID,
                        contentType: contentType,
                        dataStore: dataStore
                    )

                    ReflectionText = ""
                    DescriptionText = ""
                    selectedThemes.removeAll()
                    isSpoiler = false
                    Score = 0
                    sentiment = "feels"

                case .edit(let arc):

                    editArc.execute(
                        arcID: arc.id,
                        dataStore: dataStore,
                        newReflection: ReflectionText,
                        newDescription: DescriptionText,
                        newSentiment: sentiment,
                        newThemes: selectedThemes.map { Optional($0) },
                        newRating: Score,
                        newIsSpoiler: isSpoiler
                    )
                }

            } label: {

                Text(isEditing ? "Save Changes" : "Publish")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: 350, height: 50)
                    .background(
                        ReflectionText.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).count >= 50
                        ? AnyShapeStyle(
                            LinearGradient(
                                colors: [.purple, .red],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        : AnyShapeStyle(Color.gray.opacity(0.4))
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 16,
                            style: .continuous
                        )
                    )
            }

            .buttonStyle(.plain)
            .disabled(
                ReflectionText.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ).count < 50
            )
            .animation(
                .easeInOut,
                value: ReflectionText.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ).count >= 50
            )
        }

        .toolbar(.hidden, for: .tabBar)
    }
}

private func loadExistingArcIfNeeded() {

    guard case .edit(let arc) = mode else {
        return
    }

    ReflectionText = arc.reflection
    DescriptionText = arc.desription ?? ""
    sentiment = arc.sentiment
    selectedThemes = arc.themes
    Score = arc.rating
    isSpoiler = arc.isSpoiler
}

private func loadData() async {

    do {

        let res = try await APIService.shared.fetchContentDetails(
            ContentID: contentID,
            type: contentType
        )

        await MainActor.run {

            backdrop = res["backdrop_path"] as? String

            title = res[
                contentType == "movie"
                ? "title"
                : "name"
            ] as? String

            let genreObjects =
                res["genres"] as? [[String: Any]] ?? []

            availableThemes = genreObjects.compactMap {
                $0["name"] as? String
            }
        }

    } catch {

        print("Failed to load backdrop: \(error)")
    }
}

}

extension CreateArc {

func backdrop(path: String?) -> some View {

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

    .ignoresSafeArea(edges: .all)
}

private func toggleTheme(_ theme: String) {

    if let index = selectedThemes.firstIndex(of: theme) {

        selectedThemes.remove(at: index)

    } else if selectedThemes.count < 3 {

        selectedThemes.append(theme)
    }
}

}
