//
//  AlbumCard.swift
//  ListenList
//
//  Created by Brandon Lamer-Connolly on 10/12/24.
//

import SwiftUI

struct AlbumCard: View {
    var id: UUID
    var input: Media
    var album: Album?
    
    let maxHeight: CGFloat = 120
    
    init(input: Media) {
        self.input = input
        if case let .album(album) = input.input {
            self.album = album
        }
        self.id = UUID()
    }
    
    func artistsToStr() -> String {
        var result : String = ""
        for artist in album!.artists {
            result += artist.name + ", "
        }
        let endIndex = result.index(result.endIndex, offsetBy: -2)
        let truncated = result[..<endIndex]
        return String(truncated)
    }
    
    var body: some View {
        ZStack {
            HStack(alignment: .center) {
                if album!.images.isEmpty {
                    Image(systemName: "music.quarternote.3")
                    .cornerRadius(15.0)
                    .blur(radius: 4.2)
                    .scaledToFill()
                    .frame(maxHeight: maxHeight)
                    .clipped()
                } else {
                    AsyncImage(url: URL(string: album!.images[0].url)) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .cornerRadius(15.0)
                    .blur(radius: 4.2)
                    .scaledToFill()
                    .frame(maxHeight: maxHeight)
                    .clipped()
                }
            }.cornerRadius(15.0)
            HStack {
                RoundedRectangle(cornerRadius: 15.0)
                    .foregroundColor(.gray.opacity(0.7))
                    .cornerRadius(15.0)
                    .scaledToFill()
                    .frame(maxHeight: maxHeight)
                    .clipped()
            }.cornerRadius(15.0)
            
            HStack(alignment: .center) {
                //album cover
                if album!.images.isEmpty {
                    Image(systemName: "music.quarternote.3")
                        .aspectRatio(1, contentMode: .fit)
                        .cornerRadius(15.0)
                        .frame(maxWidth: 90, maxHeight: 90)
                        .padding(.all)
                } else {
                    AsyncImage(url: URL(string: album!.images[0].url)) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }.aspectRatio(1, contentMode: .fit)
                        .cornerRadius(15.0)
                        .frame(maxWidth: 90, maxHeight: 90)
                        .padding(.all)
                }
                //song title and artist(s) name(s)
                VStack(alignment: .leading) {
                    Text(album!.name)
                        .bold()
                        .lineLimit(1)
                        .frame(maxWidth: 220, alignment: .leading)
                        .truncationMode(.tail)
                        
                    Text(artistsToStr())
                        .lineLimit(1)
                        .frame(maxWidth: 220, alignment: .leading)
                        .truncationMode(.tail)
                }
                .padding(.trailing)
                
                Spacer()
            }
            .scaledToFill()
            .clipped()
        }
        .frame(maxWidth: 600, maxHeight: maxHeight, alignment: .center)
        .clipped()
        .padding([.leading, .trailing], 10)
    }
}


#Preview {
    AlbumCard(input: Media(input: .album(Album(images: [ImageResponse(url: "https://i.scdn.co/image/ab67616d0000b273f76f8deeba5370c98ad38f1c", height: 640, width: 640)], name: "Chemical", release_date: "2023-04-14", artists: [Artist(name: "Post Malone", artistId: "246dkjvS1zLTtiykXe5h60")]))))
}
