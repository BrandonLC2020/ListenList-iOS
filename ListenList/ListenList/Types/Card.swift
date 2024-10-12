//
//  Card.swift
//  ListenList
//
//  Created by Brandon Lamer-Connolly on 10/12/24.
//

import SwiftUI

import Foundation

class Card: Identifiable {
    var type: CardType
    var input: Media
    var id: UUID
    
    init(input: CardType, media: Media) {
        self.type = input
        self.input = media
        self.id = UUID()
    }
}

// Enum to represent different media types
enum CardType {
    case song
    case artist
    case album
}
