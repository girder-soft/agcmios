//
//  ReportViewController.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 13/02/23.
//

import UIKit
import WebKit
import ProgressHUD
import MessageUI

class ReportViewController: UIViewController {
    let viewModel = ReportViewModel()
    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Report"
        self.loadWebView()
        self.getReport()
    }
    
    func getReport() {
        ProgressHUD.show()
        viewModel.getReport {[weak self] in
            ProgressHUD.dismiss()
            self?.loadReport()
        } onError: { isInternetError in
            if isInternetError {
                ProgressHUD.showError("No Internet connection")
            } else {
                ProgressHUD.showError("Something went wrong, please try again.")
            }
        }
    }
    
    private func loadWebView() {
        webView = WKWebView(frame: self.view.bounds)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        self.view.addSubview(webView)
    }
    
    private func loadReport() {
        if let data = viewModel.reportData, let url = URL(string: "https://agcm.maybox.in/") {
            webView.load(data, mimeType: "application/pdf", characterEncodingName: "utf-8", baseURL: url)
            self.updateNavigationItem()
        }
    }
    
    private func updateNavigationItem() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "E-Mail", style: UIBarButtonItem.Style.plain, target: self, action: #selector(mailReport))
    }
    
    @objc func mailReport() {
        if let fileData = viewModel.reportData {
            if( MFMailComposeViewController.canSendMail() ) {
                let mailComposer = MFMailComposeViewController()
                mailComposer.mailComposeDelegate = self
                mailComposer.setSubject("Daily Log report")
                mailComposer.addAttachmentData(fileData, mimeType: "application/pdf", fileName: "DailyLogReport.pdf")
                self.present(mailComposer, animated: true, completion: nil)
            }
        }
    }
}

extension ReportViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
}

extension ReportViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        ProgressHUD.showError("Something went wrong, please try again.")
    }
}

class ReportViewModel {
    var dailyLogId: Int = 0
    var reportData: Data?
    private let apiService = ProjectAPI()
    
    func getReport(onSuccess: @escaping() -> (), onError: @escaping(Bool) -> ()) {
        apiService.report(dailyLogId: dailyLogId) {[weak self] response in
            switch response.result {
            case .success(let data):
                self?.reportData = data
                onSuccess()
            case .failure(let error):
                onError(error.isSessionTaskError)
            }
        }
    }
}
