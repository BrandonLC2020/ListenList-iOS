//
//  IdentifiableTypes.swift
//  ListenList
//
//  Created by Brandon Lamer-Connolly on 10/11/24.
//

import Foundation    

struct Song: Identifiable, Hashable {
    let id = UUID()
    var album: Album
    var artists: [Artist]
    var duration_ms: Int //in milliseconds
    var name: String
    var popularity: Int
    var explicit: Bool
}

struct Artist: Identifiable, Hashable {
    let id = UUID()
    var images: [ImageResponse]?
    var name: String
    var popularity: Int?
    var artistId: String
}

struct Album: Identifiable, Hashable {
    let id = UUID()
    var images: [ImageResponse]
    var name: String
    var release_date: String
    var artists: [Artist]
}
