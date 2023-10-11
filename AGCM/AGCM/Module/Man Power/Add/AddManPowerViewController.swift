//
//  AddManPowerViewController.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 22/01/23.
//

import UIKit
import Eureka
import ProgressHUD

enum ViewType {
    case view, add, edit
    
    var isReadOnly: Bool {
        return self == .view
    }
}

class AddManPowerViewController: FormViewController {
    let viewModel: AddManPowerViewModel = AddManPowerViewModel()
    weak var delegate: DataUpdateProtocol?
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
            $0.title = "Sub Contractor"
            $0.value = viewModel.manPower.contractor.createSelectModel.id != 0 ? viewModel.manPower.contractor.createSelectModel : nil
            $0.selectorTitle = "Select Contractor"
            $0.modelName = "res.partner"
            $0.add(rule: RuleRequired(msg: "Please select contractor"))
            $0.canAddOption = true
            $0.onChange {[weak self] row in
                if let model = row.value {
                    self?.viewModel.manPower.contractor = Contractor(id: model.id, name: model.name)
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
        
        <<< StepperRow() {
            $0.title = "# Workers"
            $0.value = Double(viewModel.manPower.workers)
            $0.onChange {[weak self] row in
                self?.viewModel.manPower.workers = Int(row.value ?? 0)
                self?.viewModel.updateTotalHoursValue()
            }
        }
        <<< DecimalRow () {
            $0.title = "# Hours"
            $0.value = viewModel.manPower.hours
            $0.onChange {[weak self] row in
                self?.viewModel.manPower.hours = row.value ?? 0
                self?.viewModel.updateTotalHoursValue()
            }
        }
        
        <<< TextRow() {
            $0.title = "Location"
            $0.value = viewModel.manPower.location
            $0.onChange {[weak self] row in
                self?.viewModel.manPower.location = row.value ?? ""
            }
        }
        
        <<< TextAreaRow() {
            $0.title = "Comments"
            $0.placeholder = "Comments"
            $0.value = viewModel.manPower.comments
            $0.onChange {[weak self] row in
                self?.viewModel.manPower.comments = row.value ?? ""
            }
            $0.textAreaHeight = .dynamic(initialTextViewHeight: 80)
        }
        +++ Section()
        <<< OdooAttachmentRow() {
            $0.title = "Attachments"
            $0.resModel = "man.power"
            $0.resId = viewModel.manPower.id
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
            viewModel.updateManPowerChanges {[weak self] in
                ProgressHUD.showSucceed()
                self?.updateManPowerInfo()
            } onError: { isInternetError in
                if isInternetError {
                    ProgressHUD.showError("No Internet connection")
                } else {
                    ProgressHUD.showError("Something went wrong, please try again.")
                }
            }
        }
    }
    
    private func updateManPowerInfo() {
        self.navigationController?.popViewController(animated: true)
        self.delegate?.didDataUpdated()
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
    
    @objc func editButton() {
        self.viewModel.viewType = .edit
        self.updateViewType()
        self.tableView.reloadData()
    }
    
    private func updateTitle() {
        if viewModel.viewType == .edit{
            self.title = "Edit Manpower"
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItem.Style.plain, target: self, action: #selector(saveButton))
        } else if viewModel.viewType == .add{
            self.title = "Add Manpower"
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItem.Style.plain, target: self, action: #selector(saveButton))
        } else {
            self.title = ""
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItem.Style.plain, target: self, action: #selector(editButton))
        }
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(dismissCloseButton))
    }
}

