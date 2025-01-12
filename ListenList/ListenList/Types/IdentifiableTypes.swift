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
    init?(from dto: SongDTO, id: String) {
        // Handling album resolution (since album is a DocumentReference in SongDTO)
        guard let albumRef = dto.album else {
            print("Missing album reference for song \(dto.name)")
            return nil
        }

        // Fetch the album document
        DatabaseManager.shared.fetchAlbum(from: albumRef) { album, error in
            guard let album = album, error == nil else {
                print("Error fetching album for song \(dto.name): \(error?.localizedDescription ?? "Unknown error")")
                return nil
            }

            // Convert albumDTO into the Album model
            let albumModel = Album(
                id: id,
                images: album.images.map { ImageResponse(url: $0.url, height: $0.height, width: $0.width) },
                name: album.name,
                release_date: album.releaseDate,
                artists: album.artists.map { Artist(from: $0) }
            )

            // Assign the resolved album
            self.id = id
            self.name = dto.name
            self.popularity = dto.popularity
            self.duration_ms = dto.durationMs
            self.explicit = dto.isExplicit
            self.album = albumModel

            // Convert artists
            self.artists = dto.artists.map { Artist(from: $0) }
        }
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
