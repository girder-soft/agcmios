//
//  PhotosViewController.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 01/02/23.
//

import UIKit
import ProgressHUD

class PhotosViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var imagePicker: ImagePicker!
    let viewModel = PhotosViewModel()
    weak var dailyLogDelegate: DataUpdateProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpCollectionView()
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
    }
    
    private func setUpCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getPhotos()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let layout = collectionView.collectionViewLayout
        if let flowLayout = layout as? UICollectionViewFlowLayout {
            let size = collectionView.frame.size.width / 3
            flowLayout.estimatedItemSize = CGSize(
                width: size,
                height: size
            )
            collectionView.collectionViewLayout = flowLayout
        }
    }
    
    func getPhotos() {
        ProgressHUD.show()
        viewModel.getPhotos {[weak self] in
            ProgressHUD.dismiss()
            self?.collectionView.reloadData()
        } onError: { isInternetError in
            if isInternetError {
                ProgressHUD.showError("No Internet connection")
            } else {
                ProgressHUD.showError("Something went wrong, please try again.")
            }
        }
    }
    
    @IBAction func addButtonAction(_ sender: UIBarButtonItem) {
        imagePicker.present(from: self.view)
    }
    
    @IBAction func dismissCloseButton(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension PhotosViewController: ImagePickerDelegate {

    func didSelect(pickerItem: ImagePickerItem?) {
        if let item = pickerItem {
            let addPhoto_VC = AddPhotoViewController()
            addPhoto_VC.viewModel.viewType = .add
            addPhoto_VC.viewModel.selectedImage = item.image
            addPhoto_VC.viewModel.dailyLogId = viewModel.dailyLogId
            addPhoto_VC.viewModel.photoDetail.fileName = item.fileName
            addPhoto_VC.viewModel.photoDetail.takenOn = item.created
            addPhoto_VC.viewModel.photoDetail.uploadedOn = Date()
            addPhoto_VC.viewModel.photoDetail.album = "Photos from daily log"
            addPhoto_VC.delegate = self
            self.navigationController?.pushViewController(addPhoto_VC, animated: true)
        }
    }
}

extension PhotosViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        ProgressHUD.show()
        let model = viewModel.list[indexPath.item]
        let addPhoto_VC = AddPhotoViewController()
        addPhoto_VC.viewModel.viewType = .view
        addPhoto_VC.viewModel.dailyLogId = viewModel.dailyLogId
        addPhoto_VC.viewModel.photoDetail.id = model.id
        addPhoto_VC.delegate = self
        self.navigationController?.pushViewController(addPhoto_VC, animated: true)
    }
    
}

extension PhotosViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        cell.loadingView.startAnimating()
        cell.imageView.image = nil
        PhotoDownloader.shared.getImageForPhotoModel(id: viewModel.list[indexPath.item].id) {[weak cell] image in
            cell?.loadingView.stopAnimating()
            if let image = image {
                cell?.imageView.image = image
            } else {
                cell?.imageView.image = UIImage(named: "icon_placeholder")
            }
        }
        
        cell.widthConstraint.constant = (collectionView.frame.size.width / 3) - 1
        return cell
    }
}

extension PhotosViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.size.width / 3
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension PhotosViewController: DataUpdateProtocol{
    func didDataUpdated() {
        self.getPhotos()
        self.dailyLogDelegate?.didDataUpdated()
    }
}

extension String {
    var image: UIImage? {
        guard let stringData = Data(base64Encoded: self) else {
            return nil
        }
        return UIImage(data: stringData)
    }
}

extension UIImage {
    var base64String: String {
        guard let data = self.jpegData(compressionQuality: 0.5) else {
            return ""
        }
        return data.base64EncodedString()
    }
}
