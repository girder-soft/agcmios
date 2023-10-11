//
//  CopyDailyLogViewController.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 01/02/23.
//

import UIKit
import Eureka
import ProgressHUD

class CopyDailyLogViewController: FormViewController {

    let viewModel: CopyDailyLogViewModel = CopyDailyLogViewModel()
    weak var updateDelegate: DataUpdateProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()
        updateNavigationButton()
        LabelRow.defaultCellUpdate = { cell, row in
            cell.textLabel?.textColor = .red
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            cell.textLabel?.textAlignment = .left
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        form
        +++ Section()
        <<< OdooCreateAndSelectRow() {
            $0.title = "From"
            $0.selectorTitle = "Select Daily Log"
            $0.add(rule: RuleRequired(msg: "Please select daily log"))
            $0.options = viewModel.dailyLogs.map{$0.createSelect}
            $0.onChange {[weak self] row in
                if let model = row.value {
                    self?.viewModel.updateSelectedDailyLog(id: model.id)
                }
            }
        }.onRowValidationChanged { cell, row in
            let rowIndex = row.indexPath!.row
            while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                row.section?.remove(at: rowIndex + 1)
            }
            if !row.isValid {
                for (index, validationMsg) in row.validationErrors.map({ $0.msg }).enumerated() {
                    let labelRow = LabelRow() {
                        $0.title = validationMsg
                        $0.cell.height = { 24 }
                    }
                    let indexPath = row.indexPath!.row + index + 1
                    row.section?.insert(labelRow, at: indexPath)
                }
            }
        }
        <<< DateRow() {
            $0.title = "To"
            $0.value = viewModel.toDate
            $0.maximumDate = Date()
            $0.onChange {[weak self] row in
                self?.viewModel.toDate = row.value ?? Date()
            }
        }
        
        <<< MultipleSelectorRow<String>() {
            $0.title = "Modules"
            $0.options = viewModel.moduleOptions
            $0.selectorTitle = "Modules"
            $0.add(rule: RuleRequired(msg: "Please select modules"))
            $0.onChange {[weak self] row in
                if let options = row.value {
                    self?.viewModel.selectedOptions = Array(options)
                }
            }
        }.onPresent { from, to in
            to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: from, action: #selector(CopyDailyLogViewController.dismissCloseButton))
        }.onRowValidationChanged { cell, row in
            let rowIndex = row.indexPath!.row
            while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                row.section?.remove(at: rowIndex + 1)
            }
            if !row.isValid {
                for (index, validationMsg) in row.validationErrors.map({ $0.msg }).enumerated() {
                    let labelRow = LabelRow() {
                        $0.title = validationMsg
                        $0.cell.height = { 24 }
                    }
                    let indexPath = row.indexPath!.row + index + 1
                    row.section?.insert(labelRow, at: indexPath)
                }
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
            viewModel.copyDailyLog { [weak self] in
                ProgressHUD.showSucceed()
                self?.updateDelegate?.didDataUpdated()
                self?.dismissCloseButton()
            } onError: { isInternetError in
                if isInternetError {
                    ProgressHUD.showError("No Internet connection")
                } else {
                    ProgressHUD.showError("Something went wrong, please try again.")
                }
            }
        }
    }
    
    private func updateNavigationButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItem.Style.plain, target: self, action: #selector(saveButton))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(dismissCloseButton))
        self.title = "Copy Daily log"
    }
}


class CopyDailyLogViewModel {
    
    var dailyLogs: [DailyLogItem] = []
    var toDate: Date = Date()
    var selectedOptions: [String] = []
    var moduleOptions: [String] {
        return ([.manPower, .thirdPartyObservation, .safety, .delay, .inspection] as [DashboardListType]).map{$0.title}
    }
    var selectedDailyLog: DailyLogItem!
    
    private let apiService = ProjectAPI()
    
    func updateSelectedDailyLog(id: Int) {
        if let selectedLog = self.dailyLogs.first(where: {$0.id == id}) {
            self.selectedDailyLog = selectedLog
        }
    }
    
    private func createCopyDailyLogParam() -> CopyDailyLog {
        return CopyDailyLog(kwargs: CopyDailyLog.DailyLogContext(context: CopyDailyLog.DailyLogContext.DailyLogParam(date: toDate.getOdooServerDate(format: "YYYY-MM-dd"), manpower: isModuleSelected(type: .manPower),  observation: isModuleSelected(type: .thirdPartyObservation), inspection: isModuleSelected(type: .inspection), delay: isModuleSelected(type: .delay), safety: isModuleSelected(type: .safety))))
    }
    
    private func isModuleSelected(type: DashboardListType) -> Bool {
        return self.selectedOptions.contains(type.title)
    }
    
    func copyDailyLog(onSuccess: @escaping() -> (), onError: @escaping(Bool) -> ()) {
        let copyDailylogParam = createCopyDailyLogParam()
        apiService.copyDailyLog(dailyLogId: selectedDailyLog.id, copyDailyLog: copyDailylogParam) { response in
            switch response.result {
            case .success(let result):
                if result.result {
                    onSuccess()
                } else {
                    onError(false)
                }
            case .failure(let error):
                onError(error.isSessionTaskError)
            }
        }
    }
}
