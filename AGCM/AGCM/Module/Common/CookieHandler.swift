//
//  CookieHandler.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 27/01/23.
//

import Foundation
import Alamofire

class CookieHandler {
    
    let cookiesKey = "UserSessionCookie"
    
    static let shared: CookieHandler = CookieHandler()
    
    let defaults = UserDefaults.standard
    let cookieStorage = HTTPCookieStorage.shared
    
    func getCookie(forURL url: String) -> [HTTPCookie] {
        let computedUrl = URL(string: url)
        let cookies = cookieStorage.cookies(for: computedUrl!) ?? []
        
        return cookies
    }
    
    func backupCookies(forURL url: String) -> Void {
        var cookieDict = [String : AnyObject]()
        for cookie in self.getCookie(forURL: url) {
            cookieDict[cookie.name] = cookie.properties as AnyObject?
        }
        defaults.set(cookieDict, forKey: cookiesKey)
    }
    
    func restoreCookies() {
        if let sessionCookie = getSessionCookie() {
            cookieStorage.setCookie(sessionCookie)
            AF.session.configuration.httpCookieStorage?.setCookie(sessionCookie)
        }
    }
    
    func getSessionCookie() -> HTTPCookie? {
        if let cookieDictionary = defaults.dictionary(forKey: cookiesKey) {
            for (_, cookieProperties) in cookieDictionary {
                if let cookie = HTTPCookie(properties: cookieProperties as! [HTTPCookiePropertyKey : Any] ) {
                   return cookie
                }
            }
        }
        return nil
    }
    
    func clearCookies() {
        if let sessionCookie = getSessionCookie() {
            cookieStorage.deleteCookie(sessionCookie)
            AF.session.configuration.httpCookieStorage?.deleteCookie(sessionCookie)
        }
        defaults.removeObject(forKey: cookiesKey)
    }
}
