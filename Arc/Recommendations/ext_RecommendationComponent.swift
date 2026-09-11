//
//  ext_RecommendationComponent.swift
//  Arc
//
//  Created by Ziyan Nadeem on 11/9/2026.
//

import SwiftUI

extension RecommendationsComponent{
    func toggleGenre(_ genre: String) {
       didSave = false

       if selectedGenres.contains(genre) {
           selectedGenres.remove(genre)
       } else {
           selectedGenres.insert(genre)
       }
   }

    func save() {
       guard let user else {
           showErrorMessage(UserError.localUserNotFound.localizedDescription)
           return
       }

       do {
           try updateGenres.execute(
               userID: user.id,
               dataStore: dataStore,
               updatedGenres: Array(selectedGenres)
           )

           withAnimation(.easeInOut) {
               didSave = true
           }
       } catch let error as UserError {
           showErrorMessage(error.localizedDescription)
       } catch {
           showErrorMessage(
               "Your genre preferences could not be saved. Please try again."
           )
       }
   }

    func showErrorMessage(_ message: String) {
       errorMessage = message
       showError = true
   }

    func loadGenres() async {
       do {
           async let movieGenresResult = APIService.shared.fetchGenreList(type: "movies")
           async let tvGenresResult = APIService.shared.fetchGenreList(type: "tv")

           let (movieResult, tvResult) = try await (
               movieGenresResult,
               tvGenresResult
           )

           let movieNames = (movieResult["genres"] as? [[String: Any]] ?? [])
               .compactMap { $0["name"] as? String }

           let tvNames = (tvResult["genres"] as? [[String: Any]] ?? [])
               .compactMap { $0["name"] as? String }

           let combined = Array(Set(movieNames + tvNames)).sorted()

           await MainActor.run {
               availableGenres = combined
               selectedGenres = Set(user?.preferredGenres ?? [])
               isLoading = false
           }
       } catch {
           await MainActor.run {
               isLoading = false
               showErrorMessage(
                   "We couldn't load the available genres. Please try again."
               )
           }
       }
   }
}
