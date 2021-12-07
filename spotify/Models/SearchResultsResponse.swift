//
//  SearchResultsResponse.swift
//  spotify
//
//  Created by Bryan on 2021/12/6.
//

import Foundation

struct SearchResultsResponse:Codable{
    let albums:SearchAlbumResponse
    let artists:SearchArtistsResonse
    let playlists:SearchPlaylistsResponse
    let tracks:SearchTracksResponse
}

struct SearchAlbumResponse :Codable{
    let items : [Album]
}

struct SearchArtistsResonse:Codable{
    let items : [Artist]
}

struct SearchPlaylistsResponse:Codable{
    let items : [Playlist]
}


struct SearchTracksResponse:Codable{
    let items : [AudioTrack]
}
