//
//  ListenListView.swift
//  ListenList
//
//  Created by Brandon Lamer-Connolly on 10/11/24.
//

import SwiftUI
import FirebaseFirestore

struct ListenListView: View {
    
    var songs: [Song]
    
    func fetchList() {
        let songList: () = DatabaseManager.shared.fetchSongs { documents, error in
            if let error = error {
                print("Error fetching users: \(error.localizedDescription)")
            } else if let documents = documents {
                for document in documents {
                    let data = document.data()
                    print("User ID: \(document.documentID), Data: \(String(describing: data))")
                }
            }
        }
    }
    
    init() {
        self.songs = []
        fetchList()
    }

    
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

