//
//  VisitorDetailViewModel.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 31/01/23.
//

import Foundation

class VisitorDetailViewModel {
    var viewType: ViewType = .add
    var visitor: Visitor = Visitor()
    var dailyLogId: Int = 0
    private let apiService = VisitorAPI()
    func updateVisitorChanges(onSuccess: @escaping() -> (), onError: @escaping(Bool) -> ()) {
        visitor.dailyLogId = dailyLogId
        if viewType == .add {
            apiService.createVisitor(visitor: visitor) { response in
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
            apiService.updateVisitor(visitor: visitor) { response in
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
}
