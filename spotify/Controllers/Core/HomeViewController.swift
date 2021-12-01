//
//  ViewController.swift
//  spotify
//
//  Created by Bryan on 2021/11/25.
//

import UIKit

enum BrowseSectionType{
    case newReleases(viewModels:[NewReleasesCellViewModel])
    case featuredPlaylists(viewModels:[NewReleasesCellViewModel])
    case recommendedTracks(viewModels:[NewReleasesCellViewModel])
    
}

class HomeViewController: UIViewController {
    
    
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
            print("GROUP NOTIFY")
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
            self.configureModels(newAlbums: newAlbums, playlits: playlists, tracks: tracks)
        }
    }
    
    private func configureModels(newAlbums:[Album],playlits:[Playlist],tracks:[AudioTrack]){
                //Configure Models
        let albumModels = newAlbums.compactMap { album in
           return NewReleasesCellViewModel(name: album.name, artworkURL: URL(string: album.images.first?.url ?? ""), numberOfTracks: album.total_tracks, artistName: album.artists.first?.name ?? "_" )
        }
                sections.append(.newReleases(viewModels: albumModels))
                sections.append(.featuredPlaylists(viewModels: []))
                sections.append(.recommendedTracks(viewModels: []))
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
    

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let type = sections[indexPath.section]
        
        switch type{
        case.newReleases(let viewmodels):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewReleaseCollectionViewCell.identifier, for: indexPath) as! NewReleaseCollectionViewCell
            let viewmodel = viewmodels[indexPath.row]
            cell.configure(with: viewmodel)
            return cell
        case.recommendedTracks(let viewmodels):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedTrackCollectionViewCell.identifier, for: indexPath) as! RecommendedTrackCollectionViewCell
            cell.backgroundColor = .systemGreen
            return cell
        case.featuredPlaylists(let viewmodels):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier, for: indexPath) as! FeaturedPlaylistCollectionViewCell
            cell.backgroundColor = .systemPink
            return cell

        }
    }
    
    static func createSectionLayout(section:Int) -> NSCollectionLayoutSection{
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
            return section
        }
    }
}

