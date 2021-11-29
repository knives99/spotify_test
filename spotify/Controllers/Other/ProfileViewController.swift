//
//  ProfileViewController.swift
//  spotify
//
//  Created by Bryan on 2021/11/25.
//

import UIKit
import SDWebImage

class ProfileViewController: UITabBarController, UITableViewDelegate,UITableViewDataSource {
    
    private let tableView : UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private var models = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        fetchProfile()
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func fetchProfile(){
        APICaller.shared.getCurrentUserProfile { [weak self]result in
            DispatchQueue.main.async {

                switch result{
                case .success(let model):
                    self?.updateUI(with: model)
                case .failure(let error):
                    self?.failedToGetProfile()
                    print(error.localizedDescription)
                }

            }
        }
    }
    
    private func updateUI(with model:UserProfile){
        tableView.isHidden = false
        //configure table models
        models.append("Full Name:\(model.display_name)")
        models.append("User ID : \(model.id)")
        models.append("plan:\(model.product)")
        createTableViewHeader(with: model.images.first?.url)
        tableView.reloadData()
        
    }
    
    private func createTableViewHeader(with string:String?){
        guard let urlString = string, let url = URL(string: urlString) else {return}
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: view.width * 1.2))
        let imageSize = headerView.height / 2
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: imageSize, height: imageSize))
        imageView.center = headerView.center
        imageView.contentMode = .scaleAspectFill
        imageView.sd_setImage(with: url, completed: nil)
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageSize / 2
        tableView.addSubview( imageView)
        tableView.tableHeaderView = headerView
        
        
    }
    
    private func failedToGetProfile(){
        let label = UILabel(frame: .zero)
        label.text = "Failed to load profile"
        label.sizeToFit()
        label.textColor = .secondaryLabel
        view.addSubview(label)
        label.center = view.center
    }
    
    //MARK: - Table View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        models.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text  = models[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }

}
