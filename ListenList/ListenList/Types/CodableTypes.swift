//
//  CodableTypes.swift
//  ListenList
//
//  Created by Brandon Lamer-Connolly on 10/11/24.
//
    

struct SongResponse: Codable, Hashable {
    var album: AlbumResponse
    var artists: [ArtistResponse]
    var duration_ms: Int //in milliseconds
    var name: String
    var popularity: Int
}

struct ArtistResponse: Codable, Hashable {
    var images: [ImageResponse]?
    var name: String
    var popularity: Int?
    var id: String
}

struct AlbumResponse: Codable, Hashable {
    var images: [ImageResponse]
    var name: String
    var release_date: String
    var artists: [ArtistResponse]
}

struct ImageResponse: Codable, Hashable {
    var url: String
    var height: Int?
    var width: Int?
}
