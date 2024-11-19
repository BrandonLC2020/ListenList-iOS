import SwiftUI

struct SearchView: View {
    @State var searchManager: SpotifyAPIManager
    var accessToken: String
    var tokenType: String
    @State var cards = [Card]()
    @State var searchBy = 0
    @State var searchText: String = ""
    @State var isLoading = false
    @FocusState private var isTextFieldFocused: Bool // Focus management for TextField
    
    init(access: String, type: String) {
        self.accessToken = access
        self.tokenType = type
        self.searchManager = SpotifyAPIManager(access: access, token: type)
        self.cards = []
    }
    
    func reset() {
        self.cards = []
    }
    
    func performSearch() async {
        reset()
        isLoading = true
        defer { isLoading = false } // Ensure loading state resets

        switch searchBy {
        case 0: await searchAlbums()
        case 1: await searchArtists()
        default: await searchSongs()
        }
    }
    
    func searchAlbums() async {
        if let albumSearchResults = try? await searchManager.search(query: searchText, type: "album"),
           let albums = albumSearchResults.albums {
            DispatchQueue.main.async {
                self.cards = albums.items.map { album in
                    let artists = album.artists?.map { Artist(name: $0.name, artistId: $0.id) } ?? []
                    return Card(input: .album, media: Media(input: .album(Album(images: album.images, name: album.name, release_date: album.release_date, artists: artists))))
                }
            }
        }
    }
    
    func searchSongs() async {
        if let songSearchResults = try? await searchManager.search(query: searchText, type: "track"),
           let songs = songSearchResults.tracks {
            DispatchQueue.main.async {
                self.cards = songs.items.map { song in
                    let albumArtists = song.album.artists?.map { Artist(name: $0.name, artistId: $0.id) } ?? []
                    let songArtists = song.artists.map { Artist(name: $0.name, artistId: $0.id) }
                    return Card(input: .song, media: Media(input: .song(Song(album: Album(images: song.album.images, name: song.album.name, release_date: song.album.release_date, artists: albumArtists), artists: songArtists, duration_ms: song.duration_ms, name: song.name, popularity: song.popularity))))
                }
            }
        }
    }
    
    func searchArtists() async {
        if let artistSearchResults = try? await searchManager.search(query: searchText, type: "artist"),
           let artists = artistSearchResults.artists {
            DispatchQueue.main.async {
                self.cards = artists.items.map { artist in
                    return Card(input: .artist, media: Media(input: .artist(Artist(images: artist.images, name: artist.name, popularity: artist.popularity, artistId: artist.id))))
                }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView{
                VStack {
                    Picker(selection: $searchBy, label: Text("Search Filter")) {
                        Text("Album").tag(0)
                        Text("Artist").tag(1)
                        Text("Song").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    HStack {
                        TextField("Search...", text: $searchText)
                            .focused($isTextFieldFocused)
                            .onSubmit {
                                Task {
                                    await performSearch()
                                }
                            }
                            .padding(7)
                            .padding(.horizontal, 25)
                            .background(Color(.systemGray4))
                            .cornerRadius(8)
                            .padding(.horizontal, 10)
                        
                        if !searchText.isEmpty {
                            Button("Cancel") {
                                searchText = ""
                                reset()
                                isTextFieldFocused = false // Dismiss keyboard
                            }
                            .foregroundColor(.blue)
                            .padding(.trailing, 10)
                        }
                    }
                    
                    if isLoading {
                        ProgressView("Searching...").padding()
                    }
                    
                    CardList(results: cards)
                }
            }
            .navigationTitle("Search")
        }
    }
}
