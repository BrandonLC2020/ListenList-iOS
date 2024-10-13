//
//  SearchView.swift
//  ListenList
//
//  Created by Brandon Lamer-Connolly on 10/11/24.
//

import SwiftUI

struct SearchView: View {
    @State var searchManager : SpotifyAPIManager
    var accessToken : String
    var tokenType : String
    @State var cards : [Card]
    @State var searchBy = 0
    @State var searchInput: String = ""
    @State var searchOutput: String = ""
    @State var isEditing = false
    
    init(access: String, type: String) {
        self.accessToken = access
        self.tokenType = type
        self.searchManager = SpotifyAPIManager(access: access, token: type)
        self.cards = []
    }
    
    func reset() {
        self.cards = []
        self.searchManager = SpotifyAPIManager(access: self.accessToken, token: self.tokenType)

    }
    
    var body: some View {
        NavigationView {
            ScrollView() {
                VStack{
                    Picker(selection: $searchBy, label: Text("SearchFilter")) {
                        Text("Album").tag(0)
                        Text("Artist").tag(1)
                        Text("Song").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.all, 10)
                    HStack{
                        // search bar
                        TextField("Search...", text: $searchInput, onEditingChanged: { (edit) in
                            self.isEditing = true
                        }, onCommit: {
                            reset()
                            self.searchOutput = self.searchInput
                            if (searchBy == 0) {
                                var albumSearchResults: AlbumSearchResponse = AlbumSearchResponse(href: "", limit: 0, offset: 0, total: 0, items: [])
                                self.searchManager.searchAlbums(query: searchOutput, type: "album", userCompletionHandler: { user in
                                    if let user = user {
                                        albumSearchResults = user
                                    }
                                    
                                })
                                
                                while (albumSearchResults.items.isEmpty) {}
                                sleep(2)
                                
                                for i in 0...albumSearchResults.items.endIndex-1 {
                                    var artist: [Artist] = []
                                    for art in albumSearchResults.items[i].artists {
                                        artist.append(Artist(name: art.name, artistId: art.id))
                                    }
                                    self.cards.append(Card(input: .album, media: Media(input: .album(Album(images: albumSearchResults.items[i].images, name: albumSearchResults.items[i].name, release_date: albumSearchResults.items[i].release_date, artists: artist)))))
                                }
                                print(self.cards.count)
                            } else if (searchBy == 1) {

                            } else {

                            }
                        })
                        .padding(7)
                        .padding(.horizontal, 25)
                        .background(Color(.systemGray4))
                        .cornerRadius(8)
                        .padding(.horizontal, 10)
                        .onTapGesture {
                            self.isEditing = true
                        }
                        if searchInput.count != 0 {
                            Button(action: {
                                self.isEditing = false
                                self.searchInput = ""
                                self.searchOutput = ""
                                reset()
                                
                            }) {
                                Text("Cancel")
                            }
                            .padding(.trailing, 10)
                            .transition(.move(edge: .trailing))
                        }
                    }
                    CardList(results: self.cards)
                }
                
                
            }.navigationTitle("Search")
        }
    }
}

//#Preview {
//    SearchView()
//}
