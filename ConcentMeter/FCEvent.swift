//
//  FCEvent.swift
//  ConcentMeter2
//
//  Created by tanabe on 2014/12/22.
//  Copyright (c) 2014年 Addon Inc. All rights reserved.
//

import Foundation
import Realm

class FCEvent : RLMObject{
    
    dynamic var datetime = ""
	dynamic var faceRate:Float  = 0.0
}

