//
//  InspectionListViewModel.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 24/01/23.
//

import Foundation

class InspectionListViewModel {
    var list: [InspectionListModel] = []
    var dailyLogId: Int!
    private let apiService: InspectionAPI = InspectionAPI()
        
    func getInspections(onSuccess: @escaping() -> (), onError: @escaping(Bool) -> ()) {
        apiService.getInspectionList(dailyLogId: dailyLogId) {[weak self] response in
            switch response.result {
            case .success(let pageResult):
                self?.list =  (pageResult.result ?? []).map{InspectionListModel(inspection: $0)}
                onSuccess()
            case .failure(let error):
                onError(error.isSessionTaskError)
            }
        }
    }
    
}
