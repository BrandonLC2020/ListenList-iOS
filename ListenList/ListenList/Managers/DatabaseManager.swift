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

        songRef.getDocument { [self] snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                print("Error fetching song data for ID \(songId): \(error?.localizedDescription ?? "Unknown error")")
                completion(nil, error)
                return
            }

            // Log raw data for debugging
            print("Raw song data for ID \(songId): \(data)")

            do {
                // Decode base SongDTO
                var songDTO = try Firestore.Decoder().decode(SongDTO.self, from: data)

                // Fetch album if it's a reference
                if let albumRef = data["album"] as? DocumentReference {
                    fetchAlbum(from: albumRef) { [self] albumDTO, albumError in
                        if let albumDTO = albumDTO {
                            // Manage album reference separately
                            print("Fetched album: \(albumDTO)")
                        }

                        // Fetch artists if present
                        if let artistRefs = data["artists"] as? [DocumentReference] {
                            fetchArtists(from: artistRefs) { artistDTOs, artistError in
                                if let artistDTOs = artistDTOs {
                                    print("Fetched artists: \(artistDTOs)")
                                }
                                completion(songDTO, nil) // Return the complete SongDTO
                            }
                        } else {
                            completion(songDTO, nil) // Return if no artists
                        }
                    }
                } else {
                    // No album reference, check for artists
                    if let artistRefs = data["artists"] as? [DocumentReference] {
                        fetchArtists(from: artistRefs) { artistDTOs, artistError in
                            if let artistDTOs = artistDTOs {
                                print("Fetched artists: \(artistDTOs)")
                            }
                            completion(songDTO, nil) // Return the complete SongDTO
                        }
                    } else {
                        completion(songDTO, nil) // Return if no album or artists
                    }
                }
            } catch let error as DecodingError {
                // Handle detailed decoding errors
                print("Decoding error for song ID \(songId): \(error.localizedDescription)")
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
                // Handle unexpected errors
                print("Unexpected error for song ID \(songId): \(error.localizedDescription)")
                completion(nil, error)
            }
        }
    }

    func fetchAlbum(from ref: DocumentReference, completion: @escaping (AlbumDTO?, Error?) -> Void) {
        ref.getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                print("Error fetching album: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil, error)
                return
            }
            
            do {
                let albumDTO = try Firestore.Decoder().decode(AlbumDTO.self, from: data)
                completion(albumDTO, nil)
            } catch {
                print("Error decoding album: \(error.localizedDescription)")
                completion(nil, error)
            }
        }
    }

    func fetchArtists(from refs: [DocumentReference], completion: @escaping ([ArtistDTO]?, Error?) -> Void) {
        var artists: [ArtistDTO] = []
        let group = DispatchGroup()
        
        for ref in refs {
            group.enter()
            ref.getDocument { snapshot, error in
                if let data = snapshot?.data(), error == nil {
                    if let artistDTO = try? Firestore.Decoder().decode(ArtistDTO.self, from: data) {
                        artists.append(artistDTO)
                    } else {
                        print("Error decoding artist data from \(ref.path)")
                    }
                } else {
                    print("Error fetching artist: \(error?.localizedDescription ?? "Unknown error")")
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
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

