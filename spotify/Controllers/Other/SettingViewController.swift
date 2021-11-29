//
//  SettingViewController.swift
//  spotify
//
//  Created by Bryan on 2021/11/25.
//

import UIKit

class SettingViewController: UITabBarController, UITableViewDelegate,UITableViewDataSource {
    
    private let tableView:UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private var sections = [Section]()

    override func viewDidLoad() {
        super.viewDidLoad()
        sections.append(Section(title: "Profile", options: [option(title: "View Your Profile", handler: {[weak self] in
            DispatchQueue.main.async {
                self?.viewProfile()
            }
                
        })]))
        sections.append(Section(title: "Account", options: [option(title: "Sign out", handler: {[weak self] in
            DispatchQueue.main.async {
                self?.signOutTapped()
            }
        })]))
        
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)

    }
    
    private func signOutTapped(){}
    
    private func viewProfile(){
        let vc = ProfileViewController()
        vc.title = "Profile"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
//MARK: -  TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = sections[indexPath.section].options[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = sections[indexPath.section].options[indexPath.row]
        model.handler()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let model = sections[section]
        return model.title
    }
}
