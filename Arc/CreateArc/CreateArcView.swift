//
//  CreateArc.swift
//  Arc
//
//  Created by Ziyan Nadeem on 23/8/2026.
//

import SwiftUI

struct CreateArc: View {
    
    let contentID : Int
    let contentType : String = "movie"
    
    @State private var backdrop: String?
    
    var body: some View{
        backdrop(path:  backdrop)
            .task {
                await loadData()
            }
        
    }

    private func loadData() async {
        do {
            let res = try await APIService.shared.fetchContentDetails(ContentID: contentID, type: contentType)
            await MainActor.run {
                backdrop = res["backdrop_path"] as? String
            }
        } catch {
            print("Failed to load backdrop: \(error)")
        }
    }
}

extension CreateArc {
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
    CreateArc(contentID: 157336)
}
