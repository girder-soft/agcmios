//
//  AddDailyLogViewController.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 02/02/23.
//

import UIKit
import Eureka
import ProgressHUD

class AddDailyLogViewController: FormViewController {
    
    let viewModel : AddDailyLogViewModel = AddDailyLogViewModel()
    
    weak var delegate: DataUpdateProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        updateNavigationButton()
        form
        +++ Section()
        
        <<< DateRow() {
            $0.title = "To"
            $0.value = viewModel.selectedDate
            $0.maximumDate = Date()
            $0.onChange {[weak self] row in
                self?.viewModel.selectedDate = row.value ?? Date()
            }
        }
    }
    
    @objc func dismissCloseButton() {
         self.navigationController?.popViewController(animated: true)
     }
    
    @objc func saveButton() {
        let validationError = form.validate()
        if validationError.count == 0 {
            ProgressHUD.show()
            viewModel.createDailyLog {[weak self] in
                ProgressHUD.showSucceed()
                self?.updateForecastForSelectedDate()
            } onError: { isInternetError in
                if isInternetError {
                    ProgressHUD.showError("No Internet connection")
                } else {
                    ProgressHUD.showError("Something went wrong, please try again.")
                }
            }
        }
    }
    
    private func updateForecastForSelectedDate() {
        ProgressHUD.show()
        viewModel.updateWeatherForecast { [weak self] in
            ProgressHUD.showSucceed()
            self?.delegate?.didDataUpdated()
            self?.dismissCloseButton()
        }
    }
    
    private func updateNavigationButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItem.Style.plain, target: self, action: #selector(saveButton))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(dismissCloseButton))
        self.title = "Add Daily log"
    }
}

class AddDailyLogViewModel {
    var project: Project!
    var selectedDate: Date = Date()
    var forecastUpdater: WeatherForecastUpdater!
    private let apiService = ProjectAPI()
    
    func createDailyLog(onSuccess: @escaping() -> (), onError: @escaping(Bool) -> ()) {
        
        let dailyLog = DailyLogCreate(project_id: project.id, date: selectedDate.getOdooServerDate(format: "YYYY-MM-dd"))
        apiService.createDailyLog(dailyLog: dailyLog) { response in
            switch response.result {
            case .success(let result):
                if result.result != 0 {
                    onSuccess()
                } else {
                    onError(false)
                }
            case .failure(let error):
                onError(error.isSessionTaskError)
            }
        }
    }
    
    func updateWeatherForecast(onCompletion: @escaping()->()) {
        forecastUpdater = WeatherForecastUpdater()
        forecastUpdater.updateWeatherForecast(projectId: project.id, date: selectedDate.getOdooDisplayDate(format: "YYYY-MM-dd"), lat: project.latitude, long: project.longitude) { _ in
            onCompletion()
        }
    }
}

struct DailyLogCreate: Encodable {
    let project_id: Int
    let date: String
}
