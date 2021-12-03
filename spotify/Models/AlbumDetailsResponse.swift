//
//  AlbumDetailsResponse.swift
//  spotify
//
//  Created by Bryan on 2021/12/2.
//

import Foundation



struct AlbumDetailsResponse:Codable{
    
    let album_type:String
    let artists: [Artist]
    let available_markets : [String]
    let external_urls: [String:String]
    let id :String
    let images : [APIImage]
    let name: String
    let popularity:Int
    let release_date :String
    let total_tracks :Int
    let label :String
    let tracks :TracksResponse
    
    
}

struct TracksResponse:Codable{
    let items:[AudioTrack]
}
