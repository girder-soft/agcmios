//
//  ProjectDetailViewController.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 28/01/23.
//

import UIKit
import ProgressHUD

class ProjectDetailViewController: UIViewController {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var projectNameLabel: UILabel!
    @IBOutlet weak var tradeNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: ProjectDetailViewModel = ProjectDetailViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTopView()
        setupTableView()
        setProjectInfo()
        getProjectDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    private func setUpTopView() {
        topView.layer.cornerRadius = 16
        topView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }
    
    private func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    private func setProjectInfo() {
        self.projectNameLabel.text = viewModel.projectModel.title
        self.tradeNameLabel.text = viewModel.projectModel.subTitle
    }
    
    @IBAction func backButtonAction(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func copyButtonAction(_ sender: UIBarButtonItem) {
        let copyVC = CopyDailyLogViewController()
        copyVC.viewModel.dailyLogs = viewModel.projectDetail.dailyLogs
        copyVC.updateDelegate = self
        self.navigationController?.pushViewController(copyVC, animated: true)
    }
    
    @IBAction func addButtonAction(_ sender: UIBarButtonItem) {
        let addDailyLogVC = AddDailyLogViewController()
        addDailyLogVC.viewModel.project = viewModel.projectModel.project
        addDailyLogVC.delegate = self
        self.navigationController?.pushViewController(addDailyLogVC, animated: true)
    }
    
    func getProjectDetail() {
        ProgressHUD.show()
        viewModel.getProjectDetail {[weak self] in
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

extension ProjectDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DailyLogTableViewCell", for: indexPath)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.semibold)
        let model = viewModel.list[indexPath.row]
        cell.textLabel?.text = model.date
        cell.detailTextLabel?.text = "Created By: " + model.createdBy.name
        return cell
    }
}

extension ProjectDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let dailyLog_VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "DashboardViewController") as? DashboardViewController {
            dailyLog_VC.viewModel.dailyLogItem = viewModel.projectDetail.dailyLogs[indexPath.row]
            dailyLog_VC.viewModel.project = viewModel.projectModel.project
            self.navigationController?.pushViewController(dailyLog_VC, animated: true)
        }
    }
}


extension ProjectDetailViewController : DataUpdateProtocol {
    func didDataUpdated() {
        self.getProjectDetail()
    }
}
