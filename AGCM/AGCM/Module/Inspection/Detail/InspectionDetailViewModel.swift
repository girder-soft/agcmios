//
//  InspectionDetailViewModel.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 30/01/23.
//

import Foundation

class InspectionDetailViewModel {
    var viewType: ViewType = .add
    var inspection: Inspection = Inspection()
    var dailyLogId: Int = 0
    private let apiService = InspectionAPI()
    func updateInspectionChanges(onSuccess: @escaping() -> (), onError: @escaping(Bool) -> ()) {
        if viewType == .add {
            apiService.createInspection(inspection: inspection) { response in
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
            apiService.updateInspection(inspection: inspection) { response in
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
