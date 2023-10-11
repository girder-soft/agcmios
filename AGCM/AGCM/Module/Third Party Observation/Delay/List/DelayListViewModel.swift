//
//  DelayListViewModel.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 31/01/23.
//

import Foundation

class DelayListViewModel {
    var list: [DelayListModel] = []
    var dailyLogId: Int = 0
    private let apiService = DelayAPI()
    
    func getDelayList(onSuccess: @escaping() -> (), onError: @escaping(Bool) -> ()) {
        apiService.getDelayList( dailyLogId: dailyLogId) {[weak self] response in
            switch response.result {
            case .success(let pageResult):
                self?.list =  (pageResult.result ?? []).map{DelayListModel(delay:$0)}
                onSuccess()
            case .failure(let error):
                onError(error.isSessionTaskError)
            }
        }
    }
    
}
