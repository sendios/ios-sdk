//
//  NotificationDisplayType.swift
//  Approver
//
//  Created by Oleksandr Liashko on 21.04.2020.
//  Copyright © 2020 Oleksandr Liashko. All rights reserved.
//

import Foundation


/**
 Constants indicating how to present a notification in a foreground app.
 
 - Tag: NotificationDisplayType
*/
public enum NotificationDisplayType {
    /*Notification is silent and not shown (default)*/
    case none
    /*Badge, Sound, Alert*/
    case `default`
}
