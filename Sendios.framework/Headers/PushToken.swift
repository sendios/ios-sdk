//
//  PushToken.swift
//  Approver
//
//  Created by Oleksandr Liashko on 02.04.2020.
//  Copyright © 2020 Oleksandr Liashko. All rights reserved.
//

import Foundation

/**
 Token that identifies this device to push services
 
 - Tag: PushTokenType
*/
public enum PushToken {
    /** APNs token */
    case apns(token: String)
    /** Firebase token */
    case firebase(token: String)
    /** Custom service token */
    case custom(token: String, serviceDesc: Dictionary<String, String>)
}
