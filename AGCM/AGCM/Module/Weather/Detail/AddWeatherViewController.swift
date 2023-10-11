//
//  AddWeatherViewController.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 29/01/23.
//

import UIKit
import Eureka
import ProgressHUD


class AddWeatherViewController: FormViewController {
    let viewModel: AddWeatherViewModel = AddWeatherViewModel()
    weak var delegate: DataUpdateProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()
        form
        +++ Section()
        <<< DecimalRow () {
            $0.title = "Temperature"
            $0.value = viewModel.weather.temperature
            $0.onChange {[weak self] row in
                self?.viewModel.weather.temperature = row.value ?? 0.0
            }
        }
        <<< PushRow<String>() {
            $0.title = "Weather"
            $0.options = ["Clear", "Dry", "Wet", "Cloudy"]
            $0.value = viewModel.weather.climate.capitalized
            $0.selectorTitle = "Weather"
            $0.onChange {[weak self] row in
                self?.viewModel.weather.climate = row.value?.lowercased() ?? "clear"
            }
        }.onPresent { from, to in
            to.dismissOnSelection = false
            to.dismissOnChange = true
        }
        <<< SwitchRow() {
            $0.title = "Rain"
            $0.value = viewModel.weather.rain
            $0.onChange {[weak self] row in
                self?.viewModel.weather.rain = row.value ?? false
            }
        }
        <<< DecimalRow () {
            $0.title = "Rain Fall In Inches"
            $0.value = viewModel.weather.rainFall
            $0.onChange {[weak self] row in
                self?.viewModel.weather.rainFall = row.value ?? 0.0
            }
        }
        self.updateViewType()
    }
    
   @objc func dismissCloseButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func saveButton() {
        ProgressHUD.show()
        viewModel.updateWeatherChanges {[weak self] in
            ProgressHUD.showSucceed()
            self?.updateWeatherInfo()
        } onError: { isInternetError in
            if isInternetError {
                ProgressHUD.showError("No Internet connection")
            } else {
                ProgressHUD.showError("Something went wrong, please try again.")
            }
        }
    }
    
    private func updateWeatherInfo() {
        self.navigationController?.popViewController(animated: true)
        self.delegate?.didDataUpdated()
    }
    
    private func updateViewType() {
        let allowEdit = viewModel.viewType != .view
        for row in form.allRows {
            if let row = row as? OdooAttachmentRow {
                row.baseCell.isUserInteractionEnabled = true
            } else if let row = row as? TextAreaRow {
                row.baseCell.isUserInteractionEnabled = true
                row.textAreaMode = viewModel.viewType == .view ? .readOnly : .normal
            }else {
                row.baseCell.isUserInteractionEnabled = allowEdit
            }
        }
        self.updateTitle()
    }
    
    @objc func editButton() {
        self.viewModel.viewType = .edit
        self.updateViewType()
        self.tableView.reloadData()
    }
    
    private func updateTitle() {
        if viewModel.viewType == .edit{
            self.title = "Edit Weather"
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItem.Style.plain, target: self, action: #selector(saveButton))
        } else if viewModel.viewType == .add{
            self.title = "Add Weather"
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItem.Style.plain, target: self, action: #selector(saveButton))
        } else {
            self.title = ""
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItem.Style.plain, target: self, action: #selector(editButton))
        }
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(dismissCloseButton))
    }
}

