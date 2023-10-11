//
//  ThirdPartyListViewModel.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 24/01/23.
//

import Foundation

class ThirdPartyListViewModel {
    var list: [ThirdPartyListModel] = []
    var observationId: Int = 0
    var observationDetail: ObservationDetail!
    private let apiService: ObservationAPI = ObservationAPI()
    
    init() {
        self.list = ThirdPartyListType.allCases.map{ThirdPartyListModel(type: $0)}
    }
    
    func updateList() {
        for i in 0 ..< list.count  {
            var model = list[i]
            if model.type == .safetyObservation {
                model.count = observationDetail.safetyObservations.count
            } else if model.type == .delay {
                model.count = observationDetail.delays.count
            } else if model.type == .visitor {
                model.count = observationDetail.visitors.count
            }
            list[i] = model
        }
    }
    
    func getObservationDetail(onSuccess: @escaping() -> (), onError: @escaping(Bool) -> ()) {
        apiService.getObservationDetail(id: observationId) {[weak self] response in
            switch response.result {
            case .success(let detail):
                self?.observationDetail = detail
                self?.updateList()
                onSuccess()
            case .failure(let error):
                onError(error.isSessionTaskError)
            }
        }
    }
    
}
