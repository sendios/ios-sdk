//
//  Sendios.swift
//  Sendios
//
//  Created by Oleksandr Liashko on 30.03.2021.
//  Copyright © 2021 Oleksandr Liashko. All rights reserved.
//

import UIKit
import Foundation
import UserNotifications

/**
 Sendios iOS SDK.
 
 Use the Sendios SDK to design and send push notifications,
 track and report events occurred in your application.
 
 Developers using the Sendios SDK with their app are required to register for
 a credential, and to specify these credentials (appId, clientId, clientToken) in their application.
 Failure to do so results in blocked access to certain features and degradation
 in the quality of other services.
 
 To obtain these credentials, visit the developer portal at https://api.sendios.io/dev
 and register for a license.
 
 - Note: Credentials are unique to your application's bundle identifier.
 Do not reuse credentials across multiple applications.
 
 Adding Credentials
 
 Ensure that you have provided the appId, clientId, clientToken before using the Sendios SDK.
 For example, set them in your app delegate:
 
 ```
 func application(_ application: UIApplication,
 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    Sendios.initializeWithLaunchOptions(launchOptions, appId: 'YOUR_APP_ID', clientId: 'YOUR_CLIENT_ID',  clientToken: 'YOUR_APP_CODE')
 }
 ```
 */
public final class Sendios : NSObject {
    
    /**
     Initialize the mandatory Sendios SDK Credentials notably App Id
     
     - Parameters:
        - launchOptions: A dictionary indicating the reason the app was launched (if any). The contents of this dictionary may be empty in situations where the user launched the app directly.
        - appId: Sendios SDK App Id obtained from developer portal at https://api.sendios.io
        - clientId: Sendios SDK Client Id obtained from developer portal at https://api.sendios.io
        - clientToken: Sendios SDK App Key obtained from developer portal at https://api.sendios.io
        - appVersion: Application version
     */
    @objc public static func initializeWithLaunchOptions(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?,
                                                         appId: String,
                                                         clientId : String,
                                                         clientToken: String,
                                                         appVersion: String? = nil) {
        ApproverEngine.shared.initialize(launchOptions: launchOptions,
                                         appId: appId,
                                         clientId: clientId,
                                         clientToken: clientToken,
                                         appVersion: appVersion)
    }
    
    /**
     Prompt Users to Enable Notifications
     
     - Warning: Assigning UNUserNotificationCenterDelegate delegate after these methods are called, otherwise might cause you to miss incoming notifications. The delegate will be proxied object, it won't be the same as has been assigned.
     
     - Parameters:
        - options: Constants for requesting authorization to interact with the user. By default the constatns are alert, sound, badge.
        - userResponce: The block to execute asynchronously with the results. This block may be executed on a background thread. The block has no return value and has the following parameters:
        - granted: A Boolean value indicating whether authorization was granted. The value of this parameter is true when authorization was granted for one or more options. The value is false when authorization is denied for all options.
     
     - Tag: promptForPushNotifications
    */
    @objc public static func promptForPushNotifications(options: UNAuthorizationOptions = [.alert, .sound, .badge],
                                                        userResponce: @escaping (_ granted: Bool) -> () = { _ in }) {
        
        ApproverEngine.shared.promptForPushNotifications(options: options,
                                                         userResponce: userResponce)
    }
    
    /**
     A globally unique token that identifies this device to APNs, Firebase or any other push services.
     
     - Important: If app doesn't use Sendios [promptForPushNotifications(options:userResponce)](x-source-tag://promptForPushNotifications) approach
                  then the pushToken has to be installed manually once APNs push token has received in some other way
     
     - Note: Example: In case if app handles push token registration himself
     ```
     func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        Sendios.shared.pushToken(.apns(tokenParts.joined()))
     }
     ```
     
     - Parameters:
        - token: Push token with its [service type](x-source-tag://PushTokenType)
     
     - Tag: pushToken
     */
    public static func pushToken(_ token: PushToken?) {
        ApproverEngine.shared.pushToken(token)
    }
    
    /**
     Log an event.
     
     - Parameters:
        - name The name of the event to be tracked
        - value Arbitrary value to be tracked
     */
    public static func logEvent(_ name: String, value: String) {
        ApproverEngine.shared.logEvent(name, value)
    }
    
    /**
     Log a push info payload.
     
     - Note: If there is any impl of UNUserNotificationCenterDelegate then use the method insdie callbacks
     to notify about a push notification being recieved.
     
     - Parameters:
        - pushPayload The push notification payload has been received
     */
    public static func logPush(pushPayload: [AnyHashable : Any]) {
        ApproverEngine.shared.logPush(pushPayload: pushPayload)
    }
    
