//
//  VisitorListViewModel.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 24/01/23.
//

import Foundation

class VisitorListViewModel {
    var list: [VisitorListModel] = []
    var dailyLogId: Int = 0
    private let apiService = VisitorAPI()
    
    func getVisitorList(onSuccess: @escaping() -> (), onError: @escaping(Bool) -> ()) {
        apiService.getVisitors( dailyLogId: dailyLogId) {[weak self] response in
            switch response.result {
            case .success(let pageResult):
                self?.list =  (pageResult.result ?? []).map{VisitorListModel(visitor:$0)}
                onSuccess()
            case .failure(let error):
                onError(error.isSessionTaskError)
            }
        }
    }
    
}
