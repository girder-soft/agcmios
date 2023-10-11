//
//  LoginViewModel.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 26/01/23.
//

import Foundation
import Alamofire

enum LoginError {
    case invalidCredentials, noInternet, other
}

class LoginViewModel {
    let apiService = LoginAPI()
    
    func loginWithCredential(email: String, password: String, onSuccess: @escaping()->(), onError: @escaping(LoginError) -> ()) {
        let loginPostModel = LoginPostResponse(params: LoginPostResponse.LoginParam(login: email, password: password, db: URLConstant.db))
        apiService.validateUser(loginCredential: loginPostModel) { response in
            switch response.result {
            case .success(let odooResponse):
                if let result = odooResponse.result {
                    if let url = response.response?.url?.absoluteString {
                        CookieHandler.shared.backupCookies(forURL: url)
                        CookieHandler.shared.restoreCookies()
                    }
                    UserDefaultsManager.shared.setUserId(id: result.uid, name: result.name)
                    onSuccess()
                } else {
                    onError(.invalidCredentials)
                }
            case .failure(let error):
                if error.isSessionTaskError {
                    onError(.noInternet)
                } else {
                    onError(.other)
                }
            }
        }
    }
    
    func resetPassword(email: String, onSuccess: @escaping()->(), onError: @escaping(LoginError) -> ()) {
        if email == "demo" {
            onSuccess()
        } else {
            onError(.invalidCredentials)
        }
    }
}

