//
//  ImagePicker.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 01/02/23.
//

import Foundation
import UIKit
import Photos

public struct ImagePickerItem {
    let image: UIImage
    let fileName: String
    let created: Date
}

public protocol ImagePickerDelegate: AnyObject {
    func didSelect(pickerItem: ImagePickerItem?)
}

open class ImagePicker: NSObject {

    var addTime: Bool = true
    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: ImagePickerDelegate?

    public init(presentationController: UIViewController, delegate: ImagePickerDelegate) {
        self.pickerController = UIImagePickerController()

        super.init()

        self.presentationController = presentationController
        self.delegate = delegate

        self.pickerController.delegate = self
        self.pickerController.allowsEditing = true
        self.pickerController.mediaTypes = ["public.image"]
    }

    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }

        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.pickerController.sourceType = type
            self.presentationController?.present(self.pickerController, animated: true)
        }
    }

    public func present(from sourceView: UIView) {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .notDetermined  {
            PHPhotoLibrary.requestAuthorization({[weak self]status in
                DispatchQueue.main.async {
                    self?.present(from: sourceView)
                }
            })
        } else {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            if let action = self.action(for: .camera, title: "Take a photo") {
                alertController.addAction(action)
            }
            if let action = self.action(for: .photoLibrary, title: "Choose from library") {
                alertController.addAction(action)
            }
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                alertController.popoverPresentationController?.sourceView = sourceView
                alertController.popoverPresentationController?.sourceRect = sourceView.bounds
                alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
            }
            
            self.presentationController?.present(alertController, animated: true)
        }
    }

    private func pickerController(_ controller: UIImagePickerController, didSelect pickerItem: ImagePickerItem?) {
        controller.dismiss(animated: true, completion: nil)

        self.delegate?.didSelect(pickerItem: pickerItem)
    }
}

extension ImagePicker: UIImagePickerControllerDelegate {

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, didSelect: nil)
    }

    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        guard let image = info[.editedImage] as? UIImage else {
            return self.pickerController(picker, didSelect: nil)
        }
        var selectedFileName = ""
        var date: Date = Date()
        if let imgUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL {
            if let asset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset {
                date = asset.creationDate ?? Date()
            }
            selectedFileName = imgUrl.lastPathComponent
        } else  {
            // If the user take the photo from the camera
            selectedFileName = generateImageName()
        }
        let updatedImage: UIImage
        if addTime {
            updatedImage = addDateToImage(image: image, date: date)
        } else {
            updatedImage = image
        }
        let picketItem = ImagePickerItem(image: updatedImage, fileName: selectedFileName, created: date)
        self.pickerController(picker, didSelect: picketItem)
    }
    
    private func generateImageName() -> String {
        return "IMAGE_" + Date().getOdooDisplayDate(format: "YYYY_MM_dd_HH_mm_ss")
    }
    
    private func addDateToImage(image: UIImage, date: Date) -> UIImage {
        let timeString = date.getOdooDisplayDate(format: "MMM d, YYYY hh:mm:ss aa")
        UIGraphicsBeginImageContextWithOptions(image.size, false, 1)
        
        var fontSize = image.size.width / 25
        if fontSize > 50 {
            fontSize = 50
        } else if fontSize < 20 {
            fontSize = 20
        }
        
        let textFontAttributes: [NSAttributedString.Key : Any] = [
            .font: UIFont.systemFont(ofSize: fontSize),
            .foregroundColor: UIColor.white,
            .strokeColor : UIColor.black,
            .strokeWidth : -2.0
        ]
        
        let imageSize = image.size
        image.draw(in: CGRect(origin: CGPoint.zero, size: imageSize))
        
        let textSize = timeString.size(withAttributes: textFontAttributes)
        let origin = CGPoint(x: imageSize.width - textSize.width - 20, y: 10)
        timeString.draw(at: origin, withAttributes: textFontAttributes)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? image
    }
}

extension ImagePicker: UINavigationControllerDelegate {

}
