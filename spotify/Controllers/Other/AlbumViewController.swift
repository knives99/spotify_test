//
//  AlbumViewController.swift
//  spotify
//
//  Created by Bryan on 2021/12/1.
//

import UIKit

class AlbumViewController: UIViewController {
    
    private let album : Album
    private var viewModels  = [AlbumCollectionViewCellViewModel]()
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
    
    
    
    init(album:Album){
        self.album = album
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = album.name
        view.backgroundColor = .systemBackground
        
        view.addSubview(collectionView)
        collectionView.register(AlbumTrackCollectionViewCell.self, forCellWithReuseIdentifier: AlbumTrackCollectionViewCell.identifier)
        collectionView.register(PlaylistHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
        APICaller.shared.getAlbumDetails(for: album) { [weak self]result in
            DispatchQueue.main.async {
                switch result{
                case.success(let models):
                    self?.tracks = models.tracks.items
                    self?.viewModels = models.tracks.items.compactMap({
                        AlbumCollectionViewCellViewModel(name: $0.name,
                                                      artistName: $0.artists.first?.name ?? "_")
                                                      })
                    self?.collectionView.reloadData()
                    
                case.failure(let error):
                    print(error.localizedDescription)
                    
                }
            }
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }


}


extension AlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource{


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
        
        
        let headerViewModel = PlaylistHeaderViewViewModel(name: album.name,
                                                          ownerName: album.artists.first?.name ?? "-",
                                                          description: "Release Date \(String.formattedDate(string: album.release_date))",
                                                          artworkURL: URL(string: album.images.first?.url ?? ""))
        
        header.configure(with: headerViewModel)
        header.delegate = self
        return header
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumTrackCollectionViewCell.identifier, for: indexPath) as! AlbumTrackCollectionViewCell
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

extension AlbumViewController:PlaylistHeaderCollectionReusableViewDelegate{
    func playlistHeaderCollectionReusableViewDidTapPlayAll(_ header: PlaylistHeaderCollectionReusableView) {
        PlaybackPresenter.shared.startPlayback(form: self, tracks: tracks)
    }
    
    
}

