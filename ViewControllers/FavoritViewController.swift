//
//  FavoritViewController.swift
//  parse
//
//  Created by Антон Павлов on 01.05.2023.
//

import UIKit
import AVKit
import AVFoundation

class FavoritViewController: UIViewController {
    
    // MARK: - Properties
    var newsData = [Channels]()
    var filteredData = [Channels]()
    
    // MARK: - Cell Identifier
    let cellIdentifier = "favoritCell"
    
    // MARK: - AVPlayer Properties
    let avPlayerViewController = AVPlayerViewController()
    var avPlayer: AVPlayer?
    let movieUrl: NSURL? = NSURL(string: "http://techslides.com/demos/sample-videos/small.mp4")
    
    // MARK: - Outlets
    @IBOutlet weak var favoritSearchBar: UISearchBar!
    @IBOutlet weak var favoritTableView: UITableView!
    @IBOutlet weak var favoritBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startVideo()
        parsingJson { data in
            self.newsData = data
            DispatchQueue.main.async {
                self.favoritTableView.reloadData()
            }
        }
    }
    
    // MARK: - Запуск видео
    func startVideo() {
        if let url = movieUrl {
            self.avPlayer = AVPlayer(url: url as URL)
            self.avPlayerViewController.player = self.avPlayer
        }
    }
    
}

// MARK: - UITableViewDelegate / UITableViewDataSource
extension FavoritViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? FavoritTableViewCell else { return FavoritTableViewCell() }
        
        cell.favoritTitle.text = filteredData[indexPath.row].name_ru
        cell.favoritDescription.text = filteredData[indexPath.row].current.title
        
        if let imageURL = URL(string: filteredData[indexPath.row].image) {
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: imageURL)
                if let data = data {
                    let image = UIImage(data: data)
                    DispatchQueue.main.async {
                        cell.favoritImage.image = image
                    }
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.present(self.avPlayerViewController, animated: true) {
            self.avPlayerViewController.player?.play()
        }
    }
    
}

// MARK: - НАСТРОЙКИ SEARCH BAR
extension FavoritViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filteredData = []
        
        if searchText == "" {
            filteredData = newsData
        } else {
            for item in newsData {
                if item.name_ru.lowercased().contains(searchText.lowercased()) {
                    filteredData.append(item)
                }
            }
        }
        self.favoritTableView.reloadData()
    }
}


