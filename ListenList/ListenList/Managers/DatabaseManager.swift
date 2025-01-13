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
    
    func fetchAlbumIds(completion: @escaping ([DocumentSnapshot]?, Error?) -> Void) {
        db.collection("albums").getDocuments { snapshot, error in
            completion(snapshot?.documents, error)
        }
    }
    
    func fetchSong(withId songId: String, completion: @escaping (SongDTO?, Error?) -> Void) {
        let songRef = db.collection("songs").document(songId)

        songRef.getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                print("Error fetching song data: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil, error)
                return
            }

            // Log the raw data before decoding
            print("Raw song data for ID \(songId): \(data)")

            do {
                var song = try Firestore.Decoder().decode(SongDTO.self, from: data)

                // Fetch album if it's a reference
                if let albumRef = data["album"] as? DocumentReference {
                    self.fetchAlbum(from: albumRef) { album, error in
                        song.album = album // Set the resolved album

                        // Fetch artists if present in the song
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
                    // If there's no album reference, just return the song
                    completion(song, nil)
                }
            } catch let error as DecodingError {
                // Detailed logging of decoding errors
                switch error {
                case .typeMismatch(let type, let context):
                    print("Type mismatch error: \(type) at \(context.codingPath)")
                case .valueNotFound(let value, let context):
                    print("Value not found error: \(value) at \(context.codingPath)")
                case .keyNotFound(let key, let context):
                    print("Key not found error: \(key) at \(context.codingPath)")
                case .dataCorrupted(let context):
                    print("Data corrupted error: \(context)")
                default:
                    print("Unknown decoding error: \(error.localizedDescription)")
                }
                completion(nil, error)
            } catch {
                // Catch any other errors
                print("Unknown error: \(error.localizedDescription)")
                completion(nil, error)
            }
        }
    }

    func fetchAlbum(from albumRef: DocumentReference, completion: @escaping (AlbumDTO?, Error?) -> Void) {
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

    func fetchArtists(from artistRefs: [DocumentReference], completion: @escaping ([ArtistDTO], Error?) -> Void) {
        var artists: [ArtistDTO] = []
        let dispatchGroup = DispatchGroup()

        for ref in artistRefs {
            dispatchGroup.enter()
            ref.getDocument { snapshot, error in
                if let error = error {
                    print("Error fetching artist data for \(ref.path): \(error.localizedDescription)")
                } else if let data = snapshot?.data() {
                    do {
                        let artist = try Firestore.Decoder().decode(ArtistDTO.self, from: data)
                        artists.append(artist)
                    } catch {
                        print("Error decoding artist data for \(ref.path): \(error.localizedDescription)")
                    }
                } else {
                    print("Artist document is missing or empty for \(ref.path)")
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(artists, nil)
        }
    }

    private func fetchImages(from imageRefs: [DocumentReference], completion: @escaping ([ImageDTO], Error?) -> Void) {
        var images: [ImageDTO] = []
        let dispatchGroup = DispatchGroup()

        for ref in imageRefs {
            dispatchGroup.enter()
            ref.getDocument { snapshot, error in
                if let error = error {
                    print("Error fetching image data for \(ref.path): \(error.localizedDescription)")
                } else if let data = snapshot?.data() {
                    do {
                        let image = try Firestore.Decoder().decode(ImageDTO.self, from: data)
                        images.append(image)
                    } catch {
                        print("Error decoding image data for \(ref.path): \(error.localizedDescription)")
                    }
                } else {
                    print("Image document is missing or empty for \(ref.path)")
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(images, nil)
        }
    }
}

