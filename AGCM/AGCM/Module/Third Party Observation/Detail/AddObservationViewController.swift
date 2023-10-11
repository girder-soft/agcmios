//
//  AddObservationViewController.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 13/02/23.
//

import UIKit
import Eureka
import ProgressHUD

class AddObservationViewController: FormViewController {
    let viewModel: ObservationDetailViewModel = ObservationDetailViewModel()
    weak var dataUpdateDelegate: DataUpdateProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()
        LabelRow.defaultCellUpdate = { cell, row in
            cell.textLabel?.textColor = .red
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            cell.textLabel?.textAlignment = .left
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        form
        +++ Section()
        <<< TextRow() {
            $0.title = "Notes"
            $0.add(rule: RuleRequired(msg: "Enter notes"))
            $0.value = viewModel.observation.name
            $0.onChange {[weak self] row in
                self?.viewModel.observation.name = row.value ?? ""
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
        
        <<< TextAreaRow() {
            $0.title = "Description"
            $0.placeholder = "Description"
            $0.add(rule: RuleRequired(msg: "Enter description"))
            $0.value = viewModel.observation.comments
            $0.onChange {[weak self] row in
                self?.viewModel.observation.comments = row.value ?? ""
            }
            $0.textAreaHeight = .dynamic(initialTextViewHeight: 80)
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
        
        +++ Section()
        <<< OdooAttachmentRow() {
            $0.title = "Attachments"
            $0.resModel = "notes"
            $0.resId = viewModel.observation.id
            $0.hidden = viewModel.viewType == .add ? true : false
        }
        self.updateViewType()
    }
    
   @objc func dismissCloseButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @objc func saveButton() {
        let validationError = form.validate()
        if validationError.count == 0 {
            ProgressHUD.show()
            viewModel.updateObservationChanges {[weak self] in
                ProgressHUD.showSucceed()
                self?.updateNotes()
            } onError: { isInternetError in
                if isInternetError {
                    ProgressHUD.showError("No Internet connection")
                } else {
                    ProgressHUD.showError("Something went wrong, please try again.")
                }
            }
        }
    }
    
    @objc func editButton() {
        self.viewModel.viewType = .edit
        self.updateViewType()
        self.tableView.reloadData()
    }
    
    private func updateNotes() {
        self.navigationController?.popViewController(animated: true)
        self.dataUpdateDelegate?.didDataUpdated()
    }
    
    private func updateViewType() {
        let allowEdit = viewModel.viewType != .view
        for row in form.allRows {
            if let row = row as? OdooAttachmentRow {
                row.baseCell.isUserInteractionEnabled = true
            } else if let row = row as? TextAreaRow {
                row.baseCell.isUserInteractionEnabled = true
                row.textAreaMode = viewModel.viewType == .view ? .readOnly : .normal
            } else {
                row.baseCell.isUserInteractionEnabled = allowEdit
            }
        }
        self.updateTitle()
    }
    
    private func updateTitle() {
        if viewModel.viewType == .edit{
            self.title = "Edit Notes"
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItem.Style.plain, target: self, action: #selector(saveButton))
        } else if viewModel.viewType == .add{
            self.title = "Add Notes"
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItem.Style.plain, target: self, action: #selector(saveButton))
        } else {
            self.title = ""
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItem.Style.plain, target: self, action: #selector(editButton))
        }
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(dismissCloseButton))
    }
}

class ObservationDetailViewModel {
    var viewType: ViewType = .add
    var observation: Observation = Observation()
    var dailyLogId: Int = 0
    private let apiService = ObservationAPI()
    func updateObservationChanges(onSuccess: @escaping() -> (), onError: @escaping(Bool) -> ()) {
        observation.dailyLogId = dailyLogId
        if viewType == .add {
            apiService.createObservation(observation:observation) { response in
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
        } else if viewType == .edit {
            apiService.updateObservation(observation:observation) { response in
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
}
