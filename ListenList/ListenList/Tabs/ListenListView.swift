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
        var songIds = [String]()
        DatabaseManager.shared.fetchSongIds { documents, error in
            if let error = error {
                print("Error fetching users: \(error.localizedDescription)")
            } else if let documents = documents {
                for document in documents {
                    let id = document.documentID
                    print(id)
                    songIds.append(id as String)
                }
            }
        }
        for songId in songIds {
            print(songId)
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

