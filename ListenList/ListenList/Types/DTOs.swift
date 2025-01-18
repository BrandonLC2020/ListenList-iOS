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
    var images: [ImageDTO]?
    var popularity: Int?
    
    static func toArtistLite(from dto: ArtistDTO) -> Artist {
        Artist(
            id: dto.id,
            images: nil,
            name: dto.name,
            popularity: nil,
            artistId: dto.id
        )
    }
    
    static func toArtist(from dto: ArtistDTO) -> Artist {
        Artist(
            id: dto.id,
            images: dto.images?.map { ImageDTO.toImageResponse(from: $0) },
            name: dto.name,
            popularity: dto.popularity,
            artistId: dto.id
        )
    }
}

struct AlbumDTO: Codable {
    let id: String
    let name: String
    let releaseDate: String
    var images: [ImageDTO] = []
    var artists: [ArtistDTO] = []
    
    static func toAlbum(from dto: AlbumDTO) -> Album {
        Album(
            id: dto.id,
            images: dto.images.map { ImageDTO.toImageResponse(from: $0) },
            name: dto.name,
            release_date: dto.releaseDate,
            artists: dto.artists.map { ArtistDTO.toArtistLite(from: $0) }
        )
    }
}

struct SongDTO: Codable {
    let id: String
    let name: String
    let popularity: Int
    let durationMs: Int
    var isExplicit: Bool
    var album: AlbumDTO? 
    var artists: [ArtistDTO] = [] // Resolved artists

    enum CodingKeys: String, CodingKey {
        case name, popularity, durationMs, isExplicit, album, artists, id
    }

    // Custom decoding to handle `isExplicit` as an integer or boolean
    init(from decoder: Decoder, songId: String) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = songId
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
        album = try! container.decode(AlbumDTO.self, forKey: .album)

        // Optional decoding for artists
        artists = (try? container.decode([ArtistDTO].self, forKey: .artists)) ?? []
    }
    
    static func toSong(from dto: SongDTO) -> Song? {
        Song(
            id: dto.id,
            album: AlbumDTO.toAlbum(from: dto.album!),
            artists: dto.artists.map { ArtistDTO.toArtistLite(from: $0) },
            duration_ms: dto.durationMs,
            name: dto.name,
            popularity: dto.popularity,
            explicit: dto.isExplicit
        )
    }
}

struct ImageDTO: Codable {
    let height: Int
    let width: Int
    let url: String
    
    static func toImageResponse(from: ImageDTO) -> ImageResponse {
        ImageResponse(url: from.url, height: from.height, width: from.width)
    }
}

