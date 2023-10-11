//
//  ThirdPartyListViewController.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 24/01/23.
//

import UIKit
import ProgressHUD

class ThirdPartyListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: ThirdPartyListViewModel = ThirdPartyListViewModel()
    var updateData: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        getObservationDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if updateData {
            self.updateData = false
            self.getObservationDetail()
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
    
    func getObservationDetail() {
        ProgressHUD.show()
        viewModel.getObservationDetail {[weak self] in
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

extension ThirdPartyListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ThirdPartyListCell", for: indexPath)
        let model = viewModel.list[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.semibold)
        cell.textLabel?.text = model.title
        return cell
    }
}

extension ThirdPartyListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viewModel.observationDetail != nil {
            let model = viewModel.list[indexPath.row]
            if model.type == .safetyObservation {
                let observation_SB = UIStoryboard(name: "Observation", bundle: nil)
                let safety_VC = observation_SB.instantiateViewController(withIdentifier: "SafetyViolationsListViewController") as! SafetyViolationsListViewController
                safety_VC.viewModel.dailyLogId = viewModel.observationDetail.dailyLogId
                safety_VC.updateDelegate = self
                self.navigationController?.pushViewController(safety_VC, animated: true)
            } else if model.type == .visitor {
                let observation_SB = UIStoryboard(name: "Observation", bundle: nil)
                let visitor_VC = observation_SB.instantiateViewController(withIdentifier: "VisitorListViewController") as! VisitorListViewController
                visitor_VC.viewModel.dailyLogId = viewModel.observationDetail.dailyLogId
                visitor_VC.updateDelegate = self
                self.navigationController?.pushViewController(visitor_VC, animated: true)
            } else if model.type == .delay {
                let observation_SB = UIStoryboard(name: "Observation", bundle: nil)
                let delay_VC = observation_SB.instantiateViewController(withIdentifier: "DelayListViewController") as! DelayListViewController
                delay_VC.viewModel.dailyLogId = viewModel.observationDetail.dailyLogId
                delay_VC.updateDelegate = self
                self.navigationController?.pushViewController(delay_VC, animated: true)
            }
        }
    }
}

extension ThirdPartyListViewController: DataUpdateProtocol {
    func didDataUpdated() {
        self.updateData = true
    }
}
