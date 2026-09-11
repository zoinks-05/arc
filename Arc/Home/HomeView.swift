//
//  Home.swift
//  Arc
//
//  Created by Ziyan Nadeem on 23/8/2026.
//

import SwiftUI

struct Home: View {
    
    @State var dataStore: DummyDataStore
    let user: UserModel?
    @State  var suggestions: [SuggestionItem] = []
    @State  var isLoadingMore = false
    
    // Short, quiet framing lines — the title carries the weight now, not this.
     let suggestionPhrases = [
        "Arc thinks you'll like this",
        "Picked for you",
        "Arc has a feeling about this one",
        "Worth a look, Arc says",
        "Arc's next pick for you"
    ]
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color.black.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 24) {
                        Color.clear.frame(height: 90)
                        
                        ForEach(Array(suggestions.enumerated()), id: \.element.id) { index, item in
                            SuggestionCard(item: item, dataStore: dataStore)
                                .onAppear {
                                    if index == suggestions.count - 1 {
                                        Task { await loadMoreIfNeeded() }
                                    }
                                }
                        }
                        
                        if isLoadingMore {
                            ProgressView()
                                .tint(.white)
                                .padding()
                        }
                    }
                    .padding()
                }
                .refreshable{
                    await refreshFeed()
                }
                
                VStack(spacing: 0) {
                    HStack {
                        Text("Arc")
                            .font(.system(size: 52, weight: .semibold, design: .serif))
                            .italic()
                            .foregroundStyle(.white)
                    }
                    .frame(width: 200)
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .padding(.bottom, 12)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 140)
                .background(
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .mask(
                            LinearGradient(
                                stops: [
                                    .init(color: .white, location: 0.3),
                                    .init(color: .white, location: 0.7),
                                    .init(color: .clear, location: 1)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
                .ignoresSafeArea(edges: .top)
            }
        }
        .task {
            suggestions = await fetchBatch()
        }
    }
    

}


