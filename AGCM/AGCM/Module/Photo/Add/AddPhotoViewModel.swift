//
//  AddPhotoViewModel.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 01/02/23.
//

import Foundation
import UIKit

class AddPhotoViewModel {
    var selectedImage: UIImage?
    var dailyLogId: Int = 0
    var photoDetail:PhotoDetail = PhotoDetail()
    var viewType: ViewType = .add
    
    private let apiService = PhotoAPI()
    
    func uploadPhoto(onSuccess: @escaping() -> (), onError: @escaping(Bool) -> ()) {
        if viewType == .add {
            photoDetail.dailyLogId = dailyLogId
            if let image = selectedImage {
                photoDetail.image = image.base64String
            }
            apiService.uploadPhoto(photo: photoDetail) { response in
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
            apiService.updatePhoto(photo: photoDetail) { response in
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
    
    func getPhotoDetail(onSuccess: @escaping() -> (), onError: @escaping(Bool) -> ()) {
        apiService.getPhotoDetail(id: photoDetail.id) {[weak self] response in
            switch response.result {
            case .success(let detail):
                self?.photoDetail = detail
                self?.selectedImage = detail.image.image
                onSuccess()
            case .failure(let error):
                onError(error.isSessionTaskError)
            }
        }
    }
}


