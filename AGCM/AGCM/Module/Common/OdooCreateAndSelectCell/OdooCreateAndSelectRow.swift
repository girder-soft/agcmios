//
//  OdooCreateAndSelectRow.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 29/01/23.
//

import Foundation
import UIKit
import Eureka
import Alamofire
import ProgressHUD

public struct CreateAndSelect: Codable, Equatable {
    let id: Int
    let name: String
}

public final class OdooCreateAndSelectRow: OptionsRow<PushSelectorCell<CreateAndSelect>>, PresenterRowType, RowType {
    public typealias PresenterRow = CreateAndSelectViewController
    
    /// Defines how the view controller will be presented, pushed, etc.
    public var presentationMode: PresentationMode<PresenterRow>?
    
    /// Will be called before the presentation occurs.
    public var onPresentCallback: ((FormViewController, PresenterRow) -> Void)?

    var modelName: String = "res.partner"
    var options: [CreateAndSelect] = []
    var canAddOption: Bool = false
    public required init(tag: String?) {
        super.init(tag: tag)
        presentationMode = .show(controllerProvider: ControllerProvider.callback { return CreateAndSelectViewController(modelName: self.modelName, options: self.options, canAddOption: self.canAddOption, { _ in }) }, onDismiss: { vc in _ = vc.navigationController?.popViewController(animated: true) })

        displayValueFor = {
            guard let model = $0 else { return "" }
            return model.name
        }
    }
    
    /**
     Extends `didSelect` method
     */
    public override func customDidSelect() {
        super.customDidSelect()
        guard let presentationMode = presentationMode, !isDisabled else { return }
        if let controller = presentationMode.makeController() {
            controller.row = self
            controller.title = selectorTitle ?? controller.title
            onPresentCallback?(cell.formViewController()!, controller)
            presentationMode.present(controller, row: self, presentingController: self.cell.formViewController()!)
        } else {
            presentationMode.present(nil, row: self, presentingController: self.cell.formViewController()!)
        }
    }
    
    /**
     Prepares the pushed row setting its title and completion callback.
     */
    public override func prepare(for segue: UIStoryboardSegue) {
        super.prepare(for: segue)
        guard let rowVC = segue.destination as? PresenterRow else { return }
        rowVC.title = selectorTitle ?? rowVC.title
        rowVC.onDismissCallback = presentationMode?.onDismissCallback ?? rowVC.onDismissCallback
        onPresentCallback?(cell.formViewController()!, rowVC)
        rowVC.row = self
    }
    
}

public class CreateAndSelectViewController: UITableViewController, TypedRowControllerType {
    public var row: RowOf<CreateAndSelect>!
    public var onDismissCallback: ((UIViewController) -> ())?
    var currentSelectedModel: CreateAndSelect?
    var options: [CreateAndSelect] = []
    var modelName: String = "res.partner"
    var canAddOption: Bool = false
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }

    convenience public init(modelName: String, options: [CreateAndSelect], canAddOption: Bool, _ callback: ((UIViewController) -> ())?){
        self.init(nibName: nil, bundle: nil)
        onDismissCallback = callback
        self.modelName =  modelName
        self.options = options
        self.canAddOption = canAddOption
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        if canAddOption {
            let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(CreateAndSelectViewController.addAction(_:)))
            navigationItem.rightBarButtonItem = button
        }
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TitleTableCell")
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let value = row.value {
            currentSelectedModel = value
        }
        updateTitle()
        if options.count == 0 {
            getCreateSelectOption()
        } else {
            tableView.reloadData()
        }
    }

    @objc func addAction(_ sender: UIBarButtonItem){
        let alertController = UIAlertController(title: "Add", message: "", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: {[weak self] alert -> Void in
            let nameField = alertController.textFields![0] as UITextField
            guard let weakSelf = self else {return}
            if let name = nameField.text, !name.isEmpty {
                weakSelf.addNew(name: name)
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in })
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Name"
        }
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        alertController.preferredAction = saveAction
        self.present(alertController, animated: true, completion: nil)
    }

    func updateTitle(){
        title = "Select"
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TitleTableCell", for: indexPath)
        let model = options[indexPath.row]
        cell.textLabel?.text = model.name
        cell.accessoryType = model.id == (currentSelectedModel?.id ?? 0) ? .checkmark : .none
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentSelectedModel = options[indexPath.row]
        row.value = currentSelectedModel
        onDismissCallback?(self)
    }
    
    private func getCreateSelectOption() {
        ProgressHUD.show()
        AF.request(URLConstant.domain + "/api/" + modelName, method: .get, parameters: ["query": "{id,name}"], encoder: URLEncodedFormParameterEncoder.default, headers: [URLConstant.contentType :URLConstant.applicationJson]).responseDecodable(of: OdooPageResult<CreateAndSelect>.self) {[weak self] response in
            ProgressHUD.dismiss()
            switch response.result {
            case .success(let pageResult):
                self?.options = pageResult.result ?? []
                self?.tableView.reloadData()
            case .failure(_):
                ProgressHUD.showError("Something went wrong, please try again.")
            }
        }
    }
    
    private func addNew(name: String) {
        let postData = OdooPostParam<CreateAndSelect>(params: OdooData(data: CreateAndSelect(id: 0, name: name)))
        ProgressHUD.show()
        AF.request(URLConstant.domain + "/api/" + modelName, method: .post, parameters:postData , encoder: JSONParameterEncoder.default, headers: [URLConstant.contentType :URLConstant.applicationJson]).responseDecodable(of: OdooPostResponse.self) {[weak self] response in
            ProgressHUD.dismiss()
            switch response.result {
            case .success(let createResult):
                if createResult.result != 0 {
                    self?.getCreateSelectOption()
                } else {
                    ProgressHUD.showError("Something went wrong, please try again.")
                }
            case .failure(_):
                ProgressHUD.showError("Something went wrong, please try again.")
            }
        }
    }
 
}


