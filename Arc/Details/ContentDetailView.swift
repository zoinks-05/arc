//
//  ContentDetailView.swift
//  Arc
//
//  Created by Ziyan Nadeem on 23/8/2026.
//

import SwiftUI

struct ContentDetailView: View {
    @State var contentID: Int
    @State var type: String // "movie" or "tv"
    
    // Core data (dictionary to match current APIService)
    @State  var content: [String: Any] = [:]
    
    // UI State
    @State  var isLoading: Bool = false
    @State  var synopsisExpanded = false
    @State  var showMoreInfo = false
    @State  var showAddSheet = false
    
    // Display collections (stubs you can replace with real data)
    @State  var cast: [[String: Any]] = []
    @State  var related: [[String: Any]] = []
    
    @State var dataStore: DummyDataStore
    
    // MARK: - Body
    var body: some View {
        NavigationStack{
            ZStack(alignment: .top) {
                if isLoading || content.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            Color.clear.frame(height: 250) // clears the fixed header below
                            
                            NavigationLink {
                                ScrollPageView(
                                    dataStore: dataStore,
                                    mode: .focused(contentID: contentID)
                                )
                            } label: {
                                Text("See Arcs")
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity)
                                    .glassEffect()
                            }
                            
                            MainCard(
                                label: "Synopsis",
                                value: content["overview"] as? String ?? "N/A",
                                expanded: $synopsisExpanded
                            )
                            
                            if !cast.isEmpty {
                                charactersCard()
                            } else {
                                charactersPlaceholderCard()
                            }
                            
                            if !related.isEmpty {
                                relatedCard(related: related)
                            } else {
                                relatedPlaceholderCard()
                            }
                        }
                        .padding(.horizontal, 12)
                    }
                    
                    // Fixed — not inside the ScrollView, does not move
                    header()
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .task {
                await loadAll()
            }
        }
    }
}
