//
//  ShareClass.swift
//  MicBlow
//
//  Created by deepak mishra on 15/12/14.
//  Copyright (c) 2014 cellcity. All rights reserved.
//

import UIKit

class ShareClass: NSObject {

    class var sharedInstance: ShareClass {
         struct Static {
            static var once_token: dispatch_once_t = 0
            static var instance  : ShareClass?
        }
        dispatch_once(&Static.once_token) {
            Static.instance = ShareClass()
        }
        return Static.instance!
    }
}
