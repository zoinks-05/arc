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
    
    
    @FocusState  var isReflectionFocused: Bool
    @FocusState  var isDescriptionFocused: Bool
    @State  var backdrop: String?
    @State  var title: String?
    @State  var sentiment = "feels"
    @State  var reflectionText = ""
    @State  var descriptionText = ""
    @State  var availableThemes: [String] = []
    @State  var selectedThemes: [String] = []
    @State  var isSpoiler = false
    @State  var score = 0

    @State var dataStore: DummyDataStore

    @State  var errorMessage: String?
    @State  var showError = false
    @State  var isSaving = false

     let publishArc = CreateArcUseCase()
     let editArc = ArcEditUseCase()

     var editingArc: ArcModel? {
        if case .edit(let arc) = mode {
            return arc
        }
        return nil
    }

     var isEditing: Bool {
        editingArc != nil
    }

     var reflectionCount: Int {
        reflectionText.trimmingCharacters(in: .whitespacesAndNewlines).count
    }

     var descriptionCount: Int {
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

     
}
