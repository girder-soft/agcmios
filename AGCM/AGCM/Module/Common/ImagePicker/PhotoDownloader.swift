//
//  PhotoDownloader.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 01/02/23.
//

import Foundation
import UIKit

class PhotoDownloader {
    
    static let shared = PhotoDownloader()
    var imageCache: [Int: UIImage] = [:]
    var currentRequest: [Int: [(UIImage?) -> ()]] = [:]
    var errorIds: [Int] = []
    
    private let apiService = PhotoAPI()
    
    func getImageForPhotoModel(id: Int, onCompletion: @escaping(UIImage?) -> ()) {
        if let image = imageCache[id]  {
            onCompletion(image)
        } else {
            if errorIds.contains(id) {
                onCompletion(nil)
            } else if var completions = currentRequest[id] {
                completions.append(onCompletion)
                currentRequest[id] = completions
            } else {
                currentRequest[id] = [onCompletion]
                apiService.getPhoto(id: id) {[weak self] response in
                    var image: UIImage? = nil
                    switch response.result {
                    case .success(let photo):
                        image = photo.image.image
                    case .failure(_):
                        image = nil
                    }
                    self?.passCompletion(image: image, id: id)
                }
            }
        }
    }
    
    private func passCompletion(image: UIImage?, id: Int) {
        if let image = image {
            self.imageCache[id] = image
        } else {
            self.errorIds.append(id)
        }
        for imageCompletion in (currentRequest[id] ?? []) {
            imageCompletion(image)
        }
        currentRequest.removeValue(forKey: id)
        
    }
}
