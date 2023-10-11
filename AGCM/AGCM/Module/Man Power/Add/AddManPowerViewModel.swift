//
//  AddManPowerViewModel.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 29/01/23.
//

import Foundation

class AddManPowerViewModel {
    var viewType: ViewType = .add
    var manPower: ManPower = ManPower()
    var dailyLogId: Int = 0
    private let apiService = ManPowerAPI()
    func updateManPowerChanges(onSuccess: @escaping() -> (), onError: @escaping(Bool) -> ()) {
        if viewType == .add {
            apiService.createManPower(manPower: manPower) { response in
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
            apiService.updateManPower(manPower: manPower) { response in
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
    
    func updateTotalHoursValue() {
        self.manPower.totalHours = Double(self.manPower.workers) * self.manPower.hours
    }
    
}
