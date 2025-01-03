//
//  DatabaseManager.swift
//  ListenList
//
//  Created by Brandon Lamer-Connolly on 10/12/24.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

class DatabaseManager {
    static let shared = DatabaseManager()
    let db = Firestore.firestore() // Singleton instance

    private init() {} // Prevent external initialization

    func addUser(name: String, age: Int, completion: @escaping (Error?) -> Void) {
        let userData: [String: Any] = ["name": name, "age": age]
        db.collection("users").addDocument(data: userData, completion: completion)
    }

    func fetchUsers(completion: @escaping ([DocumentSnapshot]?, Error?) -> Void) {
        db.collection("users").getDocuments { snapshot, error in
            completion(snapshot?.documents, error)
        }
    }

    func fetchSongIds(completion: @escaping ([DocumentSnapshot]?, Error?) -> Void) {
        db.collection("songs").getDocuments { snapshot, error in
            completion(snapshot?.documents, error)
        }
    }
    
    func fetchSong(withId songId: String, completion: @escaping (SongDTO?, Error?) -> Void) {
            let songRef = db.collection("songs").document(songId)

            songRef.getDocument { snapshot, error in
                guard let data = snapshot?.data(), error == nil else {
                    completion(nil, error)
                    return
                }

                do {
                    var song = try Firestore.Decoder().decode(SongDTO.self, from: data)

                    // Resolve album and artists
                    if let albumRef = data["album"] as? DocumentReference {
                        self.fetchAlbum(from: albumRef) { album, error in
                            song.album = album
                            
                            if let artistRefs = data["artists"] as? [DocumentReference] {
                                self.fetchArtists(from: artistRefs) { artists, error in
                                    song.artists = artists
                                    completion(song, nil)
                                }
                            } else {
                                completion(song, nil)
                            }
                        }
                    } else {
                        completion(song, nil)
                    }
                } catch {
                    completion(nil, error)
                }
            }
        }

        private func fetchAlbum(from albumRef: DocumentReference, completion: @escaping (AlbumDTO?, Error?) -> Void) {
            albumRef.getDocument { snapshot, error in
                guard let data = snapshot?.data(), error == nil else {
                    completion(nil, error)
                    return
                }

                do {
                    let album = try Firestore.Decoder().decode(AlbumDTO.self, from: data)
                    completion(album, nil)
                } catch {
                    completion(nil, error)
                }
            }
        }

        private func fetchArtists(from artistRefs: [DocumentReference], completion: @escaping ([ArtistDTO], Error?) -> Void) {
            var artists: [ArtistDTO] = []
            let dispatchGroup = DispatchGroup()

            for ref in artistRefs {
                dispatchGroup.enter()
                ref.getDocument { snapshot, error in
                    if let data = snapshot?.data(), error == nil {
                        if let artist = try? Firestore.Decoder().decode(ArtistDTO.self, from: data) {
                            artists.append(artist)
                        }
                    }
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .main) {
                completion(artists, nil)
            }
        }

}

