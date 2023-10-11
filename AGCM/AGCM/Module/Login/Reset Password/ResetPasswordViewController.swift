//
//  ResetPasswordViewController.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 26/01/23.
//

import UIKit
import ProgressHUD

class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    let viewModel = LoginViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func resetPasswordButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty else {
            ProgressHUD.showError("Enter valid email")
            return
        }
        self.sendResetPassword(email: email)
    }
    
    @IBAction func loginButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    private func sendResetPassword(email: String) {
        ProgressHUD.show()
        viewModel.resetPassword(email: email) {[weak self] in
            ProgressHUD.showSuccess("Reset password link send to your email")
            self?.dismiss(animated: true)
        } onError: {error in
            if error == .invalidCredentials {
                ProgressHUD.showError("Please enter valid credentials")
            } else if error == .noInternet {
                ProgressHUD.showError("No Internet connection")
            } else {
                ProgressHUD.showError("Something went wrong, please try again.")
            }
        }
    }
}
