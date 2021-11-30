//
//  ViewController.swift
//  spotify
//
//  Created by Bryan on 2021/11/25.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .done, target: self, action: #selector(didTapSetting))
        
        fetchDate()

    }
    
    private func fetchDate(){
        APICaller.shared.getRecommendedGenres { result in
            switch result{
            case .success(let model):
                var seeds = Set<String>()
                while seeds.count < 5 {
                    if let random = model.genres.randomElement(){
                        seeds.insert(random)
                    }
                    APICaller.shared.getRecommendations(genres: seeds) { result in
                        
                    }
              
                }
            case .failure(let error): break
            }
            
        }
    }
    
    @objc func didTapSetting(){
        let vc = SettingViewController()
        vc.title = "Setting"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }


}

