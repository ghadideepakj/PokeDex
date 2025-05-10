//
//  PokemonsListModel.swift
//  PokeDex
//
//  Created by Deepak Ghadi on 08/05/25.
//

import Foundation

struct PokemonsListModel : Codable {
    let results: [PokemonListResult]?
    let count: Int?
    let next: String?
    let previous: String?
    
}

struct PokemonListResult: Codable {
    let name: String
    let url: String
}

struct PokemonDetail: Codable {
    let id: Int?
    let base_experience: Int
    let height: Int
    let weight: Int
    let stats: [Stat]
    let sprites: Sprites
}

struct Stat: Codable {
    let base_stat: Int
    let stat: StatInfo
}

struct StatInfo: Codable {
    let name: String
}

struct Sprites: Codable {
    let front_default: String?
}

