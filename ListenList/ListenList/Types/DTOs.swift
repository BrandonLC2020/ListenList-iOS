//
//  DTOs.swift
//  ListenList
//
//  Created by Brandon Lamer-Connolly on 1/3/25.
//

import Foundation
import FirebaseFirestore

struct ArtistDTO: Codable {
//    let id: String
    let name: String
}

struct AlbumDTO: Codable {
//    let id: String
    let name: String
    let releaseDate: String
    var images: [ImageDTO] = []
    var artists: [ArtistDTO] = []
}

struct SongDTO: Codable {
    let name: String
    let popularity: Int
    let durationMs: Int
    var isExplicit: Bool
    var album: DocumentReference // Change to DocumentReference
    var artists: [ArtistDTO] = [] // Resolved artists

    enum CodingKeys: String, CodingKey {
        case name, popularity, durationMs, isExplicit, album, artists
    }

    // Custom decoding to handle `isExplicit` as an integer or boolean
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        popularity = try container.decode(Int.self, forKey: .popularity)
        durationMs = try container.decode(Int.self, forKey: .durationMs)
        
        // Decode `isExplicit` as Bool or Int
        if let explicit = try? container.decode(Bool.self, forKey: .isExplicit) {
            isExplicit = explicit
        } else if let explicitInt = try? container.decode(Int.self, forKey: .isExplicit) {
            isExplicit = (explicitInt != 0)
        } else {
            throw DecodingError.dataCorruptedError(forKey: .isExplicit, in: container, debugDescription: "Invalid format for isExplicit")
        }

        // Decode `album` as a DocumentReference
        album = try! container.decode(DocumentReference.self, forKey: .album)

        // Optional decoding for artists
        artists = (try? container.decode([ArtistDTO].self, forKey: .artists)) ?? []
    }
}

struct ImageDTO: Codable {
    let height: Int
    let width: Int
    let url: String
}

