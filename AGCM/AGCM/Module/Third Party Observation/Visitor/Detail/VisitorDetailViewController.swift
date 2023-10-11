//
//  VisitorDetailViewController.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 24/01/23.
//

import UIKit
import Eureka
import ProgressHUD

class VisitorDetailViewController: FormViewController {
    let viewModel: VisitorDetailViewModel = VisitorDetailViewModel()
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
            $0.title = "Visitor Name"
            $0.value = viewModel.visitor.name
            $0.add(rule: RuleRequired(msg: "Enter name"))
            $0.onChange {[weak self] row in
                self?.viewModel.visitor.name = row.value ?? ""
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
            $0.title = "Visit Reason"
            $0.placeholder = "Visit Reason"
            $0.add(rule: RuleRequired(msg: "Enter reason"))
            $0.value = viewModel.visitor.reason
            $0.onChange {[weak self] row in
                self?.viewModel.visitor.reason = row.value ?? ""
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
        
        <<< DateTimeRow() {
            $0.title = "Start Time"
            $0.value = viewModel.visitor.entryTime
            $0.onChange {[weak self] row in
                self?.viewModel.visitor.entryTime = row.value ?? Date()
            }
        }
        <<< DateTimeRow() {
            $0.title = "End Time"
            $0.value = viewModel.visitor.exitTime
            $0.onChange {[weak self] row in
                self?.viewModel.visitor.exitTime = row.value ?? Date()
            }
        }
        <<< TextAreaRow() {
            $0.title = "Comments"
            $0.placeholder = "Comments"
            $0.value = viewModel.visitor.comments
            $0.onChange {[weak self] row in
                self?.viewModel.visitor.comments = row.value ?? ""
            }
            $0.textAreaHeight = .dynamic(initialTextViewHeight: 80)
        }
        
        <<< OdooCreateAndSelectRow() {
            $0.title = "Person to Meet"
            $0.value = viewModel.visitor.user.id != 0 ? viewModel.visitor.user : nil
            $0.selectorTitle = "Select User"
            $0.modelName = "res.users"
            $0.add(rule: RuleRequired(msg: "Please select user"))
            $0.onChange {[weak self] row in
                if let model = row.value {
                    self?.viewModel.visitor.user = model
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
        
        self.updateViewType()
    }
    
   @objc func dismissCloseButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @objc func saveButton() {
        let validationError = form.validate()
        if validationError.count == 0 {
            ProgressHUD.show()
            viewModel.updateVisitorChanges {[weak self] in
                ProgressHUD.showSucceed()
                self?.updateInfo()
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
    
    private func updateInfo() {
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
            self.title = "Edit Visitor"
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItem.Style.plain, target: self, action: #selector(saveButton))
        } else if viewModel.viewType == .add{
            self.title = "Add Visitor"
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItem.Style.plain, target: self, action: #selector(saveButton))
        } else {
            self.title = ""
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItem.Style.plain, target: self, action: #selector(editButton))
        }
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(dismissCloseButton))
    }
}

