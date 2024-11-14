//
//  ArtistCard.swift
//  ListenList
//
//  Created by Brandon Lamer-Connolly on 10/12/24.
//

import SwiftUI

struct ArtistCard: View {
    var id: UUID
    var input: Media
    var artist: Artist?
    
    let maxHeight: CGFloat = 120
    
    init(input: Media) {
        self.input = input
        if case let .artist(artist) = input.input {
            self.artist = artist
        }
        self.id = UUID()
    }
    
    var body: some View {
        ZStack {
            HStack(alignment: .center) {
                AsyncImage(url: URL(string: artist!.images![0].url)) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .cornerRadius(15.0)
                .blur(radius: 4.2)
                .scaledToFill()
                .frame(maxHeight: maxHeight)
                .clipped()
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
                AsyncImage(url: URL(string: artist!.images![0].url)) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }.aspectRatio(1, contentMode: .fit)
                    .cornerRadius(15.0)
                    .frame(maxWidth: 90, maxHeight: 90)
                    .padding(.all)
                //song title and artist(s) name(s)
                VStack(alignment: .leading) {
                    Text(artist!.name)
                        .bold()
                        .lineLimit(2)
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
    ArtistCard(input: Media(input: .artist(Artist(images: [ImageResponse(url: "https://i.scdn.co/image/ab6761610000e5eb19c2790744c792d05570bb71",        height: 640, width: 640)], name: "Travis Scott", artistId: "246dkjvS1zLTtiykXe5h60"))))
}
