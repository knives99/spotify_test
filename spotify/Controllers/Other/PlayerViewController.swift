//
//  PlayerViewController.swift
//  spotify
//
//  Created by Bryan on 2021/11/25.
//

import UIKit
import SDWebImage

protocol PlayerViewControllerDelegate:AnyObject{
    
    func didTapPlayPause()
    func didTapForward()
    func didTapBackward()
    func didSlideSlider(_ value:Float)
}

class PlayerViewController: UIViewController {
    
    weak var dataSource:PlayerDataSource?
    weak var delegate : PlayerViewControllerDelegate?
    

    
    private let imageView :UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
//        imageView.backgroundColor = .blue
        return imageView
    }()
    
    private let controlsView = spotify.PlayerControlsView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(imageView)
        view.addSubview(controlsView)
        controlsView.delegate = self
        configureBarButtons()
        configure()

    }
    
    private func configure(){
        imageView.sd_setImage(with: dataSource?.imageURL, completed: nil)
        controlsView.configure(with: PlayerControlsViewModel(title: dataSource?.songName, subtitle: dataSource?.subtiltle))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.width, height: view.width)
        controlsView.frame = CGRect(x: 10, y: imageView.bottom + 10, width: view.width - 20, height: view.height - imageView.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom - 15)
    }
    
    private func configureBarButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapClose))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapAction))
    }
    
    
    @objc private func didTapClose(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapAction(){}
    
    func refreshUI(){
        configure()
    }
    

 
}

extension PlayerViewController : PlayerControlsViewDelegate {

    
    func PlayerControlsViewDidTapPlayPauseButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapPlayPause()
    }
    
    func PlayerControlsViewDidTapForwardButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapForward()
    }
    
    func PlayerControlsViewDidTapBackwardsButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapBackward()
    }
    func PlayerControlsView(_ playerControlsView:PlayerControlsView,didSlideSlider value:Float){
        delegate?.didSlideSlider(value)
    }
    
    
}
