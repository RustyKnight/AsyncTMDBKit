//
//  Genere.swift
//  
//
//  Created by Shane Whitehead on 21/6/2022.
//

import Foundation

public protocol Genre {
    var id: Int { get }
    var name: String { get }
}

struct DefaultGenre: Genre, Decodable {
    var id: Int
    var name: String
}
