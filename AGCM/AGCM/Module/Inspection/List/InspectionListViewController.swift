//
//  InspectionListViewController.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 24/01/23.
//

import UIKit
import ProgressHUD

class InspectionListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: InspectionListViewModel = InspectionListViewModel()
    weak var dailyLogDelegate: DataUpdateProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        self.getInspections()
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
        let inspection_VC = InspectionDetailViewController()
        inspection_VC.viewModel.viewType = .add
        inspection_VC.viewModel.dailyLogId = viewModel.dailyLogId
        inspection_VC.viewModel.inspection.dailyLogId = viewModel.dailyLogId
        inspection_VC.delegate = self
        self.navigationController?.pushViewController(inspection_VC, animated: true)
    }
    
    func getInspections() {
        ProgressHUD.show()
        viewModel.getInspections {[weak self] in
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

extension InspectionListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InspectionListCell", for: indexPath)
        let model = viewModel.list[indexPath.row]
        cell.textLabel?.text = model.title
        cell.detailTextLabel?.numberOfLines = 3
        cell.detailTextLabel?.text = model.subTitle
        return cell
    }
}

extension InspectionListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = viewModel.list[indexPath.row]
        let inspection_VC = InspectionDetailViewController()
        inspection_VC.viewModel.viewType = .view
        inspection_VC.viewModel.inspection = model.inspection
        inspection_VC.viewModel.dailyLogId = viewModel.dailyLogId
        inspection_VC.delegate = self
        self.navigationController?.pushViewController(inspection_VC, animated: true)
    }
}

extension InspectionListViewController: DataUpdateProtocol {
    func didDataUpdated() {
        self.getInspections()
        self.dailyLogDelegate?.didDataUpdated()
    }
}
