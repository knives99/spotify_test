//
//  PlayListViewController.swift
//  spotify
//
//  Created by Bryan on 2021/11/25.
//

import UIKit

class PlayListViewController: UIViewController {

    private let playlist : Playlist
    
    private var viewModels  = [RecommendedTrackCellViewModel]()
    private var tracks = [AudioTrack]()
    
    private let collectionView = UICollectionView(frame: .zero,
                                                  collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { _, _ in
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                                             heightDimension: .fractionalHeight(1)))
        
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 2, bottom: 1, trailing: 2)
        
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),                                                                                            heightDimension: .estimated(60)),
                                                     subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                                                                                             heightDimension: .fractionalWidth(1)),
                                                                                          elementKind: UICollectionView.elementKindSectionHeader,
                                                                                         alignment: .top)]
        return section
    }))
    
    
    init(playlist:Playlist){
        self.playlist  = playlist
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = playlist.name
        view.addSubview(collectionView)
        collectionView.register(RecommendedTrackCollectionViewCell.self, forCellWithReuseIdentifier: RecommendedTrackCollectionViewCell.identifier)
        collectionView.register(PlaylistHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        view.backgroundColor = .secondarySystemBackground
        APICaller.shared.getDetailPlaylist(with: playlist) {[weak self] result in
            DispatchQueue.main.async {
                switch result{
                case.success(let models):
                    self?.tracks = models.tracks.items.compactMap({$0.track})
                    self?.viewModels = models.tracks.items.compactMap({
                    RecommendedTrackCellViewModel(name: $0.track.name,
                                                  artistName: $0.track.artists.first?.name ?? "-",
                                                  artworkURL: URL(string: $0.track.album?.images.first?.url ?? ""))
                    })
                    self?.collectionView.reloadData()
                    
                case.failure(let error):
                    print(error.localizedDescription)
                    
                }
            }
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapShare))
    }
    
    @objc private func didTapShare(){
        guard let url = URL(string: playlist.external_urls["spotify"] ?? "")else{
            return
        }
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: [])
        
        //為了ipad
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true, completion: nil)
        
    }

}

extension PlayListViewController: UICollectionViewDelegate, UICollectionViewDataSource{


    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier, for: indexPath) as! PlaylistHeaderCollectionReusableView
        
        
        let headerViewModel = PlaylistHeaderViewViewModel(name: playlist.name,
                                                          ownerName: playlist.owner.display_name,
                                                          description: playlist.description,
                                                          artworkURL: URL(string: playlist.images.first?.url ?? ""))
        
        header.configure(with: headerViewModel)
        header.delegate = self
        return header
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedTrackCollectionViewCell.identifier, for: indexPath) as! RecommendedTrackCollectionViewCell
        let model = viewModels[indexPath.row]
        cell.configure(with: model)
        cell.backgroundColor = .secondarySystemBackground
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let track = tracks[indexPath.row]
        PlaybackPresenter.shared.startPlayback(form: self, track: track)
    }
    
}

extension PlayListViewController:PlaylistHeaderCollectionReusableViewDelegate{
    
    func playlistHeaderCollectionReusableViewDidTapPlayAll(_ header: PlaylistHeaderCollectionReusableView) {

        PlaybackPresenter.shared.startPlayback(form: self, tracks: tracks)
    }
    
    
}
