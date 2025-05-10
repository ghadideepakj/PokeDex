//
//  PokemonDetailVC.swift
//  PokeDex
//
//  Created by Deepak Ghadi on 08/05/25.
//

import UIKit
import Alamofire
import Toast_Swift

class PokemonDetailVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var pokemonImageView: UIImageView!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailsTableView: UITableView!
    
    var statTuple : [(name: String, value: Int)] = []
    var pokemonName: String?
    var pokeDetailUrl : String?
    var pokeId: Int?
    var pokeImageUrl: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailsTableView.delegate = self
        detailsTableView.dataSource = self
        detailsTableView.isHidden = true
        
        if statTuple.isEmpty {
            updateUI()
        } else {
            if let imageURL = URL(string: pokeImageUrl ?? "") {
                pokemonImageView.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "placeholder"))
            } else {
                pokemonImageView.image = UIImage(named: "placeholder")
            }
            nameLabel.text = pokemonName
            rankLabel.text = "ID: \(pokeId ?? 0)"
            detailsTableView.reloadData()
            self.detailsTableView.isHidden = false
        }
        //updateUI()
    }
    
    func extractStatTuples(from stats: [Stat]) -> [(name: String, value: Int)] {
        return stats.map { stat in
            (name: stat.stat.name, value: stat.base_stat)
        }
    }
    
    //MARK: - Update UI with details
    
    func updateUI() {
        self.nameLabel.text = pokemonName
        if let urlStr = pokeDetailUrl, let url = URL(string: urlStr) {
            AF.request(url).responseDecodable(of: PokemonDetail.self) { response in
                switch response.result {
                case .success(let detail):
                    DispatchQueue.main.async {
                        if let rankOfPokemon = detail.id {
                            self.rankLabel.text = "Rank: \(rankOfPokemon)"
                        }else{
                            self.rankLabel.isHidden = true
                        }
                        self.statTuple = self.extractStatTuples(from: detail.stats)
                        
                        if let imageUrl = detail.sprites.front_default,
                           let url = URL(string: imageUrl) {
                            AF.request(url).responseData { imgResp in
                                if let data = imgResp.data {
                                    self.pokemonImageView.image = UIImage(data: data)
                                }
                            }
                        }
                        self.detailsTableView.reloadData()
                        self.detailsTableView.isHidden = false
                    }
                case .failure(let error):
                    print("Error fetching detail: \(error)")
                    self.view.makeToast("Something went wrong. Please try again", duration: 3.0, position: .center)
                }
            }
        }
    }
    
    //MARK: - Table View Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return detailsArrayName?.count ?? 0
        return statTuple.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = detailsTableView.dequeueReusableCell(withIdentifier: "PokedetailsTableCell", for: indexPath) as! PokedetailsTableCell
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(
            roundedRect: cell.outerView.bounds,
            byRoundingCorners: [.topRight, .bottomRight],
            cornerRadii: CGSize(width: 25.0, height: 25.0)
        ).cgPath
        cell.outerView.layer.mask = maskLayer
        
        let statObj = statTuple[indexPath.row]
        cell.powerNameLabel.text = statObj.name
        cell.strenghtLabel.text = "\(statObj.value)"
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

//MARK: - Table View Cell
class PokedetailsTableCell : UITableViewCell {
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var powerNameLabel: UILabel!
    @IBOutlet weak var strenghtLabel: UILabel!
}


