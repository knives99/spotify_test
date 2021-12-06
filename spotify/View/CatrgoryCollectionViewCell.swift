//
//  CatrgoryCollectionViewCell.swift
//  spotify
//
//  Created by Bryan on 2021/12/6.
//
import SDWebImage
import UIKit

class CatrgoryCollectionViewCell: UICollectionViewCell {
    
    static let identifier =  "CatrgoryCollectionViewCell"
    
    let imageView :UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .white
        imageView.image = UIImage(systemName: "music.quarternote.3",withConfiguration: UIImage.SymbolConfiguration(pointSize: 50, weight: .regular))
        return imageView
    }()
    
    private let label :UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .white
        return label
    }()
    
    private let colors:[UIColor] = [
        .systemPurple,
        .systemGreen,
        .systemRed,
        .systemCyan,
        .systemBlue,
        .systemMint,
        .systemYellow
    ]
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(label)
        contentView.layer.cornerRadius =  8
        contentView.layer.masksToBounds = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        label.text = nil
        imageView.image = UIImage(systemName: "music.quarternote.3",withConfiguration: UIImage.SymbolConfiguration(pointSize: 50, weight: .regular))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: 10, y: contentView.height / 2 + 15, width: contentView.width, height: contentView.height / 2)
        imageView.frame = CGRect(x: 0, y: 30, width: contentView.width , height: contentView.height / 3 * 2)
        
    }
    
    func configure(with viewModel:CatrgoryCollectionViewCellViewModel){
        label.text = viewModel.title
        imageView.sd_setImage(with: viewModel.artWorkURL, completed: nil)
        contentView.backgroundColor = colors.randomElement()
    }
}
