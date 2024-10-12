//
//  CardList.swift
//  ListenList
//
//  Created by Brandon Lamer-Connolly on 10/12/24.
//

import SwiftUI

struct CardList: View {
    
    var results : [Card]
    
    private let columns = [GridItem(.flexible())]
    
    var body: some View {
        LazyVGrid(columns: columns, alignment: .center, spacing: 10) {
            ForEach(results, id: \.id) { item in
                if case .song = item.type {
                    SongCard(input: item.input)
                } else if case .album = item.type {
                    AlbumCard(input: item.input)
                } else if case .artist = item.type {
                    ArtistCard(input: item.input)
                }
            }
        }
    }
}

#Preview {
    CardList(results: [Card(input: .song, media: Media(input: .song(Song( album: Album(images: [ImageResponse(url: "https://i.scdn.co/image/ab67616d0000b273f76f8deeba5370c98ad38f1c", height: 640, width: 640)], name: "Chemical", release_date: "2023-04-14", artists: [Artist(name: "Post Malone", artistId: "246dkjvS1zLTtiykXe5h60")]), artists: [Artist(name: "Post Malone", artistId: "246dkjvS1zLTtiykXe5h60")], duration_ms: 184013, name: "Chemical", popularity: 88)))), Card(input: .song, media: Media(input: .song(Song( album: Album(images: [ImageResponse(url: "https://i.scdn.co/image/ab67616d0000b273f76f8deeba5370c98ad38f1c", height: 640, width: 640)], name: "Chemical", release_date: "2023-04-14", artists: [Artist(name: "Post Malone", artistId: "246dkjvS1zLTtiykXe5h60")]), artists: [Artist(name: "Post Malone", artistId: "246dkjvS1zLTtiykXe5h60")], duration_ms: 184013, name: "Chemical", popularity: 88)))), Card(input: .song, media: Media(input: .song(Song( album: Album(images: [ImageResponse(url: "https://i.scdn.co/image/ab67616d0000b273f76f8deeba5370c98ad38f1c", height: 640, width: 640)], name: "Chemical", release_date: "2023-04-14", artists: [Artist(name: "Post Malone", artistId: "246dkjvS1zLTtiykXe5h60")]), artists: [Artist(name: "Post Malone", artistId: "246dkjvS1zLTtiykXe5h60")], duration_ms: 184013, name: "Chemical", popularity: 88)))), Card(input: .song, media: Media(input: .song(Song( album: Album(images: [ImageResponse(url: "https://i.scdn.co/image/ab67616d0000b273f76f8deeba5370c98ad38f1c", height: 640, width: 640)], name: "Chemical", release_date: "2023-04-14", artists: [Artist(name: "Post Malone", artistId: "246dkjvS1zLTtiykXe5h60")]), artists: [Artist(name: "Post Malone", artistId: "246dkjvS1zLTtiykXe5h60")], duration_ms: 184013, name: "Chemical", popularity: 88)))), Card(input: .song, media: Media(input: .song(Song(album: Album(images: [ImageResponse(url: "https://i.scdn.co/image/ab67616d0000b273f76f8deeba5370c98ad38f1c", height: 640, width: 640)], name: "Chemical", release_date: "2023-04-14", artists: [Artist(name: "Post Malone", artistId: "246dkjvS1zLTtiykXe5h60")]), artists: [Artist(name: "Post Malone", artistId: "246dkjvS1zLTtiykXe5h60")], duration_ms: 184013, name: "Chemical", popularity: 88))))])
}
