//
//  Playlist.swift
//  spotify
//
//  Created by Bryan on 2021/11/25.
//

import Foundation

struct Playlist:Codable{
    let description: String
    let external_urls : [String:String]
    let id : String
    let images:[APIImage]
    let name : String
    let owner : User
}
