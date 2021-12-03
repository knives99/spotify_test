//
//  RecommendedTrackCollectionViewCell.swift
//  spotify
//
//  Created by Bryan on 2021/12/1.
//

import UIKit

class RecommendedTrackCollectionViewCell: UICollectionViewCell {
    
    static var identifier = "RecommendedTrackCollectionViewCell"
    
    let albumCoverImageView :UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode  = .scaleAspectFill
        imageView.image = UIImage(systemName: "photo")
        return imageView
    }()
    
    let trackNameLabel : UILabel = {
        let label  = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18, weight: .regular)
        return label
    }()
    let artistNameLabel : UILabel = {
        let label  = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15, weight: .thin)
        return label
    }()

    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .secondarySystemBackground
        contentView.addSubview(albumCoverImageView)
        contentView.addSubview(trackNameLabel)
        contentView.addSubview(artistNameLabel)
        contentView.clipsToBounds = true
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        albumCoverImageView.frame = CGRect(x: 5, y: 2, width: contentView.height - 4, height: contentView.height - 4)
        trackNameLabel.frame = CGRect(x: albumCoverImageView.right + 10,
                                      y: 0,
                                      width: contentView.width - albumCoverImageView.right - 15,
                                      height: contentView.height / 2)
        artistNameLabel.frame = CGRect(x: albumCoverImageView.right + 10,
                                       y: contentView.height / 2,
                                      width: contentView.width - albumCoverImageView.right - 15,
                                      height: contentView.height / 2)
       
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        trackNameLabel.text = nil
        artistNameLabel.text = nil
        albumCoverImageView.image = nil
    }
    
    func configure(with viewModel: RecommendedTrackCellViewModel){
        trackNameLabel.text = viewModel.name
        artistNameLabel.text = viewModel.artistName
        albumCoverImageView.sd_setImage(with: viewModel.artworkURL, completed: nil)
    }
}
