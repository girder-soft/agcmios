//
//  ObservationListViewController.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 30/01/23.
//

import UIKit
import ProgressHUD

class ObservationListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: ObservationListViewModel = ObservationListViewModel()
    weak var dailyLogDelegate: DataUpdateProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        self.getObservations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        let observation_VC = AddObservationViewController()
        observation_VC.viewModel.viewType = .add
        observation_VC.viewModel.dailyLogId = viewModel.dailyLogId
        observation_VC.dataUpdateDelegate = self
        self.navigationController?.pushViewController(observation_VC, animated: true)
    }
    
    func getObservations() {
        ProgressHUD.show()
        viewModel.getObservationList {[weak self] in
            ProgressHUD.dismiss()
            guard let weakSelf = self else { return}
            weakSelf.tableView.reloadData()
        } onError: { isInternetError in
            if isInternetError {
                ProgressHUD.showError("No Internet connection")
            } else {
                ProgressHUD.showError("Something went wrong, please try again.")
            }
        }
    }
    
}

extension ObservationListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ObservationListCell", for: indexPath)
        let model = viewModel.list[indexPath.row]
        cell.textLabel?.text = model.name
        cell.detailTextLabel?.text = model.comments
        return cell
    }
}

extension ObservationListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let observation_VC = AddObservationViewController()
        observation_VC.viewModel.viewType = .view
        observation_VC.viewModel.dailyLogId = viewModel.dailyLogId
        observation_VC.viewModel.observation = viewModel.list[indexPath.row]
        observation_VC.dataUpdateDelegate = self
        self.navigationController?.pushViewController(observation_VC, animated: true)
    }
}

extension ObservationListViewController: DataUpdateProtocol {
    func didDataUpdated() {
        self.getObservations()
        self.dailyLogDelegate?.didDataUpdated()
    }
}
