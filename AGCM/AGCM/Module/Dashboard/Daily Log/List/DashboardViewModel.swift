//
//  DashboardViewModel.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 19/01/23.
//

import Foundation

class DashboardViewModel {
    var list: [DashboardListModel] = []
    var dailyLogItem: DailyLogItem!
    var project: Project!
    var dailyLogDetail: DailyLogDetail!
    private let apiService: ProjectAPI = ProjectAPI()

    func getDailyLogDetail(onSuccess: @escaping() -> (), onError: @escaping(Bool) -> ()) {
        apiService.getDailyLogDetail(id: dailyLogItem.id) {[weak self] response in
            switch response.result {
            case .success(let detail):
                self?.dailyLogDetail = detail
                self?.createDashboardList()
                onSuccess()
            case .failure(let error):
                onError(error.isSessionTaskError)
            }
        }
    }
    
    func createDashboardList() {
        list = []
        for type in DashboardListType.allCases {
            var count: Int = 0
            var subTitle: String = ""
            if type == .weather {
                count = dailyLogDetail.weathers.count
            } else if type == .manPower {
                count = dailyLogDetail.manpowers.count
                let workers = dailyLogDetail.manpowers.reduce(0){$0 + $1.workers}
                let totalHours = dailyLogDetail.manpowers.reduce(0){$0 + $1.totalHours}
                subTitle = String(format: "%d workers & %0.2f hours", workers,totalHours)
            } else if type == .thirdPartyObservation {
                count = dailyLogDetail.notes.count
            } else if type == .safety {
                count = dailyLogDetail.safety.count
            } else if type == .delay {
                count = dailyLogDetail.delay.count
            } else if type == .visitor {
                count = dailyLogDetail.visitor.count
            } else if type == .inspection {
                count = dailyLogDetail.inspections.count
            } else if type == .photo {
                count = dailyLogDetail.photos.count
            }
            list.append(DashboardListModel(title: type.title, type: type, count: count, subTitle: subTitle))
        }
    }
}

