//
//  PlayerControlsView.swift
//  spotify
//
//  Created by Bryan on 2021/12/7.
//

import Foundation
import UIKit

protocol PlayerControlsViewDelegate : AnyObject{
    func PlayerControlsViewDidTapPlayPauseButton(_ playerControlsView:PlayerControlsView)
    func PlayerControlsViewDidTapForwardButton(_ playerControlsView:PlayerControlsView)
    func PlayerControlsViewDidTapBackwardsButton(_ playerControlsView:PlayerControlsView)
    func PlayerControlsView(_ playerControlsView:PlayerControlsView,didSlideSlider value:Float)
}

struct PlayerControlsViewModel {
    
    let title :String?
    let subtitle:String?
}

final class PlayerControlsView:UIView{
    
    weak var delegate : PlayerControlsViewDelegate?
    
    private var isPlaying = true
    
    private let volumeSlider:UISlider = {
        let slider = UISlider()
        slider.value = 0.5
        return slider
    }()
    
    private let nameLabel:UILabel = {
        let label = UILabel()
        label.text =  "Thi is sslkfmflmmf"
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    private let subtitleLabel:UILabel = {
        let label = UILabel()
        label.text = "mfmfngngngngngm;....f.f.f"
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let backButton :UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "backward.fill",withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .regular))
        button.setImage(image, for: .normal)
        return button
    }()
    private let nextButton :UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "forward.fill",withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .regular))
        button.setImage(image, for: .normal)
        return button
    }()
    private let playPauseButton :UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "pause",withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .regular))
        button.setImage(image, for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(nameLabel)
        addSubview(subtitleLabel)
        addSubview(volumeSlider)
        addSubview(backButton)
        addSubview(nextButton)
        addSubview(playPauseButton)
        
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
        playPauseButton.addTarget(self, action: #selector(didTapPlayPause), for: .touchUpInside)
        volumeSlider.addTarget(self, action: #selector(didSlideSlider(_:)), for: .valueChanged)
        
        clipsToBounds = true
        
    }
    
    @objc func didSlideSlider(_ slider: UISlider){
        let value = slider.value
        delegate?.PlayerControlsView(self, didSlideSlider: value)
    }
    
    @objc private func didTapBack(){
        delegate?.PlayerControlsViewDidTapBackwardsButton(self)
    }
    
    @objc private func didTapNext(){
        delegate?.PlayerControlsViewDidTapForwardButton(self)
    }
    
    @objc private func didTapPlayPause(){
        self.isPlaying = !isPlaying
        delegate?.PlayerControlsViewDidTapPlayPauseButton(self)
        
        //update icon
        
        let pause = UIImage(systemName: "pause",withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .regular))
        let playing = UIImage(systemName: "play.fill",withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .regular))
        
        playPauseButton.setImage(isPlaying ? pause:playing, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.frame = CGRect(x: 0, y: 0, width: width, height: 50)
        subtitleLabel.frame = CGRect(x: 0, y: nameLabel.bottom + 10, width: width, height: 50)
        volumeSlider.frame = CGRect(x: 10, y: subtitleLabel.bottom + 20 , width: width - 20, height: 44)
        let buttonSize :CGFloat = 60
        playPauseButton.frame = CGRect(x: (width - buttonSize) / 2, y: volumeSlider.bottom + 30, width: buttonSize, height: buttonSize)
        backButton.frame = CGRect(x: playPauseButton.left - 80 - buttonSize, y: playPauseButton.top, width: buttonSize, height: buttonSize)
        nextButton.frame = CGRect(x: playPauseButton.right + 80 , y: playPauseButton.top, width: buttonSize, height: buttonSize)
        
    }
    
    func configure(with viewModel:PlayerControlsViewModel){
        nameLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
    }
    
}
