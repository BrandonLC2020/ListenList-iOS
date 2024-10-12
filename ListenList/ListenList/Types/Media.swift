//
//  Media.swift
//  ListenList
//
//  Created by Brandon Lamer-Connolly on 10/12/24.
//

import Foundation

class Media {
    var input: MediaType
    
    init(input: MediaType) {
        self.input = input
    }
}

// Enum to represent different media types
enum MediaType {
    case song(Song)
    case artist(Artist)
    case album(Album)
}
