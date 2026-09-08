//
//  dummyDataStore.swift
//  Arc
//
//  Created by Ziyan Nadeem on 4/9/2026.
//

import Foundation
import Observation

@Observable
final class DummyDataStore {

    var users: [UserModel] = []
    var arcs: [ArcModel] = []
    var comments: [CommentModel] = []
    var replies: [ReplyModel] = []

    private var fileURL: URL {
        FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
        .appendingPathComponent("dummyDataV4.json")
    }

    func loadData() {

        if FileManager.default.fileExists(atPath: fileURL.path) {

            // Dataset already exists → load it
            do {
                let data = try Data(contentsOf: fileURL)

                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601

                let dataset = try decoder.decode(
                    Dataset.self,
                    from: data
                )

                users = dataset.users
                arcs = dataset.arcs
                comments = dataset.comments
                replies = dataset.replies

                print("Loaded existing dummy data")

            } catch {
                print("Failed to load dummy data:", error)
            }

        } else {

            // No dataset → generate it
            let dataset = DummyDataGenerator.generateDataset()

            users = dataset.users
            arcs = dataset.arcs
            comments = dataset.comments
            replies = dataset.replies

            saveData()
        }
    }

    func saveData() {
        do {
            let dataset = Dataset(
                users: users,
                arcs: arcs,
                comments: comments,
                replies: replies
            )

            let encoder = JSONEncoder()
            encoder.outputFormatting = [
                .prettyPrinted,
                .sortedKeys
            ]
            encoder.dateEncodingStrategy = .iso8601

            let data = try encoder.encode(dataset)

            try data.write(
                to: fileURL,
                options: .atomic
            )
            
            print(data)

            print("Saved dummy data V2")

        } catch {
            print("Failed to save dummy data:", error)
        }
    }
}
