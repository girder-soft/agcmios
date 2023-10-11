//
//  AddPhotoViewController.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 01/02/23.
//

import UIKit
import Eureka
import ProgressHUD

class AddPhotoViewController: FormViewController {
    let viewModel = AddPhotoViewModel()
    weak var delegate: DataUpdateProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateTitle()
        LabelRow.defaultCellUpdate = { cell, row in
            cell.textLabel?.textColor = .red
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            cell.textLabel?.textAlignment = .left
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        if viewModel.viewType == .view {
            self.getPhotoDetail()
        } else {
            self.loadForm()
        }
    }
    
    @objc func saveButton() {
        let validationError = form.validate()
        if validationError.count == 0 {
            ProgressHUD.show()
            viewModel.uploadPhoto { [weak self] in
                ProgressHUD.dismiss()
                self?.navigationController?.popViewController(animated: true)
                self?.delegate?.didDataUpdated()
            } onError: { isInternetError in
                if isInternetError {
                    ProgressHUD.showError("No Internet connection")
                } else {
                    ProgressHUD.showError("Something went wrong, please try again.")
                }
            }
        }
    }
    
    private func getPhotoDetail() {
        ProgressHUD.show()
        viewModel.getPhotoDetail { [weak self] in
            ProgressHUD.dismiss()
            self?.loadForm()
        } onError: { isInternetError in
            if isInternetError {
                ProgressHUD.showError("No Internet connection")
            } else {
                ProgressHUD.showError("Something went wrong, please try again.")
            }
        }
    }
    
    private func updateTitle() {
        if viewModel.viewType == .edit{
            self.title = "Edit Photo"
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItem.Style.plain, target: self, action: #selector(saveButton))
        } else if viewModel.viewType == .add{
            self.title = "Add Photo"
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItem.Style.plain, target: self, action: #selector(saveButton))
        } else {
            self.title = "View Photo"
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItem.Style.plain, target: self, action: #selector(editButton))
        }
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(dismissCloseButton))
    }
    
    @objc func dismissCloseButton() {
         self.navigationController?.popViewController(animated: true)
     }
    
    @objc func editButton() {
        self.viewModel.viewType = .edit
        self.updateTitle()
        self.loadForm()
    }
    
    private func loadForm() {
        form.removeAll()
        form
        +++ Section() {
            var header = HeaderFooterView<PhotoSectionHeader>(.nibFile(name: "PhotoSectionHeader", bundle: nil))
            header.onSetupView = {[weak self] (view, section) -> () in
                view.imageView.image = self?.viewModel.selectedImage
                view.imageView.isUserInteractionEnabled = true
                view.imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AddPhotoViewController.openImage)))
            }
            $0.header = header
        }
        <<< TextAreaRow() {
            $0.title = "Description"
            $0.placeholder = "Description"
            $0.value = viewModel.photoDetail.name
            $0.add(rule: RuleRequired(msg: "Enter description"))
            $0.textAreaMode = viewModel.viewType == .view ? .readOnly : .normal
            $0.onChange { [weak self] row in
                self?.viewModel.photoDetail.name = row.value ?? ""
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
        <<< TextRow() {
            $0.title = "Taken On"
            $0.value = viewModel.photoDetail.takenOn.getOdooDisplayDate(format: "MMM d, YYYY hh:mm aa")
            $0.disabled = true
        }
        <<< TextRow() {
            $0.title = "Uploaded On"
            $0.value = viewModel.photoDetail.uploadedOn.getOdooDisplayDate(format: "MMM d, YYYY hh:mm aa")
            $0.disabled = true
        }
        <<< TextRow() {
            $0.title = "Uploaded By"
            $0.value = viewModel.photoDetail.createdBy.name
            $0.disabled = true
        }
        <<< TextRow() {
            $0.title = "Album"
            $0.value = viewModel.photoDetail.album
            $0.onChange { [weak self] row in
                self?.viewModel.photoDetail.album = row.value ?? ""
            }
            $0.cellSetup {[weak self] cell, row in
                cell.textField.isUserInteractionEnabled = self?.viewModel.viewType != .view
            }
        }
        <<< TextRow() {
            $0.title = "Location"
            $0.value = viewModel.photoDetail.location
            $0.onChange { [weak self] row in
                self?.viewModel.photoDetail.location = row.value ?? ""
            }
            $0.cellSetup {[weak self] cell, row in
                cell.textField.isUserInteractionEnabled = self?.viewModel.viewType != .view
            }
        }
        <<< TextRow() {
            $0.title = "File Name"
            $0.value = viewModel.photoDetail.fileName
            $0.disabled = true
            $0.onChange { [weak self] row in
                self?.viewModel.photoDetail.fileName = row.value ?? ""
            }
        }
    }
    
    @objc func openImage() {
        if let image = viewModel.selectedImage {
            let imageDetailVC = ImageDetailViewController(image: image, fileName: viewModel.photoDetail.fileName)
            self.navigationController?.pushViewController(imageDetailVC, animated: true)
        }
    }
}

class PhotoSectionHeader: UIView {

    @IBOutlet weak var imageView: UIImageView!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
