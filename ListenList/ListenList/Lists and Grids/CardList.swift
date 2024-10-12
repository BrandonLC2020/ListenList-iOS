//
//  CardList.swift
//  ListenList
//
//  Created by Brandon Lamer-Connolly on 10/12/24.
//

import SwiftUI

struct CardList: View {
    
    var results
    
    private let columns = [GridItem()]
    
    var body: some View {
        LazyVGrid(columns: columns, alignment: .center, spacing: 10) {
            
        }
}

#Preview {
    CardList()
}
