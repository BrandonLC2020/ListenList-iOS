//
//  SongCard.swift
//  ListenList
//
//  Created by Brandon Lamer-Connolly on 10/12/24.
//

import SwiftUI

struct SongCard: View {
    var input: Media
    var song: Song?

    init(input: Media) {
        self.input = input
        if case let .song(song) = input.input {
            self.song = song
        }
    }

    let maxHeight: CGFloat = 120

    private func artistsToStr() -> String {
        guard let artists = song?.artists, !artists.isEmpty else { return "Unknown Artist" }
        return artists.map { $0.name }.joined(separator: ", ")
    }

    private var placeholderImage: some View {
        Image(systemName: "photo")
            .resizable()
            .scaledToFit()
            .cornerRadius(15.0)
            .frame(maxWidth: 90, maxHeight: 90)
            .padding(.all)
    }

    var body: some View {
        guard let song = song else {
            return AnyView(EmptyView())
        }
        
        return AnyView(
            ZStack {
                HStack(alignment: .center) {
                    if song.album.images == nil || song.album.images.isEmpty {
                        placeholderImage
                            .blur(radius: 4.2)
                            .frame(maxHeight: maxHeight)
                    } else {
                        AsyncImage(url: URL(string: song.album.images[0].url)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image.resizable()
                                    .cornerRadius(15.0)
                            case .failure:
                                placeholderImage
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .blur(radius: 4.2)
                        .frame(maxHeight: maxHeight)
                    }
                }
                .cornerRadius(15.0)
                
                HStack {
                    RoundedRectangle(cornerRadius: 15.0)
                        .foregroundColor(.gray.opacity(0.7))
                        .frame(maxHeight: maxHeight)
                }
                .cornerRadius(15.0)
                
                HStack(alignment: .center) {
                    if song.album.images == nil || song.album.images.isEmpty {
                        placeholderImage
                    } else {
                        AsyncImage(url: URL(string: song.album.images[0].url)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image.resizable()
                                    .cornerRadius(15.0)
                            case .failure:
                                placeholderImage
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .cornerRadius(15.0)
                        .frame(maxWidth: 90, maxHeight: 90)
                        .padding(.all)
                    }
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text(song.name)
                                .bold()
                                .lineLimit(1)
                                .frame(maxWidth: 220, alignment: .leading)
                                .truncationMode(.tail)
                            if song.explicit {
                                Image(systemName: "e.square.fill")
                            }
                        }
                        Text(artistsToStr())
                            .lineLimit(1)
                            .frame(maxWidth: 220, alignment: .leading)
                            .truncationMode(.tail)
                    }
                    .padding(.trailing)
                    
                    Spacer()
                }
            }
            .frame(maxWidth: 600, maxHeight: maxHeight)
            .padding([.leading, .trailing], 10)
        )
    }

}

#Preview {
    let mockSong = Song(
        album: Album(
            images: [ImageResponse(url: "https://i.scdn.co/image/ab67616d0000b273f76f8deeba5370c98ad38f1c", height: 640, width: 640)],
            name: "Chemical",
            release_date: "2023-04-14",
            artists: [Artist(name: "Post Malone", artistId: "246dkjvS1zLTtiykXe5h60")]
        ),
        artists: [Artist(name: "Post Malone", artistId: "246dkjvS1zLTtiykXe5h60")],
        duration_ms: 184013,
        name: "Chemical",
        popularity: 88,
        explicit: true
    )
    return SongCard(input: Media(input: .song(mockSong)))
}
