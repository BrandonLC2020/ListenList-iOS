import SwiftUI

struct SongCard: View {
    var input: Media
    var song: Song? {
        if case let .song(song) = input.input {
            return song
        }
        return nil
    }
    
    let maxHeight: CGFloat = 120
    
    private func artistsToStr() -> String {
        var result: String = ""
        if let artists = song?.artists {
            result = artists.map { $0.name }.joined(separator: ", ")
        }
        return result.isEmpty ? "Unknown Artist" : result
    }
    
    var body: some View {
        guard let song = song else {
            return AnyView(EmptyView())
        }
        
        return AnyView(
            ZStack {
                HStack(alignment: .center) {
                    if song.album.images.isEmpty {
                        Image(systemName: "music.note")
                            .cornerRadius(15.0)
                            .blur(radius: 4.2)
                            .scaledToFill()
                            .frame(maxHeight: maxHeight)
                            .clipped()
                    } else {
                        AsyncImage(url: URL(string: song.album.images[0].url)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image.resizable()
                                    .cornerRadius(15.0)
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .blur(radius: 4.2)
                        .scaledToFill()
                        .frame(maxHeight: maxHeight)
                        .clipped()
                    }
                }
                .cornerRadius(15.0)
                
                HStack {
                    RoundedRectangle(cornerRadius: 15.0)
                        .foregroundColor(.gray.opacity(0.7))
                        .cornerRadius(15.0)
                        .scaledToFill()
                        .frame(maxHeight: maxHeight)
                        .clipped()
                }
                .cornerRadius(15.0)
                
                HStack(alignment: .center) {
                    if song.album.images.isEmpty {
                        Image(systemName: "music.note")
                            .aspectRatio(1, contentMode: .fit)
                            .cornerRadius(15.0)
                            .frame(maxWidth: 90, maxHeight: 90)
                            .padding(.all)
                    } else {
                        AsyncImage(url: URL(string: song.album.images[0].url)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image.resizable()
                                    .cornerRadius(15.0)
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .cornerRadius(15.0)
                        .frame(maxWidth: 90, maxHeight: 90)
                        .padding(.all)
                    }
                    
                    VStack(alignment: .leading) {
                        Text(song.name)
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
        popularity: 88
    )
    return SongCard(input: Media(input: .song(mockSong)))
}
