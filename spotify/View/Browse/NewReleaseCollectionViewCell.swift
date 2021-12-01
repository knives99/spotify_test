//
//  NewReleaseCollectionViewCell.swift
//  spotify
//
//  Created by Bryan on 2021/12/1.
//

import UIKit
import SDWebImage

class NewReleaseCollectionViewCell: UICollectionViewCell {
    
    static var identifier = "NewReleaseCollectionViewCell"
    
    
    let albumCoverImageView :UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode  = .scaleAspectFill
        imageView.image = UIImage(systemName: "photo")
        return imageView
    }()
    
    let albumNameLabel : UILabel = {
        let label  = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        return label
    }()
    let artistNameLabel : UILabel = {
        let label  = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18, weight: .regular)
        return label
    }()
    let numberOfTracksLabel : UILabel = {
        let label  = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18, weight: .thin)
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubview(albumCoverImageView)
        contentView.addSubview(albumNameLabel)
        contentView.addSubview(artistNameLabel)
        contentView.addSubview(numberOfTracksLabel)
        contentView.clipsToBounds = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize:CGFloat = contentView.height - 10
        let albumLabelSize = albumNameLabel.sizeThatFits(CGSize(width: contentView.width - imageSize - 10, height: contentView.height - 10))
        albumNameLabel.sizeToFit()
        artistNameLabel.sizeToFit()
        numberOfTracksLabel.sizeToFit()
        
        let albumLabelHeight = min(60,albumLabelSize.height)
        albumCoverImageView.frame = CGRect(x: 5, y: 5, width: imageSize, height: imageSize)
        
        albumNameLabel.frame = CGRect(x: albumCoverImageView.right + 10,
                                      y: 5,
                                      width: albumLabelSize.width,
                                      height: albumLabelHeight)
        
        artistNameLabel.frame = CGRect(x: albumCoverImageView.right + 10,
                                       y: albumNameLabel.bottom ,
                                       width: contentView.width - albumCoverImageView.right - 10,
                                      height: 30)
        
        numberOfTracksLabel.frame = CGRect(x: albumCoverImageView.right + 10,
                                           y: contentView.bottom - 40,
                                           width: numberOfTracksLabel.width,
                                           height: 44)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        albumNameLabel.text = nil
        artistNameLabel.text = nil
        numberOfTracksLabel.text = nil
        albumCoverImageView.image = nil
    }
    
    func configure(with viewModel: NewReleasesCellViewModel){
        albumNameLabel.text = viewModel.name
        artistNameLabel.text = viewModel.artistName
        numberOfTracksLabel.text = "Tracks:\(viewModel.numberOfTracks)"
        albumCoverImageView.sd_setImage(with: viewModel.artworkURL, completed: nil)
    }
}
