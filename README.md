# Sendios SDK for iOS apps
Email Marketing and Push platform for your key product metrics https://sendios.io

- [Introduction](#introduction)
- [Installation](#installation)
- [Adding Credentials](#adding-credentials)
- [Init SDK](#init-sdk)
- [Attach User](#attach-user)
- [Push Notifications](#push-notifications)
  - [iOS Push Prompting](#ios-push-prompting)
  - [Push Token](#push-token)
  - [Rich Push for images and delivered](#rich-push)
  - [Click tracking](#click-tracking)
  - [Unseen tracking](#unseen-tracking)
  - [Unsubscribe in app](#unsubscribe)
  - [Push Notification Payload](#push-notification-payload)
  - [App-push SDK data transfer](#app-push-sdk-data-transfer)

# Introduction
Use the Sendios SDK to design and send push notifications, track and report events occurred in your application.
Developers using the Sendios SDK with their app are required to register for a credential, and to specify the credential (apiKey) in their application. Failure to do so results in blocked access to certain features and degradation in the quality of other services.
To obtain these credentials, visit the developer portal at https://sendios.io and register for a license.
Credentials are unique to your application's bundle identifier. Do not reuse credentials across multiple applications.

# Installation
Requirements
```
- iOS 10.0+
- Xcode 10.2+
- Swift 5+
```

By dependency manager *CocoaPods* (https://cocoapods.org)
To integrate Sendios into your Xcode project using CocoaPods, specify it in your `Podfile`:
```ruby
pod 'Sendios'
```

By *Swift Package Manager* (https://swift.org/package-manager/)
To integrate Sendios into your Xcode project using Swift Package Manager, specify git-hub link `https://github.com/sendios/ios-sdk`


If you prefer integrate manually:
- Download SDK for iOS package from this repo: Sendios.framework folder.
- Add the Sendios dynamic framework to your Xcode project. Click on your app target and choose the "General" tab. Find the section called "Embedded Binaries", click the plus (+) sign, and then click the "Add Other" button. From the file dialog box select "Sendios.framework" folder. Ensure that "Copy items if needed" and "Create folder reference" options are selected, then click Finish.
- Ensure that Sendios.framework appears in "Embedded Binaries" and the "Linked Frameworks and Libraries" sections.
- Run the application. Ensure that the project runs in iOS without errors.
SDK for iOS is now ready for use in your Xcode project. Now that you have your project configured to work with Sendios SDK


# Adding Credentials
For using Sendios platform you must provide credentials of your account and current app.
You can find them at admin panel or request them from your account manager.
Example:
```
clientId: 7345
clientToken: uawhvnkaeuvyagbwyeuvgbayw
appId: 837465 (aka projectId)
```
Next provide this credentials at library launch:

# Init SDK
Also creates session in analytics

```swift
import Sendios

func application(_ application: UIApplication,
didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
   Sendios.initializeWithLaunchOptions(launchOptions, appId: 'YOUR_APP_ID', clientId: 'YOUR_CLIENT_ID',  clientToken: 'YOUR_CLIENT_TOKEN')
}
```

# Attach User
For all methods in SDK we match user by [IDFV](https://developer.apple.com/documentation/uikit/uidevice/1620059-identifierforvendor)<br>
Additional you can provide more product information for analytics and etc.
- you aren't required to provide PushToken before that method

- **email** - better provide after validation https://github.com/sendios/php-sdk#check-email
- **userId** - id on your product

```swift
Sendios.logUser(email: "some@gmail.com", userId: userId)
```

Log a user's custom fields
- **fields** - User's fields. Any.
```swift
Sendios.logUserFields(["gender":"female", "email.second":"some2@gmail.com"])
```

# Push Notifications

## iOS Push Prompting
iOS Apps have a native prompt that users click "Allow" to subscribe to push. You can use the below methods to trigger that prompt in your app.

```
Warning: Use that method if no other third party or native lib do not invoke method to prompt for push permissions.
If Firebase is used for instance, just skip that section.
```

```swift
import Sendios

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
  ...
  Sendios.promptForPushNotifications { granted in
    if granted {
      ...
    } else {
      ...
    }
  }
  ...
}

// Within native UIApplicationDelegate callback pass apns token to Sendios server
func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
  let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
  let token = tokenParts.joined()
  Sendios.shared.pushToken(.apns(token))
}

```

## Push Token

Pass a **Firebase** registration token to Sendios beckend by using
```swift
Sendios.shared.pushToken(.firebase(token))
```
Note: Make sure that you have passed Firebase server key to Sendios team, otherwise no pushes are going to be delivered.

Pass an **APNS** registration token to Sendios beckend by using
```swift
Sendios.shared.pushToken(.apns(token))
```

## Rich Push
The Sendios allows your iOS application to receive rich notifications with images, and badges.<br>
It's also sends **delivered** event to analytics by didReceiveNotificationExtensionRequest.<br>

All that have to be done is introduce Notification Service Extension and invoke corresponding Sendios methods.

```swift
import UserNotifications
import Sendios

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    var receivedRequest: UNNotificationRequest!

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {

        let APP_ID : String = "XXXXX"
        let APP_CLIENT_ID : String = "XXXXX"
        let APP_CODE: String = "XXXXXXXXXXXXXXXXXX"
        Sendios.initialize(appId: APP_ID, clientId: APP_CLIENT_ID, clientToken: APP_CODE)

        self.receivedRequest = request
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            bestAttemptContent.title = "\(bestAttemptContent.title) [modified]"
            Sendios.didReceiveNotificationExtensionRequest(self.receivedRequest, with: bestAttemptContent)

            contentHandler(bestAttemptContent)
        }
    }

    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            Sendios.serviceExtensionTimeWillExpire(self.receivedRequest, with: bestAttemptContent)
            contentHandler(bestAttemptContent)
        }
    }
}

```

## Click tracking

It's required for Sendios's analytics features.
Log a push info of recieved payload.

```swift
extension PushNotificationHelper : UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        Sendios.logPush(pushPayload: userInfo)

        completionHandler()
    }
}

```

## Unseen tracking
If there is any impl of UNUserNotificationCenterDelegate.userNotificationCenter(\_:willPresent:withCompletionHandler:) and a push notification won't be shown as an app in foreground then use the method inside the callback to notify about the push notification being recieved but unseen.

```swift
extension PushNotificationService : UNUserNotificationCenterDelegate {
    // foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        ....
        // log push info code if push won't be shown
        Sendios.logUnseenPush(pushPayload: notification.request.content.userInfo)
        completionHandler([])
    }
```

## Unsubscribe

The user must first subscribe through the native prompt or app settings. It does not officially subscribe or unsubscribe them from the app settings, it unsubscribes them from receiving push from Sendios.
You can only call this method with false to opt out users from receiving notifications through Sendios. You can pass true later to opt users back into notifications.

```swift
Sendios.subscription = false
```

## Push Notification Payload
Payload Key Reference.
Table lists the keys that payload may include.

|Key                  |Value type    |  Description     |
|---------------------|:------------:| -----------------
|data                 |Dictionary    | Data messages have only custom key-value pairs with no reserved key names
|notification         |Dictionary    | Have a predefined set of user-visible keys and an optional data payload of custom key-value pairs.

Table lists the keys that you may receive in the data Dictionary.

|Key                  | Value type   |     Description  |
|---------------------|:------------:| -----------------
|push_id              |String        |  Sender id information
|type                 |String        |  Might be any. For instance 'route'
|route                |String        |  null|chat|profile|correspondence|dialogs|search|me|credits|welcome-package|activity
|from_user_id         |String        |  For route type only. chat|profile|correspondence, otherwise is null
|image_url            |String        |  The name of the launch image file to display.
|sender_id            |String        |  It is platform specific option. For iOS by default is 2.
|logic_id             |String        |  Logic identifier
|template_id          |String        |  Template's name
|mf_split_group       |String        |  Split group name. By default is nil.

Table lists the keys that you may receive in the notification Dictionary.

|Key                  | Value type   |     Description  |
|---------------------|:------------:| -----------------
|title                | String       |   The title of the notification.
|body                 | String       |   Additional information that explains the purpose of the notification.
|badge                | Number       |   The number to display in a badge on your app’s icon.

## App-push SDK data transfer
|#                  | Request type   |  Request path  | Critical | Description |
|---------------------|:------------:| --------------- | :-------: |:---:|
|1                   | POST          |   /api/v1/app/init | NO | - |
|2                   | POST          |   /api/v1/app/user | YES | Hacker can create new push user or update  if : 1)know user email 2) steal auth data from app. |
|3                   | POST          |   /api/v1/app/push/unseen | NO | It is not critical if firebase  doesn't contain critical data |
|4                   | POST          |   /api/v1/app-push/send | NO | - |
|5                   | POST          |   /api/v1/app/user/token | NO | - |
|6                   | POST          |   /api/v1/app/push/delivered | NO | - |
|7                   | POST          |   /api/v1/app/push/click | NO | - |
|8                   | POST          |   /api/v1/app/event | NO | - |
|9                   | PUT          |   /api/v1/app/devices/subscribes | NO | - |
