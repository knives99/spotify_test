//
//  ViewController.swift
//  spotify
//
//  Created by Bryan on 2021/11/25.
//

import UIKit

enum BrowseSectionType{
    case newReleases(viewModels:[NewReleasesCellViewModel])
    case featuredPlaylists(viewModels:[FeaturedPlaylistCellViewModel])
    case recommendedTracks(viewModels:[RecommendedTrackCellViewModel])
    
    var title:String{
        switch self {
        case .newReleases(let viewModels):
            return "New Release"
        case .featuredPlaylists(let viewModels):
            return "Featured"
        case .recommendedTracks(let viewModels):
            return "Recommended"
        }
    }
    
}

class HomeViewController: UIViewController {
    
    var newAlbums = [Album]()
    var playlists = [Playlist]()
    var tracks = [AudioTrack]()
    
    
    let collectionView :UICollectionView = UICollectionView(frame: .zero,
                                                            collectionViewLayout:
                                                                UICollectionViewCompositionalLayout(sectionProvider: { sectionIndex, _ in
        createSectionLayout(section: sectionIndex)
    }))
    
    
    let spinner :UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.tintColor = .label
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    private var sections = [BrowseSectionType]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .done, target: self, action: #selector(didTapSetting))
        configureCollectionView()
        view.addSubview(spinner)
        fetchDate()
        
    }
    
    
    private func configureCollectionView(){
        collectionView.register(NewReleaseCollectionViewCell.self, forCellWithReuseIdentifier: NewReleaseCollectionViewCell.identifier)
        collectionView.register(FeaturedPlaylistCollectionViewCell.self, forCellWithReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier)
        collectionView.register(RecommendedTrackCollectionViewCell.self, forCellWithReuseIdentifier: RecommendedTrackCollectionViewCell.identifier)
        collectionView.register(TitleHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TitleHeaderCollectionReusableView.identifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
    }
    
    private func fetchDate(){

        let group = DispatchGroup()
        
        group.enter()
        group.enter()
        var newRelease:NewReleaseResponse?
        var featuredPlaylistsResponse : FeaturedPlaylistsResponse?
        var recommendationsResponse : RecommendationsResponse?
        
        
        //New Releases
        APICaller.shared.gerNewRelease { result in
            defer{
                group.leave()
            }
            switch result{
            case .success(let model):
                newRelease = model
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        //Featured Playlists,
        APICaller.shared.getFeaturedPlaylists { result in
            defer{
                group.leave()
            }
            switch result{
            case .success(let model):
                featuredPlaylistsResponse = model
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        //Recommended Tracks ,
 
        
        APICaller.shared.getRecommendedGenres { result in

            switch result{
            case .success(let model):

                var seeds = Set<String>()
                while seeds.count < 5 {
                    if let random = model.genres.randomElement(){
                        seeds.insert(random)
                    }
                    group.enter()
                    APICaller.shared.getRecommendations(genres: seeds) { recommendedResult in

                        defer{
                            group.leave()
                        }
                        
                        switch recommendedResult{
                        case.success(let model):
                            recommendationsResponse = model
                        case.failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        

        
        
        group.notify(queue: .main) {
//            guard let newAlbums = newRelease?.albums.items,
//                  let playlists = featuredPlaylistsResponse?.playlists.items,
//                  let tracks = recommendationsResponse?.tracks else{
//                      return}
            guard let newAlbums = newRelease?.albums.items else {assertionFailure()
                return}
            guard let playlists = featuredPlaylistsResponse?.playlists.items else {assertionFailure()
                return}
            guard let tracks = recommendationsResponse?.tracks else{assertionFailure()
                return}
            
            self.newAlbums = newAlbums
            self.playlists = playlists
            self.tracks = tracks
            self.configureModels(newAlbums: newAlbums, playlits: playlists, tracks: tracks)
        }
    }
    
    private func configureModels(newAlbums:[Album],playlits:[Playlist],tracks:[AudioTrack]){
        //Configure Models
        let albumModels = newAlbums.compactMap { album in
            return NewReleasesCellViewModel(name: album.name,
                                            artworkURL: URL(string: album.images.first?.url ?? ""),
                                            numberOfTracks: album.total_tracks,
                                            artistName: album.artists.first?.name ?? "_" )
        }
        sections.append(.newReleases(viewModels: albumModels))
        
        sections.append(.featuredPlaylists(viewModels: playlits.compactMap({
            return FeaturedPlaylistCellViewModel(name: $0.name,
                                                 artworkURL: URL(string: $0.images.first?.url ?? ""),
                                                 creatorName: $0.owner.display_name)
        })))
        
        sections.append(.recommendedTracks(viewModels: tracks.compactMap({
            return RecommendedTrackCellViewModel(name: $0.name,
                                                 artistName: $0.artists.first?.name ?? "",
                                                 artworkURL: URL(string: $0.album?.images.first?.url ?? ""))
        })))
        collectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
  
    @objc func didTapSetting(){
        let vc = SettingViewController()
        vc.title = "Setting"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

extension HomeViewController: UICollectionViewDelegate,UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let type = sections[section]
        switch type{
        case.newReleases(let viewModels):
           return viewModels.count
        case.featuredPlaylists(let viewModels):
            return viewModels.count
        case.recommendedTracks(let viewModels):
            return viewModels.count
            
        }
    
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {return UICollectionReusableView()}
        
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TitleHeaderCollectionReusableView.identifier, for: indexPath) as! TitleHeaderCollectionReusableView
    
        header.configure(with: sections[indexPath.section].title)
        
        return header
    }
    

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let type = sections[indexPath.section]
        
        switch type{
        case.newReleases(let viewmodels):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewReleaseCollectionViewCell.identifier, for: indexPath) as! NewReleaseCollectionViewCell
            let viewmodel = viewmodels[indexPath.row]
            cell.configure(with: viewmodel)
            return cell
            
        case.featuredPlaylists(let viewmodels):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier, for: indexPath) as! FeaturedPlaylistCollectionViewCell
            
            let viewModel = viewmodels[indexPath.row]
            cell.configure(with: viewModel)
            return cell

        case.recommendedTracks(let viewmodels):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedTrackCollectionViewCell.identifier, for: indexPath) as! RecommendedTrackCollectionViewCell
            let viewModel = viewmodels[indexPath.row]
            cell.configure(with: viewModel)
            return cell

        }
        
    
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let type = sections[indexPath.section]
        switch type{
        case.newReleases:
            let album = newAlbums[indexPath.row]
            let vc = AlbumViewController(album: album)
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
            
        case.featuredPlaylists:
            let playlist = playlists[indexPath.row]
            let vc = PlayListViewController(playlist: playlist)
            navigationItem.largeTitleDisplayMode = .never
            navigationItem.title = playlist.name
            navigationController?.pushViewController(vc, animated: true)
        case.recommendedTracks:break
            
        }
    }
    
    static func createSectionLayout(section:Int) -> NSCollectionLayoutSection{
        let headerView = [NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)]
        switch section{
        case 0 :
            //itme
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                                                 heightDimension: .fractionalHeight(1.0)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            //group
            let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                                                            heightDimension: .absolute(390)),
                                                         subitem: item,
                                                         count: 3)
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9),
                                                                                            heightDimension: .absolute(390)),
                                                         subitem: verticalGroup,
                                                         count: 1)
            
            
            //section
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .groupPaging
            section.boundarySupplementaryItems = headerView
            return section
            
        case 1:
            //itme
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension:.fractionalWidth(1),
                                                                                 heightDimension:.fractionalWidth(1)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            //group
            
            let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                                                                    heightDimension: .fractionalHeight(1)),
                                                         subitem: item,
                                                         count: 2)
            

            let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(200),
                                                                                            heightDimension: .absolute(400)),
                                                         subitem: verticalGroup,
                                                         count: 1)
            
            
            //section
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .continuous
            section.boundarySupplementaryItems = headerView
            return section
            
        case 2:
            //itme
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                                                 heightDimension: .fractionalHeight(1.0)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            //group
            let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                                                            heightDimension: .absolute(80)),
                                                         subitem: item,
                                                         count: 1)

            
            
            //section
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = headerView
            return section
            
 
        default:
            //itme
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                                                 heightDimension: .fractionalHeight(1.0)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            //group
            let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                                                            heightDimension: .absolute(390)),
                                                         subitem: item,
                                                         count: 1)

            //section
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .groupPaging
            section.boundarySupplementaryItems = headerView
            return section
        }
    }
}

