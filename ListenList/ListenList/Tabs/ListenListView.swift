//
//  ListenListView.swift
//  ListenList
//
//  Created by Brandon Lamer-Connolly on 10/11/24.
//

import SwiftUI
import FirebaseFirestore

struct ListenListView: View {
    
    var songs: [Song]
    
    func fetchSongList() {
        var songIds = [String]()
        DatabaseManager.shared.fetchSongIds { documents, error in
            if let error = error {
                print("Error fetching songs: \(error.localizedDescription)")
            } else if let documents = documents {
                for document in documents {
                    let id = document.documentID
                    songIds.append(id as String)
                }
                print(songIds)
                for songId in songIds {
                    DatabaseManager.shared.fetchSong(withId: songId) { song, error in
                        if let error = error {
                            print("Error fetching song: \(error.localizedDescription)")
                        } else if let song = song {
                            print("Song Name: \(song.name)")
                            print("Popularity: \(song.popularity)")
                            print("Album Name: \(song.album?.name ?? "Unknown")")
                            print("Artists:")
                            for artist in song.artists {
                                print(" - \(artist.name)")
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    func fetchAlbumList() {
        var albumIds = [String]()
        DatabaseManager.shared.fetchAlbumIds { documents, error in
            if let error = error {
                print("Error fetching albums: \(error.localizedDescription)")
            } else if let documents = documents {
                for document in documents {
                    let id = document.documentID
                    print("id: \(id)")
                    print(document.data() as Any)
                }
            }
        }
        
    }

    
    init() {
        self.songs = []
        fetchAlbumList()
    }

    
    var body: some View {
        NavigationView() {
            ScrollView {
                VStack {
                    CardList(results: [])
                }
            }.navigationTitle("Your ListenList")
        }
    }
}

