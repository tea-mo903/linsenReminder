//
//  LinsenReminderItem.swift
//  LinsenReminder
//
//  Created by Timo Knapp on 12.10.15.
//  Copyright © 2015 Timo Knapp. All rights reserved.
//

import Foundation

struct LinsenItem {
    var startDate: NSDate
    var intervall: Int
    var nextReminder: NSDate
    
    init(startDate: NSDate, intervall: Int, nextReminder: NSDate) {
        self.startDate = startDate
        self.intervall = intervall
        self.nextReminder = nextReminder
    }
    
    init() {
        self.startDate = NSDate.init()
        self.intervall = 0
        self.nextReminder = NSDate.init()
    }
}