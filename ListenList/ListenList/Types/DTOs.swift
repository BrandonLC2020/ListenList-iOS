//
//  DTOs.swift
//  ListenList
//
//  Created by Brandon Lamer-Connolly on 1/3/25.
//

import Foundation
import FirebaseFirestore

struct ArtistDTO: Codable {
    let id: String
    let name: String
    var images: [DocumentReference]?
    var popularity: Int?
    
    static func toArtist(from ref: DocumentReference, completion: @escaping (Artist?) -> Void) {
        // Fetch the artist data asynchronously from Firestore
        ref.getDocument { (document, error) in
            if let error = error {
                print("Error getting artist document: \(error)")
                completion(nil)
                return
            }
            
            guard let document = document, document.exists else {
                print("Artist document does not exist")
                completion(nil)
                return
            }
            
            // Use document data to create the Artist object
            let data = document.data()
            let id = ref.documentID
            let name = data?["name"] as? String ?? ""
            let popularity = data?["popularity"] as? Int ?? 0
            
            // Assuming the images are stored in an array of dictionaries
            let imagesData = data?["images"] as? [[String: Any]] ?? []
            let images = imagesData.compactMap { imageDict -> ImageResponse? in
                return ImageDTO.toImageResponse(from: imageDict)
            }
            
            // Create and return the Artist object
            let artist = Artist(
                id: id,
                images: images,
                name: name,
                popularity: popularity,
                artistId: id // Assuming artistId is the same as the document id
            )
            
            // Return the created Artist object
            completion(artist)
        }
    }
}

struct AlbumDTO: Codable {
    let id: String
    let name: String
    let releaseDate: String
    var images: [DocumentReference] = []
    var artists: [DocumentReference] = []
    
    static func toAlbum(from ref: DocumentReference, completion: @escaping (Album?) -> Void) {
        ref.getDocument { (document, error) in
            if let error = error {
                print("Error getting document: \(error)")
                completion(nil)
                return
            }
            
            guard let document = document, document.exists else {
                print("Document does not exist")
                completion(nil)
                return
            }
            
            // Use the document ID directly
            let id = ref.documentID
            
            // Fetch album data
            let data = document.data()
            let name = data?["name"] as? String ?? ""
            let releaseDate = data?["release_date"] as? String ?? ""
            
            // Fetch images array (if it's an array of dictionaries that map to `ImageResponse`)
            let imagesData = data?["images"] as? [[String: Any]] ?? []
            let images = imagesData.compactMap { imageDict -> ImageResponse? in
                // Use the new helper to build an ImageResponse from a dictionary
                return ImageDTO.toImageResponse(from: imageDict)
            }
            
            let album = Album(
                id: id,
                images: images,
                name: name,
                release_date: releaseDate,
                artists: [] // Artists will be fetched asynchronously elsewhere if needed
            )
            
            completion(album)
        }
    }
}

struct SongDTO: Codable {
    let id: String
    let name: String
    let popularity: Int
    let durationMs: Int
    var isExplicit: Bool
    var album: DocumentReference?
    var artists: [DocumentReference] = []

    enum CodingKeys: String, CodingKey {
        case name, popularity, durationMs, isExplicit, album, artists, id
    }

    // Custom decoding to handle `isExplicit` as an integer or boolean
    init(from decoder: Decoder, documentId: String) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = documentId
        name = try container.decode(String.self, forKey: .name)
        popularity = try container.decode(Int.self, forKey: .popularity)
        durationMs = try container.decode(Int.self, forKey: .durationMs)
        
        // Decode `isExplicit` handling both Bool and Int
        if let explicit = try? container.decode(Bool.self, forKey: .isExplicit) {
            isExplicit = explicit
        } else if let explicitInt = try? container.decode(Int.self, forKey: .isExplicit) {
            isExplicit = explicitInt != 0
        } else {
            isExplicit = false
        }
        
        // Decode references
        album = try? container.decode(DocumentReference.self, forKey: .album)
        artists = (try? container.decode([DocumentReference].self, forKey: .artists)) ?? []
    }

    static func toSong(from dto: SongDTO, completion: @escaping (Song?) -> Void) {
        // Ensure album reference exists
        guard let albumRef = dto.album else {
            print("Album reference is missing")
            completion(nil)
            return
        }
        
        // Fetch the album asynchronously
        AlbumDTO.toAlbum(from: albumRef) { fetchedAlbum in
            guard let validAlbum = fetchedAlbum else {
                print("Failed to fetch album")
                completion(nil)
                return
            }
            
            // Now handle the artists asynchronously
            var artists: [Artist] = []
            let group = DispatchGroup() // To wait for all artists to be fetched
            
            for artistRef in dto.artists {
                group.enter()
                // Fetch each artist asynchronously using `toArtist`
                ArtistDTO.toArtist(from: artistRef) { artist in
                    if let artist = artist {
                        artists.append(artist)
                    }
                    group.leave()
                }
            }
            
            // Wait for all artists to be fetched before proceeding
            group.notify(queue: .main) {
                // Create the Song object once everything is ready
                let song = Song(
                    id: dto.id,
                    album: validAlbum,
                    artists: artists,
                    duration_ms: dto.durationMs,
                    name: dto.name,
                    popularity: dto.popularity,
                    explicit: dto.isExplicit
                )
                completion(song)
            }
        }
    }
}

struct ImageDTO: Codable {
    let height: Int
    let width: Int
    let url: String
    
    // Existing asynchronous version using a DocumentReference remains unchanged.
    static func toImageResponse(from ref: DocumentReference, completion: @escaping (ImageResponse?) -> Void) {
        // Fetch the image data asynchronously from Firestore
        ref.getDocument { (document, error) in
            if let error = error {
                print("Error getting image document: \(error)")
                completion(nil)
                return
            }
            
            guard let document = document, document.exists else {
                print("Image document does not exist")
                completion(nil)
                return
            }
            
            // Use document data to create the ImageResponse object
            let data = document.data()
            let url = data?["url"] as? String ?? ""
            let height = data?["height"] as? Int ?? 0
            let width = data?["width"] as? Int ?? 0
            
            let imageResponse = ImageResponse(url: url, height: height, width: width)
            completion(imageResponse)
        }
    }
    
    // New helper to create an ImageResponse from a dictionary (synchronous conversion)
    static func toImageResponse(from dict: [String: Any]) -> ImageResponse? {
        guard let url = dict["url"] as? String else { return nil }
        let height = dict["height"] as? Int
        let width = dict["width"] as? Int
        return ImageResponse(url: url, height: height, width: width)
    }
}
