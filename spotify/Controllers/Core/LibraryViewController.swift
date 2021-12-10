//
//  LibraryViewController.swift
//  spotify
//
//  Created by Bryan on 2021/11/25.
//

import UIKit



class LibraryViewController: UIViewController {
    
    private let playListsVc = LibraryPlaylistsViewController()
    private let albumVC = LibraryAlbumViewController()
    
    private let scrollView:UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        return scrollView
    }()
    
    
    private let toggleView = LibrayToggleView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(toggleView)
        scrollView .delegate = self
        view.addSubview(scrollView)
        scrollView.contentSize = CGSize(width: view.width * 2, height: scrollView.height)
        addChildren()
        toggleView.delegate = self
        UpdateBarButton()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = CGRect(x: 0, y: view.safeAreaInsets.top + 55, width: view.width, height: view.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom - 55)
        toggleView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: 200, height: 55)
    }
    
    private func addChildren(){
        addChild(playListsVc)
        scrollView.addSubview(playListsVc.view)
        playListsVc.view.frame = CGRect(x: 0, y: 0, width: scrollView.width, height: scrollView.height)
        playListsVc.didMove(toParent: self)
        
        addChild(albumVC)
        scrollView.addSubview(albumVC.view)
        albumVC.view.frame = CGRect(x: view.width, y: 0, width: scrollView.width, height: scrollView.height)
        albumVC.didMove(toParent: self)
    }
    
    private func UpdateBarButton(){
        switch toggleView.state{
        case.playlist:
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        case.album:
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    @objc private func didTapAdd(){
        playListsVc.showCreatePlaylistAlert()
    }
}

extension LibraryViewController:UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x >= scrollView.width - 100{
            toggleView.update(state: .album)
            UpdateBarButton()
        }else{
            toggleView.update(state: .playlist)
            UpdateBarButton()
        }
    }
}

extension LibraryViewController : LibraryToggleViewDelegate{
    func libraryToggleViewDidTapPlaylists(_ toggleView: LibrayToggleView) {
        scrollView.setContentOffset(.zero, animated: true)
        UpdateBarButton()
    }
    
    func libraryToggleViewDidTapAlbums(_ toggleView: LibrayToggleView) {
        scrollView.setContentOffset(CGPoint(x: view.width, y: 0), animated: true)
        UpdateBarButton()
    }
    
    
}
