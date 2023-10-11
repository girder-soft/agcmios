//
//  WeatherViewController.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 24/01/23.
//

import UIKit
import ProgressHUD

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: WeatherViewModel = WeatherViewModel()
    weak var dailyLogDelegate: DataUpdateProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        getWeathers()
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
        let addWeather_VC = AddWeatherViewController()
        addWeather_VC.viewModel.viewType = .add
        addWeather_VC.viewModel.dailyLogId = viewModel.dailyLogId
        addWeather_VC.viewModel.weather.dailyLogId = viewModel.dailyLogId
        addWeather_VC.delegate = self
        self.navigationController?.pushViewController(addWeather_VC, animated: true)
    }
    
    @IBAction func dismissCloseButton(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }

    func getWeathers() {
        ProgressHUD.show()
        viewModel.getWeathers {[weak self] in
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

extension WeatherViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = viewModel.list[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell" , for: indexPath)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.semibold)
        cell.textLabel?.text = model.title
        cell.detailTextLabel?.text = model.subTitle
        return cell
    }
}

extension WeatherViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let weatherModel = viewModel.list[indexPath.row]
        let viewWeather_VC = AddWeatherViewController()
        viewWeather_VC.viewModel.viewType = .view
        viewWeather_VC.viewModel.dailyLogId = viewModel.dailyLogId
        viewWeather_VC.viewModel.weather = weatherModel.weather
        viewWeather_VC.delegate = self
        self.navigationController?.pushViewController(viewWeather_VC, animated: true)
    }
}

extension WeatherViewController: DataUpdateProtocol {
    func didDataUpdated() {
        self.getWeathers()
        self.dailyLogDelegate?.didDataUpdated()
    }
}
