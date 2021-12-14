//
//  PlaylistHeaderCollectionReusableView.swift
//  spotify
//
//  Created by Bryan on 2021/12/3.
//

import UIKit
import SDWebImage

protocol PlaylistHeaderCollectionReusableViewDelegate :AnyObject {
    
    func playlistHeaderCollectionReusableViewDidTapPlayAll (_ header:PlaylistHeaderCollectionReusableView)
}

final class PlaylistHeaderCollectionReusableView: UICollectionReusableView {
    
    static let identifier = "PlaylistHeaderCollectionReusableView"
    
    var delegate : PlaylistHeaderCollectionReusableViewDelegate?
    
    private let imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "photo")
        return imageView
    }()
    
    private let nameLabel:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.tintColor  = .brown
        return label
    }()
    
    private let discriptionLabel:UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.tintColor  = .brown
        return label
    }()
    
    private let ownerLabel:UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18, weight: .regular )
        label.tintColor  = .brown
        return label
    }()
    
    private let playAllButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGreen
        let image = UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize:30 , weight: .regular))
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius  =  30
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(didTapPlayAll), for: .touchUpInside)
        return button
    }()
    
    @objc private func didTapPlayAll(){
        delegate?.playlistHeaderCollectionReusableViewDidTapPlayAll(self)
    }
    
    //MARK: - Init
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubview(imageView)
        addSubview(nameLabel)
        addSubview(ownerLabel)
        addSubview(discriptionLabel)
        addSubview(playAllButton)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize = height / 1.8
        imageView.frame = CGRect(x: (width-imageSize) / 2 , y: 20, width: imageSize, height: imageSize)
        nameLabel.frame = CGRect(x: 10, y: imageView.bottom, width: width - 20, height: 44)
        discriptionLabel.frame = CGRect(x: 10, y: nameLabel.bottom, width: width - 20, height: 44)
        ownerLabel.frame = CGRect(x: 10, y: discriptionLabel.bottom, width: width - 20, height: 44)
        playAllButton.frame = CGRect(x: width - 80, y: bottom - 80, width: 60, height: 60)
    }
    
    
    func configure(with viewModel:PlaylistHeaderViewViewModel){
        
        nameLabel.text = viewModel.name
        discriptionLabel.text = viewModel.description
        ownerLabel.text = viewModel.ownerName
        imageView.sd_setImage(with: viewModel.artworkURL,placeholderImage: UIImage(systemName: "photo"), completed: nil)
    }
        
}
