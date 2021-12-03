//
//  PlaylistDetailsResponse.swift
//  spotify
//
//  Created by Bryan on 2021/12/2.
//

import Foundation

struct PlaylistDetailsResponse:Codable{
    
    let description:String
//    let followers : [String:Any]
    let external_urls :[String:String]
    let id : String
    let images : [APIImage]
    let name :String
    let snapshot_id :String
    let tracks:PlaylistTracksResponse
}


struct PlaylistTracksResponse:Codable{
    let items:[PlaylistItem]
    
}

struct PlaylistItem:Codable{
    let track :AudioTrack
}
