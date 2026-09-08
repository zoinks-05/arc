//
//  ArcEditUseCase.swift
//  Arc
//
//  Created by Ziyan Nadeem on 8/9/2026.
//

import Foundation

final class ArcEditUseCase {

    func execute(
        arcID: UUID,
        dataStore: DummyDataStore,
        newReflection: String?,
        newDescription: String?,
        newSentiment: String?,
        newThemes: [String?],
        newRating: Int?,
        newIsSpoiler: Bool?
    ) {
        guard let i = dataStore.arcs.firstIndex(where: { $0.id == arcID }) else {
            return
        }
        
        if let newReflection {
            dataStore.arcs[i].reflection = newReflection
        }
        
        if let newDescription {
            dataStore.arcs[i].desription = newDescription
        }
        
        if let newSentiment {
            dataStore.arcs[i].sentiment = newSentiment
        }
        
        let themes = newThemes.compactMap { $0 }
        
        if !themes.isEmpty {
            dataStore.arcs[i].themes = themes
        }
        
        if let newRating {
            dataStore.arcs[i].rating = newRating
        }
        
        if let newIsSpoiler {
            dataStore.arcs[i].isSpoiler = newIsSpoiler
        }
        
        dataStore.saveData()
    }
}
