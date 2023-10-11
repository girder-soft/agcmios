//
//  ManPowerListViewModel.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 22/01/23.
//

import Foundation


class ManPowerListViewModel {
    var list: [ManPowerListModel] = []
    var dailyLogId: Int!
    let apiService: ManPowerAPI = ManPowerAPI()
        
    func getManPowerDetails(onSuccess: @escaping() -> (), onError: @escaping(Bool) -> ()) {
        apiService.getManPowerList(id: dailyLogId) {[weak self] response in
            switch response.result {
            case .success(let manPowerList):
                self?.list = manPowerList.list.map{ManPowerListModel(manPower: $0)}
                onSuccess()
            case .failure(let error):
                onError(error.isSessionTaskError)
            }
        }
    }
}
