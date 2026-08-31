//
//  ScrollPageView.swift
//  Arc
//
//  Created by Ziyan Nadeem on 30/8/2026.
//

import SwiftUI

struct ScrollPageView: View {
    
    @State private var selectedTab = "movie"
    @State private var type = "movie"
    @State private var currentPosterPath: String? = "/IfR2DrWLb26AAdQFwGkhvPTflX.jpg"
    
    var body: some View {
        NavigationStack{
            ZStack{
                GeometryReader { geo in
                    AsyncImage(url: APIService.shared.imageURL(path: currentPosterPath)) { state in
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
                    .frame(maxWidth:.infinity, alignment: .top)
                }
                .ignoresSafeArea(edges: .all)
                
                VStack{
                    // Header
                    HStack{
                        
                        scrollPage_button(tab: "createarc", image: "plus")
                        
                        Spacer()
                        
                        scrollPage_button(tab: "movie", newtype: "movie", image: "film")
                        
                        scrollPage_button(tab: "tv", newtype: "tv", image: "tv")
                        
                        scrollPage_button(tab: "search", image: "magnifyingglass")
                        
                        Spacer()
                        
                        scrollPage_button(tab: "recommendation", image: "slider.horizontal.3")
                    }
                    .padding(.horizontal)
                    
                    if selectedTab == "search" {
                        SearchView()
                            .transition(.scale)
                    }
                    
                    if selectedTab == "movie" || selectedTab == "tv" {
                        Text("TitleName")
                            .font(.title.bold())
                            .id(type)
                            .transition(.scale)
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                            .glassEffect(.regular,in: Capsule())
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                    
                    Spacer()
                    
                    // Content
                    HStack{
                        
                    }
                    
                    Spacer()
                    
                    // Footer
                    
                    HStack{
                        
                    }
                }
            }
        }
    }
}

extension ScrollPageView {
    
    @ViewBuilder
    func scrollPage_button(tab: String, newtype: String? = nil, image: String) -> some View{
        Button {
            withAnimation(.bouncy()) {
                selectedTab = tab
                if let newtype {
                    type = newtype
                }
            }
        } label: {
            Image(systemName: image)
                .font(.title)
                .foregroundColor(.primary)
                .padding(10)
        }
    }
    
}

#Preview {
    ScrollPageView()
}
