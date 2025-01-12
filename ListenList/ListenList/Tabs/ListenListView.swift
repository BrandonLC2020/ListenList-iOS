//
//  ListenListView.swift
//  ListenList
//
//  Created by Brandon Lamer-Connolly on 10/11/24.
//

import SwiftUI
import FirebaseFirestore

struct ListenListView: View {
    
    @State private var cards: [Card] = [] // Holds the list of cards
    @State private var songs: [Song] = [] // Use the SwiftUI-compatible Song type
    @State private var isLoading = true     // Track loading state
    
    func createCard(from song: Song) -> Card {
        let media = Media(input: .song(song)) // Wrap the Song in a MediaType
        return Card(input: .song, media: media, id: song.id) // Create the Card
    }
    
    func fetchSongList() {
        var songIds = [String]()
        DatabaseManager.shared.fetchSongIds { documents, error in
            if let error = error {
                print("Error fetching song IDs: \(error.localizedDescription)")
                self.isLoading = false
            } else if let documents = documents {
                for document in documents {
                    let id = document.documentID
                    songIds.append(id)
                }
                
                var fetchedSongs: [Song] = []
                let group = DispatchGroup()
                
                for songId in songIds {
                    group.enter()
                    DatabaseManager.shared.fetchSong(withId: songId) { songDTO, error in
                        if let error = error {
                            print("Error fetching song with ID \(songId): \(error.localizedDescription)")
                        } else if let songDTO = songDTO {
                            if let song = Song(from: songDTO, id: songId) { // Safe conversion
                                fetchedSongs.append(song)
                            } else {
                                print("Failed to convert songDTO to Song for ID \(songId).")
                            }
                        } else {
                            print("No songDTO found for ID \(songId).")
                        }
                        group.leave()
                    }
                }

                
                group.notify(queue: .main) {
                    // Convert songs to cards
                    let songCards = fetchedSongs.map { createCard(from: $0) }
                    self.cards = songCards // Assign to a @State property in your View
                    self.isLoading = false
                }
            }
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    if isLoading {
                        ProgressView("Loading songs...")
                    } else if songs.isEmpty && cards.isEmpty {
                        Text("No songs found.")
                    } else {
                        CardList(results: self.cards)
                    }
                    Text("song count: \(songs.count)")
                    Text("card count: \(cards.count)")
                }
            }
            .navigationTitle("Your ListenList")
            .onAppear {
                fetchSongList()
            }
        }
    }
}
