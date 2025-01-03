//
//  DTOs.swift
//  ListenList
//
//  Created by Brandon Lamer-Connolly on 1/3/25.
//

import Foundation

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
//    let id: String
    let name: String
    let popularity: Int
    let durationMs: Int
    let isExplicit: Bool
    var album: AlbumDTO? // Resolved album
    var artists: [ArtistDTO] = [] // Resolved artists
}

struct ImageDTO: Codable {
    let height: Int
    let width: Int
    let url: String
}

