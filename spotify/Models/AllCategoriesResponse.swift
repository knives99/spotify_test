//
//  AllCategoriesResponse.swift
//  spotify
//
//  Created by Bryan on 2021/12/6.
//

import Foundation

struct AllCategoriesResponse:Codable {
    let categories : categories
    
}

struct categories:Codable{
    let items:[Category]
}

struct Category:Codable{
    let id :String
    let name:String
    let icons:[APIImage]

}

