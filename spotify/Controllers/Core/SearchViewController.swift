//
//  SearchViewController.swift
//  spotify
//
//  Created by Bryan on 2021/11/25.
//

import UIKit
import SafariServices

class SearchViewController: UIViewController, UISearchResultsUpdating ,UISearchBarDelegate{

    
    
    private var categories =  [Category]()
    let searchController:UISearchController = {

        let vc = UISearchController(searchResultsController: SearchResultViewController())
        vc.searchBar.placeholder = "Songs,Arists,Albums"
        vc.searchBar.searchBarStyle  = .minimal
        vc.definesPresentationContext = true
        return vc
    }()
    
    private let collectionView:UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { index, _ in
            let item = NSCollectionLayoutItem(layoutSize:
                                                NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                                       heightDimension: .fractionalHeight(1)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 7, bottom: 2, trailing: 7)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(180)),
                                                         subitem: item, count: 2)
            group.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
            let section = NSCollectionLayoutSection(group: group)
            return section
        }))
    
    //MARK: -  LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemPink
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        view.addSubview(collectionView)
        collectionView.register(CatrgoryCollectionViewCell.self, forCellWithReuseIdentifier: CatrgoryCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        
        APICaller.shared.getCategories { result in
            DispatchQueue.main.async {
                switch result{
                case.success(let models):
                    self.categories = models
                    self.collectionView.reloadData()
                    
                    guard let category = models.first else{return}
                    APICaller.shared.getCategoryPlaylists(category: category) { result in
                        switch result{
                        case.success(let model):break

                        case .failure(let error):break
                        }
                    }
                case.failure(let error):break
                }

            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let resultController = searchController.searchResultsController as? SearchResultViewController else{return}
        
        guard let query = searchBar.text ,
              !query.trimmingCharacters(in: .whitespaces).isEmpty else {return}
        
        resultController.delegate = self
        //performSearch
        APICaller.shared.getSearch(with: query) { result in
            DispatchQueue.main.async {
                switch result{
                case.success(let results):
                    resultController.update(with:results)
                case.failure(let error):
                    print(error.localizedDescription)
                }
            }
        }

    }
    func updateSearchResults(for searchController: UISearchController) {
    }
}

extension SearchViewController:UICollectionViewDelegate,UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CatrgoryCollectionViewCell.identifier, for: indexPath) as! CatrgoryCollectionViewCell
                let category = categories[indexPath.row]
        cell.configure(with: CatrgoryCollectionViewCellViewModel(title: category.name, artWorkURL: URL(string: category.icons.first?.url ?? "")))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        HapticsManager.shared.vibrateForSelection()
        collectionView.deselectItem(at: indexPath, animated: true)
        let category = categories[indexPath.row]
        let vc = CategoryViewController(category: category)
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }

    
}

extension SearchViewController:searchResultViewControllerDelegate{
    func didTapResult(_ result: SearchResult) {
        switch result {
        case.artist(let model):
            guard let url = URL(string: model.external_urls["spotify"] ?? "") else{return}
            let vc = SFSafariViewController(url: url)
            present(vc, animated: true, completion: nil)
            
            
        case.album(let model):
            let vc = AlbumViewController(album: model)
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        case.track(let model):
            PlaybackPresenter.shared.startPlayback(form: self, track: model)
        case.playlist(let model):
            let vc = PlayListViewController(playlist: model)
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        }

    }
    

    
}
