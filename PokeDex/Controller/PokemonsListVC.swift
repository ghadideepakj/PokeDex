//
//  PokemonsListVC.swift
//  PokeDex
//
//  Created by Deepak Ghadi on 07/05/25.
//

import UIKit
import Alamofire
import RealmSwift
import SDWebImage
import SwiftLoader
import Toast_Swift

class PokemonsListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var pokeListTableView: UITableView!
    var pokemonsArray : [PokemonListResult]?
    
    let realm = try! Realm()
    var pokemonList: Results<PokemonListItemModel>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pokeListTableView.delegate = self
        pokeListTableView.dataSource = self
        pokemonList = realm.objects(PokemonListItemModel.self)
        //getPokemonsList()
        //fetchAndCachePokemonList()
        checkAndLoadData()
        addRefreshBtn()
        UserDefaults.standard.set(true, forKey: "isRefreshBtnEnable")
    }
    
    //Custom floating button
    func addRefreshBtn() {
        let buttonSize: CGFloat = 50
        let buttonX = view.frame.size.width - buttonSize - 50
        let buttonY = view.frame.size.height - buttonSize - 50
        
        let refreshButton = UIButton(type: .system)
        refreshButton.frame = CGRect(x: buttonX, y: buttonY, width: buttonSize, height: buttonSize)
        
        // Configuration for image-only button
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "arrow.clockwise")
        config.baseBackgroundColor = .white
        config.baseForegroundColor = .black
        config.cornerStyle = .capsule // Fully rounded
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        
        refreshButton.configuration = config
        
        // Add shadow styling
        refreshButton.layer.shadowColor = UIColor.black.cgColor
        refreshButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        refreshButton.layer.shadowOpacity = 0.5
        refreshButton.layer.shadowRadius = 5
        refreshButton.clipsToBounds = false
        
        refreshButton.addTarget(self, action: #selector(customButtonTapped), for: .touchUpInside)
        view.addSubview(refreshButton)
    }
    
    @objc func customButtonTapped() {
        
        if UserDefaults.standard.bool(forKey: "isRefreshBtnEnable") {
            UserDefaults.standard.set(false, forKey: "isRefreshBtnEnable")
            
            self.fetchAndCachePokemonList()
            
        }else{
            //List updated sucessfully
            print("List Already updated")
            self.view.makeToast("Latest list fetched succesfully", duration: 3.0, position: .center)
        }
        
    }
    
    //MARK: - Check if data exists
    func checkAndLoadData() {
        let realm = try! Realm()
        let savedPokemons = realm.objects(PokemonListItemModel.self).sorted(byKeyPath: "id", ascending: true)
        
        if savedPokemons.isEmpty {
            // No cached data → Fetch from API
            fetchAndCachePokemonList()
        } else {
            // Data exists → Load from Realm
            pokemonList = savedPokemons
            pokeListTableView.reloadData()
        }
    }
    
    func statValue(named name: String, in stats: [Stat]) -> Int {
        return stats.first(where: { $0.stat.name == name })?.base_stat ?? 0
    }
    
    //MARK: - Fetch data from API
    func fetchAndCachePokemonList() {
        
        //Custome Activity Indicator
        //self.showSpinner()
        //Library for loader
        SwiftLoader.show(title: "Loading...", animated: true)
        
        APIManager.getListOfPokemons().responseDecodable(of: PokemonsListModel.self) { response in
            switch response.result {
            case .success(let listModel):
                let realm = try! Realm()
                
                guard let results = listModel.results else {
                    print("No results found.")
                    //self.removeSpinner()
                    SwiftLoader.hide()
                    return
                }
                for result in results {
                    // For each item in the list, fetch details
                    AF.request(result.url).responseDecodable(of: PokemonDetail.self) { detailResponse in
                        switch detailResponse.result {
                        case .success(let detail):
                            let imageUrl = detail.sprites.front_default ?? ""
                            
                            let pokemonItem = PokemonListItemModel()
                            pokemonItem.name = result.name
                            pokemonItem.url = result.url
                            pokemonItem.imageUrl = imageUrl
                            pokemonItem.id = detail.id ?? 0
                            
                            pokemonItem.base_experience = detail.base_experience
                            pokemonItem.speed = self.statValue(named: "speed", in: detail.stats)
                            pokemonItem.height = detail.height
                            pokemonItem.weight = detail.weight
                            
                            pokemonItem.hp = self.statValue(named: "hp", in: detail.stats)
                            pokemonItem.attack = self.statValue(named: "attack", in: detail.stats)
                            pokemonItem.defense = self.statValue(named: "defense", in: detail.stats)
                            
                            try! realm.write {
                                realm.add(pokemonItem, update: .modified)
                            }
                            
                            DispatchQueue.main.async {
                                //self.removeSpinner()
                                SwiftLoader.hide()
                                self.pokeListTableView.reloadData()
                            }
                            
                        case .failure(let error):
                            self.removeSpinner()
                            print("Error fetching detail for \(String(describing: result.name)): \(error)")
                            self.view.makeToast("Something went wrong. Please try again", duration: 3.0, position: .center)
                        }
                    }
                }
                
            case .failure(let error):
                print("Failed to fetch Pokémon list: \(error)")
                self.view.makeToast("Something went wrong. Please try again", duration: 3.0, position: .center)
            }
        }
    }
    
    //MARK: - TableView Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pokemonList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = pokeListTableView.dequeueReusableCell(withIdentifier: "PokeListTableViewCell", for: indexPath) as! PokeListTableViewCell
        
        cell.outerView.layer.cornerRadius = cell.outerView.frame.height/2
        let item = pokemonList[indexPath.row]
        cell.NameLabel.text = item.name
        //cell.rankLabel.text = "ID: \(indexPath.row + 1)"
        cell.rankLabel.text = "ID: \(item.id)"
        if let imageURL = URL(string: item.imageUrl) {
            cell.pokeImageView.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "placeholder"))
        } else {
            cell.pokeImageView.image = UIImage(named: "placeholder")
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedPokemon = pokemonList[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "PokemonDetailVC") as? PokemonDetailVC {
            detailVC.pokemonName = selectedPokemon.name
            detailVC.pokeDetailUrl = selectedPokemon.url
            detailVC.pokeId = selectedPokemon.id
            detailVC.pokeImageUrl = selectedPokemon.imageUrl
            
            if let realm = try? Realm(),
               let cachedItem = realm.object(ofType: PokemonListItemModel.self, forPrimaryKey: selectedPokemon.name) {
                detailVC.statTuple = [
                    (name: "base_experience", value: cachedItem.base_experience),
                    (name: "Speed", value: cachedItem.speed),
                    (name: "Height", value: cachedItem.height),
                    (name: "Weight", value: cachedItem.weight),
                    (name: "HP", value: cachedItem.hp),
                    (name: "Attack", value: cachedItem.attack),
                    (name: "Defense", value: cachedItem.defense)
                ]
            }
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}

class PokeListTableViewCell : UITableViewCell {
    
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var pokeImageView: UIImageView!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var NameLabel: UILabel!
}
