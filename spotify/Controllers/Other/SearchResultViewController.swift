//
//  SearchResultViewController.swift
//  spotify
//
//  Created by Bryan on 2021/11/25.
//

import UIKit

struct SearchSection {
    let title :String
    let results:[SearchResult]
}

protocol searchResultViewControllerDelegate:AnyObject{
    func didTapResult(_ result:SearchResult)
}

class SearchResultViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    private var sections:[SearchSection] = []
    
    weak var delegate:searchResultViewControllerDelegate?
    
    
    private let tableView:UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(SearchResultDefaultTaBleViewCell.self, forCellReuseIdentifier: SearchResultDefaultTaBleViewCell.identifier)
        tableView.register(SearchResultSubtitleTableViewCell.self, forCellReuseIdentifier: SearchResultSubtitleTableViewCell.identifier)
        tableView.isHidden = true
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
       title = "loaam"
        view.backgroundColor = .clear
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func update(with results:[SearchResult]){
        
        
        let artists = results.filter({
            switch $0 {
            case.artist:
                return true
            default : return false
            }
        })
        let albums = results.filter({
            switch $0 {
            case.album:
                return true
            default : return false
            }
        })
        let tracks = results.filter({
            switch $0 {
            case.track:
                return true
            default : return false
            }
        })
        let playlists = results.filter({
            switch $0 {
            case.playlist:
                return true
            default : return false
            }
        })
        
        sections.append(SearchSection(title: "Songs", results: tracks))
        sections.append(SearchSection(title: "Albums", results: albums))
        sections.append(SearchSection(title: "Artists", results: artists))
        sections.append(SearchSection(title: "playlists", results: playlists))
        
        tableView.reloadData()
        tableView.isHidden = results.isEmpty
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].results.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let result = sections[indexPath.section].results[indexPath.row]
        let Acell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        switch result {
            
        case.artist(let model):
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultDefaultTaBleViewCell.identifier, for: indexPath) as! SearchResultDefaultTaBleViewCell
            let viewModel = SearchResultDefaultTableViewCellViewModel(title: model.name, imageURL: URL(string: model.images?.first?.url ?? "") )
            cell.configure(with: viewModel)
            return cell
            
        case.album(let model):
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.identifier, for: indexPath) as! SearchResultSubtitleTableViewCell
            cell.configure(with: SearchResultSubtitleTableViewCellViewModel(title: model.name, subtitle: model.artists.first?.name ?? "", imageURL: URL(string: model.images.first?.url ?? "")))
            return cell
            
        case.track(let model):
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.identifier, for: indexPath) as! SearchResultSubtitleTableViewCell
            cell.configure(with: SearchResultSubtitleTableViewCellViewModel(title: model.name, subtitle: model.artists.first?.name ?? "", imageURL: URL(string: model.album?.images.first?.url ?? "")))
            return cell
            
        case.playlist(let model):
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.identifier, for: indexPath) as! SearchResultSubtitleTableViewCell
            cell.configure(with: SearchResultSubtitleTableViewCellViewModel(title: model.name, subtitle: model.description, imageURL: URL(string: model.images.first?.url ?? "" )))
            return cell
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let result = sections[indexPath.section].results[indexPath.row]
        delegate?.didTapResult(result)
        
    }


}
