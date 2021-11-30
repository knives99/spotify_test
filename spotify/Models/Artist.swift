//
//  Artist.swift
//  spotify
//
//  Created by Bryan on 2021/11/25.
//

import Foundation

struct Artist:Codable{
    let id :String
    let name :String
    let type:String
    let external_urls:[String:String]
}
