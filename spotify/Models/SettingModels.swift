//
//  SettingModels.swift
//  spotify
//
//  Created by Bryan on 2021/11/29.
//

import Foundation

struct Section {
    let title :String
    let options : [option]
}

struct option {
    let title :String
    let handler : ()->Void
}
