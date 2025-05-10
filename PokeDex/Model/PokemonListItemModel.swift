//
//  PokemonDetailsObject.swift
//  PokeDex
//
//  Created by Deepak Ghadi on 10/05/25.
//

import RealmSwift

class PokemonListItemModel: Object {
    @Persisted(primaryKey: true) var name: String
    @Persisted var url: String
    @Persisted var imageUrl: String
    @Persisted var id: Int
    
    @Persisted var base_experience: Int
    @Persisted var hp: Int
    @Persisted var attack: Int
    @Persisted var defense:Int
//    @Persisted var special_attack:Int
//    @Persisted var special-defense:Int
    @Persisted var speed:Int
    @Persisted var height:Int
    @Persisted var weight:Int
    
}


