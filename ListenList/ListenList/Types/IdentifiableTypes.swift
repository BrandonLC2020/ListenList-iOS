//
//  IdentifiableTypes.swift
//  ListenList
//
//  Created by Brandon Lamer-Connolly on 10/11/24.
//

import Foundation    

struct Song: Identifiable, Hashable {
    var id: String
    var album: Album
    var artists: [Artist]
    var duration_ms: Int //in milliseconds
    var name: String
    var popularity: Int
    var explicit: Bool
}

struct Artist: Identifiable, Hashable {
    var id: String
    var images: [ImageResponse]?
    var name: String
    var popularity: Int?
    var artistId: String
}

struct Album: Identifiable, Hashable {
    var id: String
    var images: [ImageResponse]
    var name: String
    var release_date: String
    var artists: [Artist]
}

extension Song {
    init?(from dto: SongDTO?) {
        guard let dto = dto else { return nil } // Return nil if the DTO is nil
        self.id = UUID().uuidString // Generate a unique ID or map from Firestore if available
        self.album = Album(from: dto.album) ?? Album(
            id: UUID().uuidString,
            images: [],
            name: "Unknown Album",
            release_date: "Unknown Date",
            artists: []
        )
        self.artists = dto.artists.map { Artist(from: $0) }
        self.duration_ms = dto.durationMs
        self.name = dto.name
        self.popularity = dto.popularity
        self.explicit = dto.isExplicit
    }
}

extension Album {
    init?(from dto: AlbumDTO?) {
        guard let dto = dto else { return nil }
        self.id = UUID().uuidString // Generate or map the ID
        self.images = dto.images.map { ImageResponse(from: $0) }
        self.name = dto.name
        self.release_date = dto.releaseDate
        self.artists = dto.artists.map { Artist(from: $0) }
    }
}

extension Artist {
    init(from dto: ArtistDTO) {
        self.id = UUID().uuidString // Generate or map the ID
        self.images = nil // Add logic if `ArtistDTO` includes image data in the future
        self.name = dto.name
        self.popularity = nil // Add if `ArtistDTO` includes popularity data
        self.artistId = UUID().uuidString // Generate or map
    }
}
