//
//  OdooAttachmentRow.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 01/02/23.
//

import Foundation
import UIKit
import Eureka
import Alamofire
import ProgressHUD

public final class OdooAttachmentRow: OptionsRow<PushSelectorCell<String>>, PresenterRowType, RowType {
    public typealias PresenterRow = AttachmentViewController
    
    /// Defines how the view controller will be presented, pushed, etc.
    public var presentationMode: PresentationMode<PresenterRow>?
    
    /// Will be called before the presentation occurs.
    public var onPresentCallback: ((FormViewController, PresenterRow) -> Void)?

    var resId: Int = 0
    var resModel: String = ""
    var isViewOnly: Bool = false
    public required init(tag: String?) {
        super.init(tag: tag)
        presentationMode = .show(controllerProvider: ControllerProvider.callback { return AttachmentViewController(resId: self.resId, resModel: self.resModel, isViewOnly: self.isViewOnly) { _ in } }, onDismiss: { vc in _ = vc.navigationController?.popViewController(animated: true) })

        displayValueFor = {
            guard let count = $0 else { return "" }
            return count
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

struct Attachment: Codable {
    let id: Int
    let name: String
    let mimetype: String
}

struct AttachmentDetail: Codable {
    let id: Int
    let datas: String
    let name: String
}

struct AttachmentUpload: Codable {
    let datas: String
    let name: String
    let resId: Int
    let resModel: String
    
    enum CodingKeys: String, CodingKey {
        case datas
        case name
        case resId = "res_id"
        case resModel = "res_model"
    }
}

public class AttachmentViewController: UITableViewController, TypedRowControllerType {
    public var row: RowOf<String>!
    public var onDismissCallback: ((UIViewController) -> ())?
    var resId: Int = 0
    var resModel: String = ""
    var isViewOnly: Bool = false
    private var attachments: [Attachment] = []
    private var imagePicker: ImagePicker!
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }

    convenience public init(resId: Int, resModel: String, isViewOnly: Bool, _ callback: ((UIViewController) -> ())?){
        self.init(nibName: nil, bundle: nil)
        onDismissCallback = callback
        self.resId =  resId
        self.resModel = resModel
        self.isViewOnly = isViewOnly
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        if !isViewOnly {
            let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(AttachmentViewController.addAction(_:)))
            navigationItem.rightBarButtonItem = button
        }
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TitleTableCell")
        self.getAttachments()
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTitle()
    }

    @objc func addAction(_ sender: UIBarButtonItem){
        imagePicker.present(from: self.view)
    }

    func updateTitle(){
        title = "Attachment"
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attachments.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TitleTableCell", for: indexPath)
        let model = attachments[indexPath.row]
        cell.textLabel?.text = model.name
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.getAttachment(id: attachments[indexPath.row].id)
    }
    
    private func getAttachments() {
        let filter = String(format: "[[\"res_model\",\"=\",\"%@\"],[\"res_id\",\"=\",%d]]", resModel,resId)
        ProgressHUD.show()
        AF.request(URLConstant.domain + "/api/ir.attachment" , method: .get, parameters: ["query": "{id,type,mimetype,name}", "filter": filter], encoder: URLEncodedFormParameterEncoder.default, headers: [URLConstant.contentType :URLConstant.applicationJson]).responseDecodable(of: OdooPageResult<Attachment>.self) {[weak self] response in
            ProgressHUD.dismiss()
            switch response.result {
            case .success(let pageResult):
                self?.attachments = pageResult.result ?? []
                self?.tableView.reloadData()
            case .failure(_):
                ProgressHUD.showError("Something went wrong, please try again.")
            }
        }
    }
    
    private func getAttachment(id: Int) {
        ProgressHUD.show()
        AF.request(URLConstant.domain + "/api/ir.attachment/" + String(id)  , method: .get, parameters: ["query": "{id,datas,name}"], encoder: URLEncodedFormParameterEncoder.default, headers: [URLConstant.contentType :URLConstant.applicationJson]).responseDecodable(of: AttachmentDetail.self) {[weak self] response in
            ProgressHUD.dismiss()
            switch response.result {
            case .success(let detail):
                self?.showAttachmentDetail(attachmentDetail: detail)
            case .failure(_):
                ProgressHUD.showError("Something went wrong, please try again.")
            }
        }
    }
    
    private func showAttachmentDetail(attachmentDetail: AttachmentDetail) {
        if let image = attachmentDetail.datas.image {
            let imageDetailVC = ImageDetailViewController(image: image, fileName: attachmentDetail.name)
            self.navigationController?.pushViewController(imageDetailVC, animated: true)
        }
    }
    
    private func addNew(image: UIImage, fileName: String) {
        let postData = OdooPostParam<AttachmentUpload>(params: OdooData(data: AttachmentUpload(datas: image.base64String, name: fileName, resId: resId, resModel: resModel)))
        ProgressHUD.show()
        AF.request(URLConstant.domain + "/api/ir.attachment/", method: .post, parameters:postData , encoder: JSONParameterEncoder.default, headers: [URLConstant.contentType :URLConstant.applicationJson]).responseDecodable(of: OdooPostResponse.self) {[weak self] response in
            ProgressHUD.dismiss()
            switch response.result {
            case .success(let createResult):
                if createResult.result != 0 {
                    self?.getAttachments()
                } else {
                    ProgressHUD.showError("Something went wrong, please try again.")
                }
            case .failure(_):
                ProgressHUD.showError("Something went wrong, please try again.")
            }
        }
    }
 
}


extension AttachmentViewController: ImagePickerDelegate {
    
    public func didSelect(pickerItem: ImagePickerItem?) {
        if let item = pickerItem {
            self.addNew(image: item.image, fileName: item.fileName)
        }
    }
}


