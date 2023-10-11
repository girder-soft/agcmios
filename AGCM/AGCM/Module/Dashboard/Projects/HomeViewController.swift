//
//  HomeViewController.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 26/01/23.
//

import UIKit
import ProgressHUD

class HomeViewController: UIViewController {
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cornerView: UIView!
    @IBOutlet weak var avatarNameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    let viewModel:HomeViewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpTopView()
        self.setupTableView()
        self.setUserDetail()
        self.updateUserInfo()
        self.getProjectList()
    }
    
    private func setUpTopView() {
        cornerView.layer.cornerRadius = 16
        cornerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    private func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    private func setUserDetail() {
        self.emailLabel.text = viewModel.email
        self.nameLabel.text = viewModel.name
        self.avatarNameLabel.text = viewModel.name.prefix(1).uppercased()
    }
    
    private func getProjectList() {
        ProgressHUD.show()
        viewModel.getProjectList {[weak self] in
            ProgressHUD.dismiss()
            self?.tableView.reloadData()
        } onError: { isInternetError in
            if isInternetError {
                ProgressHUD.showError("No Internet connection")
            } else {
                ProgressHUD.showError("Something went wrong, please try again.")
            }
        }
    }
    
    private func updateUserInfo() {
        viewModel.updateUserInfo {[weak self] in
            self?.setUserDetail()
        }
    }
    
    @IBAction func logoutButtonAction(_ sender: UIBarButtonItem) {
        UserDefaultsManager.shared.resetUser()
        if let window = UIApplication.shared.window {
            let login_VC = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()
            window.rootViewController = login_VC
            window.makeKeyAndVisible()
        }
    }
}

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectListCell", for: indexPath)
        let model = viewModel.list[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        cell.textLabel?.text = model.title
        cell.detailTextLabel?.text = model.subTitle
        return cell
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.list[indexPath.row].subTitle.isEmpty ? 54 : 64
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = viewModel.list[indexPath.row]
        if let projectDetail_VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ProjectDetailViewController") as? ProjectDetailViewController {
            projectDetail_VC.viewModel.projectModel = model
            self.navigationController?.pushViewController(projectDetail_VC, animated: true)
        }
    }    
}

