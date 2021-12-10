//
//  LibraryPlaylistsViewController.swift
//  spotify
//
//  Created by Bryan on 2021/12/9.
//

import UIKit

class LibraryPlaylistsViewController: UIViewController {
    
    private var playlists = [Playlist]()
    
    private let noPlaylistsView = ActionLabelView()
    
    private let tableView:UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(SearchResultSubtitleTableViewCell.self, forCellReuseIdentifier: SearchResultSubtitleTableViewCell.identifier)
        tableView.isHidden = true
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        setUpNoPlaylistsView()
        fetchData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noPlaylistsView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        noPlaylistsView.center = view.center
        tableView.frame = view.bounds
        
    }
    
    private func updateUI(){
        
        if playlists.isEmpty {
            DispatchQueue.main.async {
                self.noPlaylistsView.isHidden = false
            }

        }else{
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.isHidden = false
                self.noPlaylistsView.isHidden = true
            }
        }
    }
    
    private func setUpNoPlaylistsView(){
        noPlaylistsView.configure(with: ActionLabelViewModel(text: "You dont have any playlists", actionTitle: "create"))
        view.addSubview(noPlaylistsView)
        noPlaylistsView.delegate = self
    }
    
    
    private func fetchData(){
        APICaller.shared.getCurrentUserPlaylists { [weak self]result in
            switch result{
            case .success(let playlists):
                self?.playlists = playlists
                self?.updateUI()
            case.failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    public func showCreatePlaylistAlert(){
        let alert = UIAlertController(title: "New Playlists", message: "Enter playlist name", preferredStyle: .alert)
        alert.addTextField { textFiled in
            textFiled.placeholder = "playlist......."
        }
        alert.addAction(UIAlertAction(title: "Canecel", style:.cancel , handler: nil))
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { _ in
            guard let field = alert.textFields?.first,
                  let text = field.text,
                  !text.trimmingCharacters(in: .whitespaces).isEmpty else{
                      return
                  }
            APICaller.shared.createPlaylist(with: text) { success in
                if success{
                    //refresh lis of playlists
                }else{
                    print("Failed to create playlist")
                }
            }
        }))
    
        
        present(alert, animated: true, completion: nil)
    }
}

extension LibraryPlaylistsViewController: ActionLabelViewDelegate{
    func ActionLabelViewDidTapButton(_ actionView: ActionLabelView) {
        //showCreationUI
        showCreatePlaylistAlert()
    }
    
    
}

extension LibraryPlaylistsViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        playlists.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:SearchResultSubtitleTableViewCell.identifier , for: indexPath) as! SearchResultSubtitleTableViewCell
        let playlist = playlists[indexPath.row]
        cell.configure(with: SearchResultSubtitleTableViewCellViewModel(title: playlist.name, subtitle: playlist.description, imageURL: URL(string: playlist.images.first?.url ?? "")))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    
}


