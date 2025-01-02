import SwiftUI

struct SearchView: View {
    var searchManager: SpotifyAPIManager
    var accessToken: String
    var tokenType: String
    @State private var cards = [Card]()
    @State private var searchBy = 0
    @State private var searchText: String = ""
    @State private var isLoading = false
    @FocusState private var isTextFieldFocused: Bool // Focus management for TextField
    
    init(access: String, type: String) {
        self.accessToken = access
        self.tokenType = type
        self.searchManager = SpotifyAPIManager(access: access, token: type)
        self.cards = []
    }
    
    @MainActor
    func performSearch() async -> [Card] {
        self.isLoading = true
        defer { self.isLoading = false }

        switch self.searchBy {
            case 0: return await searchAlbums()
            case 1: return await searchArtists()
            default: return await searchSongs()
        }
    }

    func searchAlbums() async -> [Card] {
        do {
            if let albumSearchResults = try await searchManager.search(query: searchText, type: "album"),
               let albums = albumSearchResults.albums {
                return albums.items.map { album in
                    let artists = album.artists?.map { Artist(name: $0.name, artistId: $0.id) } ?? []
                    return Card(input: .album, media: Media(input: .album(Album(images: album.images, name: album.name, release_date: album.release_date, artists: artists))), id: album.id)
                }
            }
        } catch {
            print("Error during album search: \(error)")
        }
        return []
    }

    func searchSongs() async -> [Card] {
        do {
            if let songSearchResults = try await searchManager.search(query: searchText, type: "track"),
               let songs = songSearchResults.tracks {
                
                return songs.items.map { song in
                    let albumArtists = song.album.artists?.map { Artist(name: $0.name, artistId: $0.id) } ?? []
                    let songArtists = song.artists.map { Artist(name: $0.name, artistId: $0.id) }
                    return Card(input: .song, media: Media(input: .song(Song(album: Album(images: song.album.images, name: song.album.name, release_date: song.album.release_date, artists: albumArtists), artists: songArtists, duration_ms: song.duration_ms, name: song.name, popularity: song.popularity, explicit: song.explicit))), id: song.id)
                    
                }
            }
        } catch {
            print("Error during song search: \(error)")
        }
        return []
    }
    
    func searchArtists() async -> [Card] {
        do {
            if let artistSearchResults = try await searchManager.search(query: searchText, type: "artist"),
               let artists = artistSearchResults.artists {
                    
                    return artists.items.map { artist in
                        return Card(input: .artist, media: Media(input: .artist(Artist(images: artist.images, name: artist.name, popularity: artist.popularity, artistId: artist.id))), id: artist.id)
                    
                }
            }
        } catch {
            print("Error during song search: \(error)")
        }
        return []
    }
    
    @MainActor
    func startSearch() async {
        guard !self.searchText.isEmpty else { return }

        self.isLoading = true
        self.cards = [] // Clear previous results
        self.isTextFieldFocused = false // Dismiss keyboard

        // Perform search and handle results
        let results: [Card] = await performSearch()
        
        self.cards = results // Update results

        self.isLoading = false // Stop loading
        print("done searching!")
    }


    func resetSearch() {
        // Reset all states explicitly
        searchText = ""
        cards = []
        isLoading = false
        isTextFieldFocused = false // Clear keyboard focus
    }



    var body: some View {
        NavigationView {
            ScrollView {
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
                            .onChange(of: searchText) {
                                print("Search text changed to: \(searchText)")
                            }
                            .onSubmit {
                                Task { await startSearch() }
                            }
                            .padding(7)
                            .padding(.horizontal, 25)
                            .background(Color(.systemGray4))
                            .cornerRadius(8)
                            .padding(.horizontal, 10)
                        
                        if !searchText.isEmpty {
                            Button("Cancel") {
                                resetSearch()
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
            .onTapGesture { isTextFieldFocused = false }
            .navigationTitle("Search")
        }
    }



}
