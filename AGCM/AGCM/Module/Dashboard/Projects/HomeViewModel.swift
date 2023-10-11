//
//  HomeViewModel.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 27/01/23.
//

import Foundation

class HomeViewModel {
    var list:[ProjectListModel] = []
    var name: String = ""
    var email: String = ""
    let apiService: HomeAPI = HomeAPI()
    
    init() {
        name = UserDefaultsManager.shared.getUserName()
        email = UserDefaultsManager.shared.getUserEmail()
    }
    
    func getProjectList(onSuccess: @escaping() -> (), onError: @escaping(Bool) -> ()) {
        apiService.getProjectList { [weak self] response in
            switch response.result {
            case .success(let pageResult):
                if let result = pageResult.result {
                    self?.list = result.map{ProjectListModel(project: $0)}
                    onSuccess()
                } else {
                    onError(false)
                }
            case .failure(let error):
                onError(error.isSessionTaskError)
            }
        }
    }
    
    func updateUserInfo(onCompletion: @escaping() -> ()) {
        apiService.getUser(id: UserDefaultsManager.shared.userId) {[weak self] response in
            switch response.result {
            case .success(let user):
                UserDefaultsManager.shared.setUser(name: user.name, email: user.email )
                self?.name = user.name
                self?.email = user.email
            case .failure(_):
                break
            }
            onCompletion()
        }
    }
}
