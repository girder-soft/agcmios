//
//  DashboardViewController.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 19/01/23.
//

import UIKit
import ProgressHUD

class DashboardViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var shouldRefreshDetail: Bool = true
    
    var viewModel: DashboardViewModel = DashboardViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if shouldRefreshDetail {
            self.getDailyLogDetail()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    private func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    @IBAction func backButtonAction(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func shareButtonAction(_ sender: UIBarButtonItem) {
        let report_VC = ReportViewController()
        report_VC.viewModel.dailyLogId = viewModel.dailyLogItem.id
        self.navigationController?.pushViewController(report_VC, animated: true)
    }
    
    func getDailyLogDetail() {
        self.shouldRefreshDetail = false
        ProgressHUD.show()
        viewModel.getDailyLogDetail {[weak self] in
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
    
}

extension DashboardViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardTableViewCell", for: indexPath) 
        let model = viewModel.list[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.semibold)
        cell.textLabel?.text = model.displayTitle
        cell.detailTextLabel?.text = model.subTitle
        return cell
    }    
}

extension DashboardViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = viewModel.list[indexPath.row]
        return model.subTitle != "" ? 64 : 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = viewModel.list[indexPath.row]
        if model.type == .manPower {
            let manPower_SB = UIStoryboard(name: "ManPower", bundle: nil)
            let manPower_VC = manPower_SB.instantiateViewController(withIdentifier: "ManPowerViewController") as! ManPowerViewController
            manPower_VC.viewModel.dailyLogId = viewModel.dailyLogDetail.id
            self.navigationController?.pushViewController(manPower_VC, animated: true)
        } else if model.type == .thirdPartyObservation {
            let observation_SB = UIStoryboard(name: "Observation", bundle: nil)
            let observation_VC = observation_SB.instantiateViewController(withIdentifier: "ObservationListViewController") as! ObservationListViewController
            observation_VC.viewModel.dailyLogId = viewModel.dailyLogDetail.id
            observation_VC.dailyLogDelegate = self
            self.navigationController?.pushViewController(observation_VC, animated: true)
        } else if model.type == .weather {
            let weather_SB = UIStoryboard(name: "Weather", bundle: nil)
            let weather_VC = weather_SB.instantiateViewController(withIdentifier: "WeatherViewController") as! WeatherViewController
            weather_VC.viewModel.dailyLogId = viewModel.dailyLogDetail.id
            weather_VC.viewModel.project = viewModel.project
            weather_VC.dailyLogDelegate = self
            self.navigationController?.pushViewController(weather_VC, animated: true)
        } else if model.type == .inspection {
            let inspection_SB = UIStoryboard(name: "Inspection", bundle: nil)
            let inspection_VC = inspection_SB.instantiateViewController(withIdentifier: "InspectionListViewController") as! InspectionListViewController
            inspection_VC.viewModel.dailyLogId = viewModel.dailyLogDetail.id
            inspection_VC.dailyLogDelegate = self
            self.navigationController?.pushViewController(inspection_VC, animated: true)
        } else if model.type == .photo {
            let photo_SB = UIStoryboard(name: "Photos", bundle: nil)
            let photo_VC = photo_SB.instantiateViewController(withIdentifier: "PhotosViewController") as! PhotosViewController
            photo_VC.viewModel.dailyLogId = viewModel.dailyLogDetail.id
            photo_VC.dailyLogDelegate = self
            self.navigationController?.pushViewController(photo_VC, animated: true)
        } else if model.type == .safety {
            let observation_SB = UIStoryboard(name: "Observation", bundle: nil)
            let safety_VC = observation_SB.instantiateViewController(withIdentifier: "SafetyViolationsListViewController") as! SafetyViolationsListViewController
            safety_VC.viewModel.dailyLogId = viewModel.dailyLogDetail.id
            safety_VC.updateDelegate = self
            self.navigationController?.pushViewController(safety_VC, animated: true)
        } else if model.type == .visitor {
            let observation_SB = UIStoryboard(name: "Observation", bundle: nil)
            let visitor_VC = observation_SB.instantiateViewController(withIdentifier: "VisitorListViewController") as! VisitorListViewController
            visitor_VC.viewModel.dailyLogId = viewModel.dailyLogDetail.id
            visitor_VC.updateDelegate = self
            self.navigationController?.pushViewController(visitor_VC, animated: true)
        } else if model.type == .delay {
            let observation_SB = UIStoryboard(name: "Observation", bundle: nil)
            let delay_VC = observation_SB.instantiateViewController(withIdentifier: "DelayListViewController") as! DelayListViewController
            delay_VC.viewModel.dailyLogId = viewModel.dailyLogDetail.id
            delay_VC.updateDelegate = self
            self.navigationController?.pushViewController(delay_VC, animated: true)
        }
    }
}

extension DashboardViewController: DataUpdateProtocol {
    
    func didDataUpdated() {
        self.shouldRefreshDetail = true
    }
}
