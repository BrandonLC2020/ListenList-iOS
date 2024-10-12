//
//  SearchView.swift
//  ListenList
//
//  Created by Brandon Lamer-Connolly on 10/11/24.
//

import SwiftUI

struct SearchView: View {
    var body: some View {
        NavigationView {
            ScrollView() {
                VStack{
                    HStack{
                        // search bar
                        // type filter
                    }
                    CardList(results: [])
                }
                
                
            }.navigationTitle("Search")
        }
    }
}

#Preview {
    SearchView()
}
