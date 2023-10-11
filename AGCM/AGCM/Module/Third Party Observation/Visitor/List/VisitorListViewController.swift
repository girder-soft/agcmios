//
//  VisitorListViewController.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 24/01/23.
//

import UIKit
import ProgressHUD

class VisitorListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: VisitorListViewModel = VisitorListViewModel()
    weak var updateDelegate: DataUpdateProtocol?
    var updateData: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        getVisitors()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if updateData {
            self.getVisitors()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    private func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    @IBAction func dismissCloseButton(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addButtonAction(_ sender: UIBarButtonItem) {
        let violation_VC = VisitorDetailViewController()
        violation_VC.viewModel.viewType = .add
        violation_VC.viewModel.dailyLogId = viewModel.dailyLogId
        violation_VC.dataUpdateDelegate = self
        self.navigationController?.pushViewController(violation_VC, animated: true)
    }
    
    func getVisitors() {
        ProgressHUD.show()
        viewModel.getVisitorList {[weak self] in
            ProgressHUD.dismiss()
            guard let weakSelf = self else { return}
            weakSelf.tableView.reloadData()
            if weakSelf.updateData {
                weakSelf.updateData = false
                weakSelf.updateDelegate?.didDataUpdated()
            }
        } onError: { isInternetError in
            if isInternetError {
                ProgressHUD.showError("No Internet connection")
            } else {
                ProgressHUD.showError("Something went wrong, please try again.")
            }
        }
    }

}

extension VisitorListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VisitorListCell", for: indexPath)
        let model = viewModel.list[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)
        cell.textLabel?.text = model.title
        cell.detailTextLabel?.text = model.subTitle
        cell.detailTextLabel?.numberOfLines = 3

        return cell
    }
}

extension VisitorListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = viewModel.list[indexPath.row]
        let violation_VC = VisitorDetailViewController()
        violation_VC.viewModel.viewType = .view
        violation_VC.viewModel.visitor = model.visitor
        violation_VC.viewModel.dailyLogId = viewModel.dailyLogId
        violation_VC.dataUpdateDelegate = self
        self.navigationController?.pushViewController(violation_VC, animated: true)
    }
}

extension VisitorListViewController: DataUpdateProtocol {
    func didDataUpdated() {
        self.updateData = true
    }
}
