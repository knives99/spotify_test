//
//  LibrayToggleView.swift
//  spotify
//
//  Created by Bryan on 2021/12/9.
//

import UIKit

protocol LibraryToggleViewDelegate:AnyObject{
    func libraryToggleViewDidTapPlaylists(_ toggleView:LibrayToggleView)
    func libraryToggleViewDidTapAlbums(_ toggleView:LibrayToggleView)
}

class LibrayToggleView: UIView {
    
    enum State {
        case playlist
        case album
    }
    
    var state:State = .playlist
    
    weak var delegate: LibraryToggleViewDelegate?
    
    private let playlistButton :UIButton = {
        let button = UIButton()
        button.setTitle("playList", for: .normal)
        button.setTitleColor(.label, for: .normal)
        return button
    }()
    
    private let albumsButton :UIButton = {
        let button = UIButton()
        button.setTitle("albums", for: .normal)
        button.setTitleColor(.label, for: .normal)
        return button
    }()
    
    private let indicatorView :UIView = {
        let view = UIView()
        view.backgroundColor = .systemGreen
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 4
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(playlistButton)
        addSubview(albumsButton)
        addSubview(indicatorView)
        playlistButton.addTarget(self, action: #selector(didTapPlaylists), for: .touchUpInside)
        albumsButton.addTarget(self, action: #selector(didTapAlbums), for: .touchUpInside)
    }
    
    @objc private func didTapPlaylists(){
        state = .playlist
        delegate?.libraryToggleViewDidTapPlaylists(self)
        UIView.animate(withDuration: 0.2) {
            self.layoutIndicator()
        }
        
    }
    
    @objc private func didTapAlbums(){
        state = .album
        delegate?.libraryToggleViewDidTapAlbums(self)
        UIView.animate(withDuration: 0.2) {
            self.layoutIndicator()
        }
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playlistButton.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        albumsButton.frame = CGRect(x: playlistButton.right, y: 0, width: 100, height: 50)
  
        layoutIndicator()
    }
    
    private func layoutIndicator(){
            switch state {
            case .playlist:
                self.indicatorView.frame = CGRect(x: 0, y: playlistButton.bottom, width: 100, height: 3)
            case .album:
                self.indicatorView.frame = CGRect(x: 100, y: playlistButton.bottom, width: 100, height: 3)
            }
    }
    
    func update(state:State){
        self.state = state
        UIView.animate(withDuration: 0.2) {
            switch state {
            case .playlist:
                self.indicatorView.frame = CGRect(x: 0, y: self.playlistButton.bottom, width: 100, height: 3)
            case .album:
                self.indicatorView.frame = CGRect(x: 100, y: self.playlistButton.bottom, width: 100, height: 3)
            }
        }
    }
}
