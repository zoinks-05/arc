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
    
    
    @FocusState private var isReflectionFocused: Bool
    @FocusState private var isDescriptionFocused: Bool
    @State private var backdrop: String?
    @State private var title: String?
    @State private var sentiment = "feels"
    @State private var reflectionText = ""
    @State private var descriptionText = ""
    @State private var availableThemes: [String] = []
    @State private var selectedThemes: [String] = []
    @State private var isSpoiler = false
    @State private var score = 0

    @State var dataStore: DummyDataStore

    @State private var errorMessage: String?
    @State private var showError = false
    @State private var isSaving = false

    private let publishArc = CreateArcUseCase()
    private let editArc = ArcEditUseCase()

    private var editingArc: ArcModel? {
        if case .edit(let arc) = mode {
            return arc
        }
        return nil
    }

    private var isEditing: Bool {
        editingArc != nil
    }

    private var reflectionCount: Int {
        reflectionText.trimmingCharacters(in: .whitespacesAndNewlines).count
    }

    private var descriptionCount: Int {
        descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).count
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

                reflectionSection
                descriptionSection

                if !availableThemes.isEmpty {
                    themesSection
                }

                settingsSection

                Button {
                    saveArc()
                } label: {
                    Text(isSaving ? "Saving..." : (isEditing ? "Save Changes" : "Publish"))
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(width: 350, height: 50)
                        .background(
                            reflectionCount >= 50
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
                .disabled(reflectionCount < 50 || isSaving)
                .animation(
                    .easeInOut,
                    value: reflectionCount >= 50
                )
            }
            .toolbar(.hidden, for: .tabBar)
        }
        .alert("Unable to save Arc", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "Your Arc could not be saved. Please try again.")
        }
    }

    private var reflectionSection: some View {
        VStack(spacing: 4) {
            TextField(
                "Reflection",
                text: $reflectionText,
                axis: .vertical
            )
            .font(.title2.bold())
            .padding()
            .frame(width: 350, height: 200, alignment: .top)
            .contentShape(Rectangle())
            .onTapGesture {
                isReflectionFocused = true
            }
            .focused($isReflectionFocused)
            .submitLabel(.done)
            .onChange(of: reflectionText) { _, newValue in
                if newValue.contains("\n") {
                    reflectionText = newValue.replacingOccurrences(of: "\n", with: "")
                    isReflectionFocused = false
                    return
                }
                if newValue.count > 75 {
                    reflectionText = String(newValue.prefix(75))
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

                Text("\(reflectionCount)/75")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 300)
            .padding(.bottom, 4)
            .padding(.horizontal, 4)
        }
        .frame(width: 350)
        .glassEffect(
            in: RoundedRectangle(
                cornerSize: CGSize(width: 20, height: 20)
            )
        )
    }

    private var descriptionSection: some View {
        VStack(spacing: 4) {
            TextField(
                "Optional Description",
                text: $descriptionText,
                axis: .vertical
            )
            .padding()
            .frame(width: 350, height: 150, alignment: .top)
            .glassEffect(
                in: RoundedRectangle(
                    cornerSize: CGSize(width: 20, height: 20)
                )
            )
            .contentShape(Rectangle())
            .onTapGesture {
                isDescriptionFocused = true
            }
            .focused($isDescriptionFocused)
            .submitLabel(.done)
            .onChange(of: descriptionText) { _, newValue in
                if newValue.contains("\n") {
                    descriptionText = newValue.replacingOccurrences(of: "\n", with: "")
                    isDescriptionFocused = false
                    return
                }
                if newValue.count > 250 {
                    descriptionText = String(newValue.prefix(250))
                }
            }
            
            HStack {
                Spacer()

                Text("\(descriptionCount)/250")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 350)
            .padding(.horizontal, 4)
        }
    }

    private var themesSection: some View {
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
                            .opacity(
                                !isSelected && selectedThemes.count >= 3
                                ? 0.4
                                : 0.7
                            )
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
        .glassEffect(
            in: RoundedRectangle(
                cornerSize: CGSize(width: 20, height: 20)
            )
        )
    }

    private var settingsSection: some View {
        HStack {
            Toggle(isOn: $isSpoiler) {
                Text("Spoiler")
                    .font(.subheadline)
                    .foregroundStyle(.white)
            }
            .tint(.red)
            .padding(10)

            Spacer()

            Stepper(value: $score, in: 0...10) {
                Text("\(score)/10")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
            }
            .padding(10)
        }
        .frame(width: 350)
        .glassEffect(
            in: RoundedRectangle(
                cornerSize: CGSize(width: 20, height: 20)
            )
        )
    }

    private func saveArc() {
        guard !isSaving else {
            return
        }

        isSaving = true
        defer { isSaving = false }

        do {
            switch mode {
            case .new:
                try publishArc.execute(
                    reflection: reflectionText,
                    description: descriptionText,
                    sentiment: sentiment,
                    themes: selectedThemes,
                    rating: score,
                    isSpoiler: isSpoiler,
                    contentID: contentID,
                    contentType: contentType,
                    dataStore: dataStore
                )

                resetForm()

            case .edit(let arc):
                try editArc.execute(
                    arcID: arc.id,
                    dataStore: dataStore,
                    newReflection: reflectionText,
                    newDescription: descriptionText,
                    newSentiment: sentiment,
                    newThemes: selectedThemes.map { Optional($0) },
                    newRating: score,
                    newIsSpoiler: isSpoiler
                )
            }
        } catch let error as ArcError {
            showErrorMessage(error.localizedDescription)
        } catch let error as UserError {
            showErrorMessage(error.localizedDescription)
        } catch {
            showErrorMessage(
                "Your Arc could not be saved. Please try again."
            )
        }
    }

    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }

    private func resetForm() {
        reflectionText = ""
        descriptionText = ""
        selectedThemes.removeAll()
        isSpoiler = false
        score = 0
        sentiment = "feels"
    }

    private func loadExistingArcIfNeeded() {
        guard case .edit(let arc) = mode else {
            return
        }

        reflectionText = arc.reflection
        descriptionText = arc.desription ?? ""
        sentiment = arc.sentiment
        selectedThemes = arc.themes
        score = arc.rating
        isSpoiler = arc.isSpoiler
    }

    private func loadData() async {
        do {
            let response = try await APIService.shared.fetchContentDetails(
                ContentID: contentID,
                type: contentType
            )

            await MainActor.run {
                backdrop = response["backdrop_path"] as? String

                title = response[
                    contentType == "movie" ? "title" : "name"
                ] as? String

                let genreObjects = response["genres"] as? [[String: Any]] ?? []

                availableThemes = genreObjects.compactMap {
                    $0["name"] as? String
                }
            }
        } catch {
            await MainActor.run {
                showErrorMessage(
                    "We couldn't load the movie or TV show details. Please try again."
                )
            }
        }
    }

    private func toggleTheme(_ theme: String) {
        if let index = selectedThemes.firstIndex(of: theme) {
            selectedThemes.remove(at: index)
        } else if selectedThemes.count < 3 {
            selectedThemes.append(theme)
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
        .ignoresSafeArea()
    }
}
