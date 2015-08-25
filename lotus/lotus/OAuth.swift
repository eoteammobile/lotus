//
//  OAuth.swift
//  lotus
//
//  Created by Jacob Macdonald on 8/24/15.
//
//

import Foundation
import OAuthSwift

//Consumer key, consumer secret for twitter. Will probably change for production.
let cKey = "y7Qc5rO9Fl4qWgqQsk1OR6Pjp", cSecret = "lV184NQxR2rUcKQbjYdeYHq1L3J1wvTC9jOK93DhGLOCGTxcrH";

let oauthswift = OAuth1Swift(
    consumerKey:    cKey,
    consumerSecret: cSecret,
    requestTokenUrl: "https://api.twitter.com/oauth/request_token",
    authorizeUrl:    "https://api.twitter.com/oauth/authorize",
    accessTokenUrl:  "https://api.twitter.com/oauth/access_token"
)

let prefs = NSUserDefaults.standardUserDefaults()

/*****************************************
* Represents data associated with user
*****************************************/
class User {
    
    //User identifier, e.g. email
    var identifier: String
    
    init() {
        identifier = User.getUserIdentifier()
        println(identifier)
    }
    
    /*****************************************
    * Run at startup to skip login screen
    * Returns login status and provider
    *****************************************/
    class func isLoggedIn() -> (status: Bool, method: String) {
        if Facebook.isLoggedIn() {
            return (true, "facebook")
        }
        else if Twitter.isLoggedIn() {
            return (true, "twitter")
        }
        else if Gtherer.isLoggedIn() {
            return (true, "gtherer")
        }
        else {
            return (false, "")
        }
    }
    
    class func logout() {
        Facebook.logout()
        Twitter.logout()
        Gtherer.logout()
    }
    
    /*****************************************
    * Returns sotred user identifier, e.g. email
    *****************************************/
    class func getUserIdentifier() -> String {
        if(prefs.stringForKey("identifier") == nil) { prefs.setValue("temp_username", forKey: "identifier") }//TEMP
        return prefs.stringForKey("identifier")!
    }
}


/*****************************************
* Represents different login types
*****************************************/
protocol Account {
    static func login()
    static func logout()
    static func isLoggedIn() -> Bool
    static func storeUserInfo()
}

class Facebook : Account {
    
    static func login() {
        //Handled by Facebook login button
    }
    
    static func logout() {
        //Handled by Facebook login button
    }
    
    static func isLoggedIn() -> Bool {
        return false
    }
    
    static func storeUserInfo() {
        
    }
}

class Twitter : Account {
    
    static func isLoggedIn() -> Bool {
        return prefs.stringForKey("auth_token_secret") != nil
    }
    
    static func login() {
        oauthswift.authorizeWithCallbackURL( NSURL(string: "oauth-swift://oauth-callback/twitter")!,
            success: { credential, response in
                let auth_token = credential.oauth_token, auth_token_secret = credential.oauth_token_secret
                prefs.setValue(auth_token, forKey: "auth_token")
                prefs.setValue(auth_token_secret, forKey: "auth_token_secret")
                Twitter.storeUserInfo()
                println("Twitter logged in")
            }, failure: { (error:NSError!) -> Void in
                println(error.localizedDescription)
            }
        )
    }
    
    static func logout() {
        prefs.removeObjectForKey("auth_token")
        prefs.removeObjectForKey("auth_token_secret")
        println("Twitter logged out")
    }
    
    static func storeUserInfo() {
        var parameters =  Dictionary<String, AnyObject>()
        oauthswift.client.get("https://api.twitter.com/1.1/account/verify_credentials.json", parameters: parameters,
            success: {
                data, response in
                let jsonDict: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil)
                prefs.setValue(jsonDict["name"]!! as! String, forKey: "name")
                prefs.setValue(jsonDict["screen_name"]!! as! String, forKey: "identifier")
                user = User()
            }, failure: {(error:NSError!) -> Void in
                println(error)
        })
    }
}

class Gtherer : Account {
    
    static func login() {
        
    }
    
    static func logout() {
        
    }
    
    static func isLoggedIn() -> Bool {
        return false
    }
    
    static func storeUserInfo() {
        
    }
}