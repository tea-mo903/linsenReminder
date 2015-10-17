//
//  ViewController.swift
//  LinsenReminder
//
//  Created by Timo Knapp on 28.09.15.
//  Copyright © 2015 Timo Knapp. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource  {

    @IBOutlet var intervallLabel: UILabel!
    @IBOutlet var intervallPicker: UIPickerView!

    var intervallPickerData: [String] = [String]()
    
    @IBAction func btnSetIntervall(sender: AnyObject) {
//        StartDate
        self.startDate = beginnPicker.date
        
//        Intervall
        let dayComponent: NSDateComponents = NSDateComponents.init()
        dayComponent.day = self.intervall
        
//        NextReminder
        self.nextReminder = NSCalendar.currentCalendar().dateByAddingUnit(
            .Day,
            value: dayComponent.day,
            toDate: startDate,
            options: NSCalendarOptions(rawValue: 0))!
        
        self.nextReminder = setReminderTime(self.nextReminder)
        let nextDateString = formatDateToString(nextReminder)
        
        let linsenItem = LinsenItem(startDate: beginnPicker.date, intervall: self.intervall, nextReminder: self.nextReminder)
        
        compareNewReminderToRecent(linsenItem)
        
//        set Content for NextDate TextField
        self.nextData.text = nextDateString as String
        
//        defaults.setObject(startDate, forKey: "start")
//        defaults.setInteger(intervall, forKey: "intervall")
//        defaults.setObject(nextReminder, forKey: "next")
        
        print(nextDateString)
    }
    @IBOutlet var beginnLabel: UILabel!
    @IBOutlet var beginnPicker: UIDatePicker!
    @IBOutlet var nextLabel: UILabel!
    @IBOutlet var nextData: UILabel!
    
    var startDate: NSDate!
    var intervall: Int!
    var nextReminder: NSDate!
    
    private let LINSEN_REMINDER_KEY = "linsenReminder"
    private let START_KEY = "startDate"
    private let INTERVALL_KEY = "intervall"
    private let NEXT_KEY = "nextReminder"
    
    var linsenReminderItem: LinsenItem = LinsenItem()
    
    func compareNewReminderToRecent(newReminderItem: LinsenItem) {
        let recentReminderItem: LinsenItem = getRecentReminder()
        
        // delete recentReminder
        for notification in UIApplication.sharedApplication().scheduledLocalNotifications as [UILocalNotification]! { // loop through notifications...
            if (notification.userInfo!["start"] as! NSDate == recentReminderItem.startDate) { // ...and cancel the notification that corresponds to this TodoItem instance (matched by startdate)
                print("delete notification: \(notification.userInfo)")
                UIApplication.sharedApplication().cancelLocalNotification(notification) // there should be a maximum of one match on UUID
                break
            }
        }
        // add newReminder
        addNewReminder(newReminderItem)
    }
    
    func addNewReminder(linsenReminderItem: LinsenItem) {
       var defaultLinsenReminder = NSUserDefaults.standardUserDefaults().dictionaryForKey(LINSEN_REMINDER_KEY) ?? Dictionary()
        
        defaultLinsenReminder[LINSEN_REMINDER_KEY] = [START_KEY: linsenReminderItem.startDate, INTERVALL_KEY: linsenReminderItem.intervall, NEXT_KEY: linsenReminderItem.nextReminder]
        NSUserDefaults.standardUserDefaults().setObject(defaultLinsenReminder, forKey: LINSEN_REMINDER_KEY)
        
        let reminderDateAsString = formatDateToString(linsenReminderItem.nextReminder) as String
        // create a corresponding local notification
        let notification = UILocalNotification()
        notification.alertBody = "Kontaktlinsen tauschen am \"\(reminderDateAsString)" // text that will be displayed in the notification
        notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
        notification.fireDate = linsenReminderItem.nextReminder // todo item due date (when notification will be fired)
        notification.soundName = UILocalNotificationDefaultSoundName // play default sound
        notification.userInfo = ["start": linsenReminderItem.startDate, ] // assign a unique identifier to the notification so that we can retrieve it later
        notification.category = "KontaktlinsenReminder"
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    func setReminderTime(dateObj: NSDate) -> NSDate {
        
        var tempDate: NSDate = dateObj
        
        tempDate = NSCalendar.currentCalendar().dateBySettingHour(7, minute: 0, second: 0, ofDate: dateObj, options: NSCalendarOptions(rawValue: 0))!
        
        return tempDate
    }
    
    func getRecentReminder() -> LinsenItem {
        let defaultLinsenReminder = NSUserDefaults.standardUserDefaults().dictionaryForKey(LINSEN_REMINDER_KEY) ?? [:]
        let items = Array(defaultLinsenReminder.values)
        var firstItem: LinsenItem = LinsenItem()
        
        if (items.count == 0) {
            return firstItem
        } else {
            var linsenItems: [LinsenItem]
            linsenItems = items.map({LinsenItem(startDate: $0[START_KEY] as! NSDate, intervall: $0[INTERVALL_KEY] as! Int, nextReminder: $0[NEXT_KEY] as! NSDate)})
            
            
            firstItem = linsenItems[0]
            
            print("getRecentReminder - Intervall: \(firstItem.intervall)")
            print("getRecentReminder - StartDate: \(firstItem.startDate)")
            print("getRecentReminder - NextReminder: \(firstItem.nextReminder)")
            
            return firstItem
        }
    }
    
    func formatDateToString(date: NSDate) -> NSString {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        let nextDateString = dateFormatter.stringFromDate(date)
        
        return nextDateString
    }

    func updateUIWithCurrentValues(item: LinsenItem) {
//        intervallPicker.
        for row in 0...2 {
            let intervallInt = Int(intervallPickerData[row])
            if (intervallInt == item.intervall) {
                intervallPicker.selectRow(row, inComponent: 0, animated: false)
            }
        }
            
        beginnPicker.setDate(item.startDate, animated: false)
        nextData.text = formatDateToString(item.nextReminder) as String
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.intervallPicker.delegate = self
        self.intervallPicker.dataSource = self
        
        intervallPickerData = ["1", "14", "30"]
        
        //linsenReminderItem = getRecentReminder()
        
//        if (linsenReminderItem.intervall != 0)  {
//            self.startDate = linsenReminderItem.startDate
//            self.intervall = linsenReminderItem.intervall
//            self.nextReminder = linsenReminderItem.nextReminder
//            updateUIWithCurrentValues(linsenReminderItem)
//            print("ViewDidLoad - Intervall: \(linsenReminderItem.intervall)")
//            print("ViewDidLoad - StartDate: \(linsenReminderItem.startDate)")
//            print("ViewDidLoad - NextReminder: \(linsenReminderItem.nextReminder)")
//        }
//        
//        
//        if (nextReminder != nil) {
//            let now = NSDate().timeIntervalSince1970
//            let next = nextReminder.timeIntervalSince1970
//            let dayComponent: NSDateComponents = NSDateComponents.init()
//            dayComponent.day = self.intervall
//            
//            if(now > next) {
//                self.nextReminder = NSCalendar.currentCalendar().dateByAddingUnit(
//                    .Day,
//                    value: dayComponent.day,
//                    toDate: nextReminder,
//                    options: NSCalendarOptions(rawValue: 0))!
//            }
//        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(false)
        linsenReminderItem = getRecentReminder()
        
        if (linsenReminderItem.intervall != 0)  {
            self.startDate = linsenReminderItem.startDate
            self.intervall = linsenReminderItem.intervall
            self.nextReminder = linsenReminderItem.nextReminder
            updateUIWithCurrentValues(linsenReminderItem)
            print("ViewDidAppear - Intervall: \(linsenReminderItem.intervall)")
            print("ViewDidAppear - StartDate: \(linsenReminderItem.startDate)")
            print("ViewDidAppear - NextReminder: \(linsenReminderItem.nextReminder)")
        }
        
        if (nextReminder != nil) {
            let now = NSDate().timeIntervalSince1970
            let next = nextReminder.timeIntervalSince1970
            let dayComponent: NSDateComponents = NSDateComponents.init()
            dayComponent.day = self.intervall
            
            if(now > next) {
                self.nextReminder = NSCalendar.currentCalendar().dateByAddingUnit(
                    .Day,
                    value: dayComponent.day,
                    toDate: nextReminder,
                    options: NSCalendarOptions(rawValue: 0))!
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }

    // The number of columns of data
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(intervallPicker: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return intervallPickerData.count
    }
    
//    // The data to return for the row and component (column) that's being passed in
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return intervallPickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        // selected value in Uipickerview in Swift
        let value: Int? = Int(intervallPickerData[row])
        print("values:----------\(value)");
        self.intervall = value!
        
    }
    
}

