//
//  ProjectDetailViewModel.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 28/01/23.
//

import Foundation

class ProjectDetailViewModel{
    var list: [DailyLogItem] = []
    var projectModel: ProjectListModel!
    var projectDetail: ProjectDailyLogListItem!
    let apiService: ProjectAPI = ProjectAPI()
    
    func getProjectDetail(onSuccess: @escaping() -> (), onError: @escaping(Bool) -> ()) {
        apiService.getDailyLogList(id: projectModel.id) {[weak self] response in
            switch response.result {
            case .success(let projectDetail):
                self?.projectDetail = projectDetail
                self?.list = projectDetail.dailyLogs
                onSuccess()
            case .failure(let error):
                onError(error.isSessionTaskError)
            }
        }
    }
} 
