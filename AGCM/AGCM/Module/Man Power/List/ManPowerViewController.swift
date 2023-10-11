//
//  ManPowerViewController.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 22/01/23.
//

import UIKit
import ProgressHUD

class ManPowerViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: ManPowerListViewModel = ManPowerListViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        getManPowerList()
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
    
    @IBAction func addButtonAction(_ sender: UIBarButtonItem) {
        let addManPower_VC = AddManPowerViewController()
        addManPower_VC.viewModel.viewType = .add
        addManPower_VC.viewModel.dailyLogId = viewModel.dailyLogId
        addManPower_VC.viewModel.manPower.dailyLogId = viewModel.dailyLogId
        addManPower_VC.delegate = self
        self.navigationController?.pushViewController(addManPower_VC, animated: true)
    }
    
    @IBAction func dismissCloseButton(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getManPowerList() {
        ProgressHUD.show()
        viewModel.getManPowerDetails {[weak self] in
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


extension ManPowerViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ManPowerTableViewCell", for: indexPath)
        let model = viewModel.list[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.semibold)
        cell.textLabel?.text = model.title
        cell.detailTextLabel?.text = model.subTitle
        return cell
    }
}

extension ManPowerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.list[indexPath.row].subTitle.isEmpty ? 54 : 64
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = viewModel.list[indexPath.row]
        let viewManPower_VC = AddManPowerViewController()
        viewManPower_VC.viewModel.viewType = .view
        viewManPower_VC.viewModel.manPower = model.manPower
        viewManPower_VC.viewModel.dailyLogId = viewModel.dailyLogId
        viewManPower_VC.delegate = self
        self.navigationController?.pushViewController(viewManPower_VC, animated: true)
    }
}

extension ManPowerViewController: DataUpdateProtocol{
    func didDataUpdated() {
        self.getManPowerList()
    }
}
