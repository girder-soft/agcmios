//
//  UserDefaultsManager.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 27/01/23.
//

import Foundation

class UserDefaultsManager {
    enum Keys: String, CaseIterable {
        case isUserLogin, userId, userName, userEmail
    }
    
    static let shared = UserDefaultsManager()
    let userDefault: UserDefaults
    private init() {
        userDefault = UserDefaults.standard
    }
    
    var isUserLoggedIn: Bool {
        userDefault.bool(forKey: Keys.isUserLogin.rawValue)
    }
    
    var userId: Int {
        userDefault.integer(forKey: Keys.userId.rawValue)
    }
    
    func setUserId(id: Int, name: String) {
        userDefault.set(true, forKey: Keys.isUserLogin.rawValue)
        userDefault.set(id, forKey: Keys.userId.rawValue)
        userDefault.set(name, forKey: Keys.userName.rawValue)
    }
    
    func setUser(name: String, email: String) {
        userDefault.set(name, forKey: Keys.userName.rawValue)
        userDefault.set(email, forKey: Keys.userEmail.rawValue)
    }
    
    func getUserName() -> String {
        return userDefault.string(forKey: Keys.userName.rawValue) ?? ""
    }
    
    func getUserEmail() -> String {
        return userDefault.string(forKey: Keys.userEmail.rawValue) ?? ""
    }
    
    func resetUser() {
        Keys.allCases.forEach { userDefault.removeObject(forKey: $0.rawValue) }
        CookieHandler.shared.clearCookies()
    }
    
}
