//
//  ListenListView.swift
//  ListenList
//
//  Created by Brandon Lamer-Connolly on 10/11/24.
//

import SwiftUI

struct ListenListView: View {
    var body: some View {
        NavigationView() {
            ScrollView {
                VStack {
                    CardList(results: [])
                }
            }.navigationTitle("Your ListenList")
        }
    }
}

#Preview {
    ListenListView()
}
