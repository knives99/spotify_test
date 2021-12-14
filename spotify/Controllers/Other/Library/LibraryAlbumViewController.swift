//
//  LibraryAlbumViewController.swift
//  spotify
//
//  Created by Bryan on 2021/12/9.
//

import UIKit

class LibraryAlbumViewController: UIViewController {

    private var albums = [Album]()
    
    private let noAlbumView = ActionLabelView()
    
    private var observer:NSObjectProtocol?
    
    
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
        setUpNoAlbumsView()
        fetchData()
        observer = NotificationCenter.default.addObserver(forName: .albumSaveNotification, object: nil, queue: .main, using: { [weak self]_ in
            self?.fetchData()
        })

    }
    
    @objc func didTapClose(){
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noAlbumView.frame = CGRect(x: (view.height - 150) / 2, y: (view.height - 150) / 2, width: 150, height: 150)
//        noAlbumView.center = view.center
        tableView.frame = view.bounds
        
    }
    
    private func updateUI(){
        
        if albums.isEmpty {
            DispatchQueue.main.async {
                self.noAlbumView.backgroundColor = .red
                self.noAlbumView.isHidden = false
            }

        }else{
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.isHidden = false
                self.noAlbumView.isHidden = true
            }
        }
    }
    
    private func setUpNoAlbumsView(){
        noAlbumView.configure(with: ActionLabelViewModel(text: "You have mot saved any albums yet", actionTitle: "Browse"))
        view.addSubview(noAlbumView)
        noAlbumView.delegate = self
    }
    
    
    private func fetchData(){
        albums.removeAll()
        APICaller.shared.getCurrentUserAlbums { [weak self]result in
            DispatchQueue.main.async { [weak self] in
                switch result{
                case .success(let responses):
                    responses.items.compactMap { response in
                        let album = response.album
                        self?.albums.append(album)
                    }
                    self?.updateUI()
                case.failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }

}

extension LibraryAlbumViewController: ActionLabelViewDelegate{
    func ActionLabelViewDidTapButton(_ actionView: ActionLabelView) {
        //showCreationUI
        tabBarController?.selectedIndex = 0
    }
    
    
}

extension LibraryAlbumViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        albums.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:SearchResultSubtitleTableViewCell.identifier , for: indexPath) as! SearchResultSubtitleTableViewCell
        let album  = albums[indexPath.row]
        cell.configure(with: SearchResultSubtitleTableViewCellViewModel(title: album.name, subtitle: album.artists.first?.name ?? "-", imageURL: URL(string: album.images.first?.url ?? "")))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        HapticsManager.shared.vibrateForSelection()
        tableView.deselectRow(at: indexPath, animated: true)
        let album = albums[indexPath.row]
        
      
        let vc = AlbumViewController(album: album)
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }

}
