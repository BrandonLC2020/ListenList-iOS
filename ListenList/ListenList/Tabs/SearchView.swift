//
//  SearchView.swift
//  ListenList
//
//  Created by Brandon Lamer-Connolly on 10/11/24.
//

import SwiftUI

struct SearchView: View {
    var searchManager : SpotifyAPIManager
    var accessToken : String
    var tokenType : String
    var cards : [Card]
    
    init(access: String, type: String) {
        self.accessToken = access
        self.tokenType = type
        self.searchManager = SpotifyAPIManager(access: access, token: type)
        self.cards = []
    }
    
    var body: some View {
        NavigationView {
            ScrollView() {
                VStack{
                    HStack{
                        // search bar
                        // type filter
                    }
                    CardList(results: cards)
                }
                
                
            }.navigationTitle("Search")
        }
    }
}

//#Preview {
//    SearchView()
//}
