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
    var duration_ms: Int
    var name: String
    var popularity: Int
    var explicit: Bool

    static func create(from dto: SongDTO, id: String, album: Album, completion: @escaping (Song) -> Void) {
        let song = Song(
            id: id,
            album: album,
            artists: dto.artists.map { ArtistDTO.toArtist(from: $0) },
            duration_ms: dto.durationMs,
            name: dto.name,
            popularity: dto.popularity,
            explicit: dto.isExplicit
        )
        completion(song)
    }
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
