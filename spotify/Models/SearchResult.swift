//
//  SearchResult.swift
//  spotify
//
//  Created by Bryan on 2021/12/7.
//

import Foundation


enum SearchResult {
    case artist(model:Artist)
    case album(model:Album)
    case track(model:AudioTrack)
    case playlist(model:Playlist)
}
