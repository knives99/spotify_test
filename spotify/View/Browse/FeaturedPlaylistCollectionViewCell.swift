//
//  FeaturedPlaylistCollectionViewCell.swift
//  spotify
//
//  Created by Bryan on 2021/12/1.
//

import UIKit

class FeaturedPlaylistCollectionViewCell: UICollectionViewCell {
    
    static var identifier = "FeaturedPlaylistCollectionViewCell"
    
    let playlistCoverImageView :UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode  = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.image = UIImage(systemName: "photo")
        return imageView
    }()
    
    let playlistNameLabel : UILabel = {
        let label  = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18, weight: .regular)
        return label
    }()
    let creatorNameLabel : UILabel = {
        let label  = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15, weight: .thin)
        return label
    }()

    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .none
        contentView.addSubview(playlistCoverImageView)
        contentView.addSubview(playlistNameLabel)
        contentView.addSubview(creatorNameLabel)
        contentView.clipsToBounds = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        creatorNameLabel.frame = CGRect(x: 3,
                                        y: contentView.height - 30,
                                        width: contentView.width - 6,
                                        height: 30)
        playlistNameLabel.frame = CGRect(x: 3,
                                        y: contentView.height - 50,
                                        width: contentView.width - 6,
                                        height: 30)
        let imageSize = contentView.height - 50
        playlistCoverImageView.frame = CGRect(x: (contentView.width - imageSize) / 2,
                                              y: 3,
                                              width: imageSize,
                                              height: imageSize)
       
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playlistNameLabel.text = nil
        creatorNameLabel.text = nil
        playlistCoverImageView.image = nil
    }
    
    func configure(with viewModel: FeaturedPlaylistCellViewModel){
        playlistNameLabel.text = viewModel.name
        creatorNameLabel.text = viewModel.creatorName
        playlistCoverImageView.sd_setImage(with: viewModel.artworkURL, completed: nil)
    }
}
