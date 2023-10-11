//
//  PhotosAPI.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 01/02/23.
//

import Foundation
import Alamofire

struct PhotoAPI {
    private let photoModel = "/api/photo/"
    func getPhotos(dailyLogId: Int, onCompletion: @escaping(AFDataResponse<OdooPageResult<Photo>>) -> ()) {
        let filter = String(format: "[[\"dailylog_id\",\"=\",%d]]", dailyLogId)
        AF.request(URLConstant.domain + photoModel, method: .get, parameters: ["query": "{id,dailylog_id,name}", "filter" : filter], encoder: URLEncodedFormParameterEncoder.default, headers: [URLConstant.contentType :URLConstant.applicationJson]).responseDecodable(of: OdooPageResult<Photo>.self) { response in
            onCompletion(response)
        }
    }
    
    func getPhoto(id: Int, onCompletion: @escaping(AFDataResponse<Photo>) -> ()) {
        AF.request(URLConstant.domain + photoModel + String(id), method: .get, parameters: ["query": "{id,dailylog_id,image,name}"], encoder: URLEncodedFormParameterEncoder.default, headers: [URLConstant.contentType :URLConstant.applicationJson]).responseDecodable(of: Photo.self) { response in
            onCompletion(response)
        }
    }
    
    func uploadPhoto(photo: PhotoDetail, onCompletion: @escaping(AFDataResponse<OdooPostResponse>) -> ()) {
        let postData = OdooPostParam<PhotoDetail>(params: OdooData(data: photo))
        AF.request(URLConstant.domain + photoModel  , method: .post, parameters: postData, encoder: JSONParameterEncoder.default, headers: [URLConstant.contentType :URLConstant.applicationJson]).responseDecodable(of: OdooPostResponse.self) { response in
            onCompletion(response)
        }
    }
    
    func getPhotoDetail(id: Int, onCompletion: @escaping(AFDataResponse<PhotoDetail>) -> ()) {
        AF.request(URLConstant.domain + photoModel + String(id), method: .get, parameters: ["query": "{id,album,name,file_name,create_uid{id,name},create_date,location,dailylog_id,taken_on,image}"], encoder: URLEncodedFormParameterEncoder.default, headers: [URLConstant.contentType :URLConstant.applicationJson]).responseDecodable(of: PhotoDetail.self) { response in
            onCompletion(response)
        }
    }
    
    func updatePhoto(photo: PhotoDetail, onCompletion: @escaping(AFDataResponse<OdooPutResponse>) -> ()) {
        let postData = OdooPostParam<PhotoDetail>(params: OdooData(data: photo))
        AF.request(URLConstant.domain + photoModel + String(photo.id)  , method: .put, parameters: postData, encoder: JSONParameterEncoder.default, headers: [URLConstant.contentType :URLConstant.applicationJson]).responseDecodable(of: OdooPutResponse.self) { response in
            onCompletion(response)
        }
    }
}