    /**
     Log an unseen push info payload.
     
     - Note: If there is any impl of UNUserNotificationCenterDelegate.userNotificationCenter(_:willPresent:withCompletionHandler:)
     and a push notification won't be shown as an app in foreground then use the method inside the callback to notify about the push notification
     being recieved but unseen.
     
     - Parameters:
        - pushPayload The push notification payload has been received
     */
    public static func logUnseenPush(pushPayload: [AnyHashable : Any]) {
        ApproverEngine.shared.logUnseenPush(pushPayload: pushPayload)
    }
    
    /**
     Log a user's email and unique id if any
     
     - Warning: The data is requred to help to optimize an app experience
     by making it easy to analyze and scale product and marketing experiments. If both params are nil, no requests are performed.
     
     - Parameters:
        - email User's email. Can be nil if there is no any.
        - userId User unique identifier. Can be nil if there is no any.
    */
    public static func logUser(email: String? = nil, userId : String? = nil) {
        ApproverEngine.shared.logUser(email: email, userId: userId)
    }

    /**
     Log user's custom fields
     
     - Warning: The data is required to help to optimize an app experience
     by making it easy to analyze and scale product and marketing experiments. If fields param is empty, no requests are performed.
     
     - Parameters:
        - fields User's fields. Any.
    */
    public static func logUserFields(_ fields: [String: String]) {
        ApproverEngine.shared.logUserFields(fields)
    }
    
    /**
     Changes how notifications display while app in foreground
     
     - Warning: The parameter doesn't have any impact if you have overridden UNUserNotificationCenterDelegate.userNotificationCenter(_:willPresent:withCompletionHandler:))
     
     - Parameters:
        - type Use the [type](x-source-tag://NotificationDisplayType) parameter to specify how you want the system to alert the user, if at all
     */
    public static var inFocusDisplayType : NotificationDisplayType {
        get { ApproverEngine.shared.inFocusDisplayType }
        set { ApproverEngine.shared.inFocusDisplayType = newValue }
    }
    
    /// Opt users in or out of receiving notifications
    public static var subscription : Bool {
        get { ApproverEngine.shared.subscription }
        set { ApproverEngine.shared.subscription = newValue }
    }
    
} // class Sendios

public extension Sendios {
    
    /**
        Ensure that you have provided the appId, clientId, clientToken before using the Sendios SDK.
        Set them in your push notification extension app delegate
     
        - Warning: The method is only for invoking from push notificaiton extension
     
        Initialize the mandatory Sendios SDK Credentials notably App Id
     
        - Parameters:
            - appId: Sendios SDK App Id obtained from developer portal at https://api.sendios.io
            - clientId: Sendios SDK Client Id obtained from developer portal at https://api.sendios.io
            - clientToken: Sendios SDK App Key obtained from developer portal at https://api.sendios.io
     
        ```
        override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
            Sendios.initialize(appId: 'YOUR_APP_ID', clientId: 'YOUR_CLIENT_ID',  clientToken: 'YOUR_APP_CODE')
            ...
        }
        ```
     */
    static func initialize(appId: String, clientId : String, clientToken: String) {
        ApproverEngine.shared.initialize(appId: appId,
                                         clientId: clientId,
                                         clientToken: clientToken)
        
        
    }

    
    /**
     Parses an APS push payload
     
     Useful to call from your NotificationServiceExtension.
     
     - Parameters:
        - request: The original notification request. This object is used to get the original content of the notification.
        - content: A UNNotificationContent object with the content to be displayed to the user.
     */
    static func didReceiveNotificationExtensionRequest(_ request: UNNotificationRequest, with content : UNMutableNotificationContent) {
        ApproverEngine.shared.didReceiveNotificationExtensionRequest(request, with: content)
    }
    
    /**
     An opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
     
     Useful to call from your NotificationServiceExtension.
     
     - Parameters:
        - request: The original notification request. This object is used to get the original content of the notification.
        - content: A UNNotificationContent object with the content to be displayed to the user.
     */
    static func serviceExtensionTimeWillExpire(_ request: UNNotificationRequest, with content: UNMutableNotificationContent) {
        ApproverEngine.shared.serviceExtensionTimeWillExpire(request, with: content)
    }
}


// UNNotificationResponse().notification.request.content.userInfo

