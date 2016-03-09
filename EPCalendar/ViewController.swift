//
//  ViewController.swift
//  EPCalendar
//
//  Created by Prabaharan Elangovan on 02/11/15.
//  Copyright © 2015 Prabaharan Elangovan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, EPCalendarPickerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewWillAppear(animated: Bool) {
        let CalendarView = EPCalendarPicker(startYear: 2016, endYear: 2017, multiSelection: false, selectedDates: [], frame: self.view.frame)
        CalendarView.multiSelectEnabled = true
        CalendarView.calendarDelegate = self
        self.view.addSubview(CalendarView)
    }
    
    func epCalendarPicker(calendar: EPCalendarPicker, didSelectMultipleDate dates: [NSDate]) {
        print("SELECTED\(dates.count)")
    }
    
    func epCalendarPicker(calendar: EPCalendarPicker, didDeselectDate date: NSDate) {
        print("DESELECT \(date)")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

