//
//  APIManager.swift
//  PokeDex
//
//  Created by Deepak Ghadi on 08/05/25.
//

import Foundation
import Alamofire

public class APIManager : NSObject {
    
    public static func getListOfPokemons() -> DataRequest {
        AF.request("https://pokeapi.co/api/v2/pokemon?limit=50", method: .get, encoding: JSONEncoding.default)
    }
}
