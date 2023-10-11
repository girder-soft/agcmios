//
//  LoginAPI.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 27/01/23.
//

import Foundation
import Alamofire

class LoginAPI {
    private let auth = "/auth"
    
    func validateUser(loginCredential: LoginPostResponse, onCompletion: @escaping(AFDataResponse<OdooResponse<LoginResponse>>) -> ()) {
        AF.request(URLConstant.domain + auth, method: .post, parameters: loginCredential, encoder: JSONParameterEncoder.default, headers: [URLConstant.contentType :URLConstant.applicationJson]).responseDecodable(of: OdooResponse<LoginResponse>.self) { response in
            onCompletion(response)
        }
    }
}
