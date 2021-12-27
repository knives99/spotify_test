//
//  WelcomeViewController.swift
//  spotify
//
//  Created by Bryan on 2021/11/25.
//

import UIKit

class WelcomeViewController: UITabBarController {
    

    private let signInButton : UIButton = {
        let button = UIButton()
        button.setTitle("SIgn In with Spotify", for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    private let imageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "album")
        return imageView
    }()
    
    private let overlayView :UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.7
        return view
    }()
    
    private let logoImageView : UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "logo"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let label :UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 32, weight: .semibold)
        label.text = "LISTEN"
        return label
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Spotify"
        view.backgroundColor = .systemGreen
        view.addSubview(imageView)
        view.addSubview(overlayView)
        view.addSubview(signInButton)
        view.addSubview(label)
        view.addSubview(logoImageView)
        
        signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)

    }
    
    
    @objc private func didTapSignIn(){
        let vc = AuthViewController()
        vc.completionHandler = {[weak self]success in
            DispatchQueue.main.async {
                self?.handelSignIn(success:success)
            }
        }
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        signInButton.frame = CGRect(x: 20,
                                    y: view.height-58-view.safeAreaInsets.bottom,
                                    width: view.width - 40,
                                    height: 50)
        imageView.frame = view.bounds
        overlayView.frame = view.bounds
        
        logoImageView.frame = CGRect(x: (view.width - 120) / 2, y: (view.height - 200 ) / 2, width: 120, height: 120)
        label.frame = CGRect(x: 30, y: logoImageView.bottom + 30, width: view.width - 60, height: 150)
    }

    private func handelSignIn(success:Bool){
        //log user in or yell at tehm for error
        
        guard success else {
            let alert = UIAlertController(title: "oops", message: "something went wrong when signin", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            return}
        
        let mainAppTabbarVc = TabBarViewController()
        mainAppTabbarVc.modalPresentationStyle = .fullScreen
        present(mainAppTabbarVc, animated: true, completion: nil)
    }

}
