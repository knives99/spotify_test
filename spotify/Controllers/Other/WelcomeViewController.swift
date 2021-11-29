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
        button.setTitleColor(.blue, for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Spotify"
        view.backgroundColor = .systemGreen
        view.addSubview(signInButton)
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
