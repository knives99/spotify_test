//
//  LibraryAlbumsResponse.swift
//  spotify
//
//  Created by Bryan on 2021/12/10.
//

import Foundation

struct LibraryAlbumsResponse : Codable{
    let items:[LibraryAlbumsitemsResponse]
}


struct LibraryAlbumsitemsResponse:Codable{
    
    let album :Album
    
}
