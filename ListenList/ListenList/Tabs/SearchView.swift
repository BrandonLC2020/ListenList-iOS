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
                                        albumSearchResults = user.albums!
                                    }
                                    
                                })
                                
                                while (albumSearchResults.items.isEmpty) {}
                                sleep(2)
                                
                                for i in 0...albumSearchResults.items.endIndex-1 {
                                    var artist: [Artist] = []
                                    for art in albumSearchResults.items[i].artists! {
                                        artist.append(Artist(name: art.name, artistId: art.id))
                                    }
                                    self.cards.append(Card(input: .album, media: Media(input: .album(Album(images: albumSearchResults.items[i].images, name: albumSearchResults.items[i].name, release_date: albumSearchResults.items[i].release_date, artists: artist)))))
                                }
                                print(self.cards.count)
                            } else if (searchBy == 1) {
                                var artistSearchResults: ArtistSearchResponse = ArtistSearchResponse(href: "", limit: 0, offset: 0, total: 0, items: [])
                                self.searchManager.searchArtists(query: searchOutput, type: "artist", userCompletionHandler: { user in
                                    if let user = user {
                                        artistSearchResults = user.artists!
                                    }
                                    
                                })
                                
                                while (artistSearchResults.items.isEmpty) {}
                                sleep(2)
                                
                                for i in 0...artistSearchResults.items.endIndex-1 {
                                    self.cards.append(Card(input: .artist, media: Media(input: .artist(Artist(images: artistSearchResults.items[i].images, name: artistSearchResults.items[i].name, popularity: artistSearchResults.items[i].popularity, artistId: artistSearchResults.items[i].id)))))
                                }
                                print(self.cards.count)

                            } else {
                                var songSearchResults: SongSearchResponse = SongSearchResponse(href: "", limit: 0, offset: 0, total: 0, items: [])
                                self.searchManager.searchSongs(query: searchOutput, type: "track", userCompletionHandler: { user in
                                    if let user = user {
                                        songSearchResults = user.tracks!
                                    }
                                    
                                })
                                
                                while (songSearchResults.items.isEmpty) {}
                                sleep(2)
                                
                                for i in 0...songSearchResults.items.endIndex-1 {
                                    var albumArtist: [Artist] = []
                                    for art in songSearchResults.items[i].album.artists! {
                                        albumArtist.append(Artist(name: art.name, artistId: art.id))
                                    }
                                    var songArtist: [Artist] = []
                                    for art in songSearchResults.items[i].artists {
                                        songArtist.append(Artist(name: art.name, artistId: art.id))
                                    }
                                    self.cards.append(Card(input: .song, media: Media(input: .song(Song(album: Album(images: songSearchResults.items[i].album.images, name: songSearchResults.items[i].album.name, release_date: songSearchResults.items[i].album.release_date, artists: albumArtist), artists: songArtist, duration_ms: songSearchResults.items[i].popularity, name:songSearchResults.items[i].name, popularity: songSearchResults.items[i].duration_ms)))))
                                }
                                print(self.cards.count)
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
