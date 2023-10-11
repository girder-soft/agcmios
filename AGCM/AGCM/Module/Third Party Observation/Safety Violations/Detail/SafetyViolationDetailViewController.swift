//
//  SafetyViolationDetailViewController.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 24/01/23.
//

import UIKit
import Eureka
import ProgressHUD

class SafetyViolationDetailViewController: FormViewController {
    let viewModel: SafetyViolationDetailViewModel = SafetyViolationDetailViewModel()
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
        <<< OdooCreateAndSelectRow() {
            $0.title = "Observation Type"
            $0.add(rule: RuleRequired(msg: "Please select observation type"))
            $0.value = viewModel.safety.type.id != 0 ? viewModel.safety.type : nil
            $0.selectorTitle = "Select Observation Type"
            $0.modelName = "violation.type"
            $0.canAddOption = true
            $0.onChange {[weak self] row in
                if let model = row.value {
                    self?.viewModel.safety.type = model
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
        
        <<< TextAreaRow() {
            $0.title = "Description"
            $0.placeholder = "Description"
            $0.add(rule: RuleRequired(msg: "Enter description"))
            $0.value = viewModel.safety.name
            $0.onChange {[weak self] row in
                self?.viewModel.safety.name = row.value ?? ""
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
        
        <<< TextAreaRow() {
            $0.title = "Observation Notice"
            $0.placeholder = "Observation Notice"
            $0.add(rule: RuleRequired(msg: "Enter observation notice"))
            $0.value = viewModel.safety.comment
            $0.onChange {[weak self] row in
                self?.viewModel.safety.comment = row.value ?? ""
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
        
        <<< OdooCreateAndSelectRow() {
            $0.title = "Notice To"
            $0.value = viewModel.safety.partner.id != 0 ? viewModel.safety.partner : nil
            $0.add(rule: RuleRequired(msg: "Please select contractor"))
            $0.selectorTitle = "Select Contractor"
            $0.modelName = "res.partner"
            $0.canAddOption = true
            $0.onChange {[weak self] row in
                if let model = row.value {
                    self?.viewModel.safety.partner = model
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
        
        <<< OdooCreateAndSelectRow() {
            $0.title = "Created By"
            $0.value = viewModel.safety.user.id != 0 ? viewModel.safety.user : nil
            $0.add(rule: RuleRequired(msg: "Please select created by"))
            $0.selectorTitle = "Select User"
            $0.modelName = "res.users"
            $0.onChange {[weak self] row in
                if let model = row.value {
                    self?.viewModel.safety.user = model
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
        
        +++ Section()
        <<< OdooAttachmentRow() {
            $0.title = "Attachments"
            $0.resModel = "safety.violations"
            $0.resId = viewModel.safety.id
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
            viewModel.updateSafetyChanges {[weak self] in
                ProgressHUD.showSucceed()
                self?.updateSafetyInfo()
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
    
    private func updateSafetyInfo() {
        self.navigationController?.popViewController(animated: true)
        self.dataUpdateDelegate?.didDataUpdated()
    }
    
    private func updateViewType() {
        let allowEdit = viewModel.viewType != .view
        for row in form.allRows {
            if let row = row as? OdooAttachmentRow {
                row.baseCell.isUserInteractionEnabled = true
            }else if let row = row as? TextAreaRow {
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
            self.title = "Edit Safety Observation"
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItem.Style.plain, target: self, action: #selector(saveButton))
        } else if viewModel.viewType == .add{
            self.title = "Add Safety Observation"
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItem.Style.plain, target: self, action: #selector(saveButton))
        } else {
            self.title = ""
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItem.Style.plain, target: self, action: #selector(editButton))
        }
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(dismissCloseButton))
    }
}

