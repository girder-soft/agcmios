//
//  PhotosViewModel.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 01/02/23.
//

import Foundation

class PhotosViewModel {
    var list:[Photo] = []
    var dailyLogId: Int = 0
    private let apiService = PhotoAPI()
    
    func getPhotos(onSuccess: @escaping() -> (), onError: @escaping(Bool) -> ()) {
        apiService.getPhotos(dailyLogId: dailyLogId) {[weak self] response in
            switch response.result {
            case .success(let pageResult):
                self?.list = pageResult.result ?? []
                onSuccess()
            case .failure(let error):
                onError(error.isSessionTaskError)
            }
        }
    }
}




