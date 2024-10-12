//
//  CardList.swift
//  ListenList
//
//  Created by Brandon Lamer-Connolly on 10/12/24.
//

import SwiftUI

struct CardList: View {
    
    var results : [Card]
    
    private let columns = [GridItem(.flexible())]
    
    var body: some View {
        LazyVGrid(columns: columns, alignment: .center, spacing: 10) {
            ForEach(results, id: \.id) { item in
                if case let .song(song) = item.type {
                    SongCard(input: item.input)
                }
            }
        }
    }
}

#Preview {
    CardList(results: [])
}
