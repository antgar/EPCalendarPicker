//
//  EPCalendarPicker.swift
//  EPCalendar
//
//  Created by Prabaharan Elangovan on 02/11/15.
//  Copyright © 2015 Prabaharan Elangovan. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

@objc public protocol EPCalendarPickerDelegate{
    optional    func epCalendarPicker(calendar: EPCalendarPicker, didCancel error : NSError)
    optional    func epCalendarPicker(calendar: EPCalendarPicker, didSelectDate date : NSDate)
    optional    func epCalendarPicker(calendar: EPCalendarPicker, didSelectMultipleDate dates : [NSDate])
    optional    func epCalendarPicker(calendar:EPCalendarPicker, didDeselectDate date : NSDate)
}

public class EPCalendarPicker: UICollectionView,UICollectionViewDataSource,UICollectionViewDelegate{

    public var calendarDelegate : EPCalendarPickerDelegate?
    public var multiSelectEnabled: Bool
    public var showsTodaysButton: Bool = true
    private var arrSelectedDates = [NSDate]()
    
    public var dayDisabledTintColor: UIColor
    public var weekdayTintColor: UIColor
    public var weekendTintColor: UIColor
    public var todayTintColor: UIColor
    public var dateSelectionColor: UIColor
    public var monthTitleColor: UIColor
    
    // new options
    public var startDate: NSDate?
    public var hightlightsToday: Bool = true
    public var hideDaysFromOtherMonth: Bool = false
    public var barTintColor: UIColor
    
    public var backgroundImage: UIImage?
    
    private(set) public var startYear: Int
    private(set) public var endYear: Int
    
    
    public init(startYear: Int, endYear: Int, multiSelection: Bool, selectedDates: [NSDate]?,frame:CGRect) {
        
        self.startYear = startYear
        self.endYear = endYear
        // Register cell classes
        
        self.multiSelectEnabled = multiSelection
        //Text color initializations
        //self.tintColor = EPDefaults.tintColor
        self.barTintColor = EPDefaults.barTintColor
        self.dayDisabledTintColor = EPDefaults.dayDisabledTintColor
        self.weekdayTintColor = EPDefaults.weekdayTintColor
        self.weekendTintColor = EPDefaults.weekendTintColor
        self.dateSelectionColor = EPDefaults.dateSelectionColor
        self.monthTitleColor = EPDefaults.monthTitleColor
        self.todayTintColor = EPDefaults.todayTintColor

        //Layout creation
        let layout = UICollectionViewFlowLayout()
        //layout.sectionHeadersPinToVisibleBounds = true  // If you want make a floating header enable this property(Avaialble after iOS9)
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        layout.headerReferenceSize = EPDefaults.headerSize
        if let _ = selectedDates  {
            self.arrSelectedDates.appendContentsOf(selectedDates!)
        }
        super.init(frame: frame, collectionViewLayout: layout)
        self.dataSource = self
        self.delegate = self
        self.registerNib(UINib(nibName: "EPCalendarCell1", bundle: NSBundle(forClass: EPCalendarPicker.self )), forCellWithReuseIdentifier: reuseIdentifier)
        self.registerNib(UINib(nibName: "EPCalendarHeaderView", bundle: NSBundle(forClass: EPCalendarPicker.self )), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header")
         self.backgroundColor = UIColor.clearColor()
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.scrollToToday()
        }
    }
    

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UICollectionViewDataSource

     public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if startYear > endYear {
            return 0
        }
        
        let numberOfMonths = 12 * (endYear - startYear) + 12
        return numberOfMonths
    }


    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let startDate = NSDate(year: startYear, month: 1, day: 1)
        let firstDayOfMonth = startDate.dateByAddingMonths(section)
        let addingPrefixDaysWithMonthDyas = ( firstDayOfMonth.numberOfDaysInMonth() + firstDayOfMonth.weekday() - NSCalendar.currentCalendar().firstWeekday )
        let addingSuffixDays = addingPrefixDaysWithMonthDyas%7
        var totalNumber  = addingPrefixDaysWithMonthDyas
        if addingSuffixDays != 0 {
            totalNumber = totalNumber + (7 - addingSuffixDays)
        }
        
        return totalNumber
    }

     public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! EPCalendarCell1
        
        let calendarStartDate = NSDate(year:startYear, month: 1, day: 1)
        let firstDayOfThisMonth = calendarStartDate.dateByAddingMonths(indexPath.section)
        let prefixDays = ( firstDayOfThisMonth.weekday() - NSCalendar.currentCalendar().firstWeekday)
        
        if indexPath.row >= prefixDays {
            cell.isCellSelectable = true
            let currentDate = firstDayOfThisMonth.dateByAddingDays(indexPath.row-prefixDays)
            let nextMonthFirstDay = firstDayOfThisMonth.dateByAddingDays(firstDayOfThisMonth.numberOfDaysInMonth()-1)
            
            cell.currentDate = currentDate
            cell.lblDay.text = "\(currentDate.day())"
            print(currentDate)
            
            if arrSelectedDates.filter({ $0.isDateSameDay(currentDate)
            }).count > 0 && (firstDayOfThisMonth.month() == currentDate.month()) {

                cell.selectedForLabelColor(dateSelectionColor)
            }
            else{
                cell.deSelectedForLabelColor(weekdayTintColor)
               
                if cell.currentDate.isSaturday() || cell.currentDate.isSunday() {
                    cell.lblDay.textColor = weekendTintColor
                }
                if (currentDate > nextMonthFirstDay) {
                    cell.isCellSelectable = false
                    if hideDaysFromOtherMonth {
                        cell.lblDay.textColor = UIColor.clearColor()
                    } else {
                        cell.lblDay.textColor = self.dayDisabledTintColor
                    }
                }
                if currentDate.isToday() && hightlightsToday {
                    cell.setTodayCellColor(todayTintColor)
                }
               
                if startDate != nil {
                    if NSCalendar.currentCalendar().startOfDayForDate(cell.currentDate) < NSCalendar.currentCalendar().startOfDayForDate(startDate!) {
                        cell.isCellSelectable = false
                        cell.lblDay.textColor = self.dayDisabledTintColor
                    }
                }
            }
        }
        else {
            cell.deSelectedForLabelColor(weekdayTintColor)
            cell.isCellSelectable = false
            let previousDay = firstDayOfThisMonth.dateByAddingDays(-( prefixDays - indexPath.row))
            cell.currentDate = previousDay
            cell.lblDay.text = "\(previousDay.day())"
            if hideDaysFromOtherMonth {
                cell.lblDay.textColor = UIColor.clearColor()
            } else {
                cell.lblDay.textColor = self.dayDisabledTintColor
            }
        }
        
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }

    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        
        let rect = UIScreen.mainScreen().bounds
        let screenWidth = rect.size.width - 7
        return CGSizeMake(screenWidth/7, screenWidth/7);
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsetsMake(5, 0, 5, 0); //top,left,bottom,right
    }
    
    public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {

        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", forIndexPath: indexPath) as! EPCalendarHeaderView
            
            let startDate = NSDate(year: startYear, month: 1, day: 1)
            let firstDayOfMonth = startDate.dateByAddingMonths(indexPath.section)
            
            header.lblTitle.text = firstDayOfMonth.monthNameFull()
            header.lblTitle.textColor = monthTitleColor
            header.updateWeekdaysLabelColor(weekdayTintColor)
            header.updateWeekendLabelColor(weekendTintColor)
            header.backgroundColor = UIColor.clearColor()
            
            return header;
        }

        return UICollectionReusableView()
    }
    
     public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! EPCalendarCell1
        if !multiSelectEnabled {
            calendarDelegate?.epCalendarPicker?(self, didSelectDate: cell.currentDate)
            cell.selectedForLabelColor(dateSelectionColor)
            return
        }
        
        if cell.isCellSelectable! {
            if arrSelectedDates.filter({ $0.isDateSameDay(cell.currentDate)
            }).count == 0 {
                arrSelectedDates.append(cell.currentDate)
                calendarDelegate?.epCalendarPicker?(self, didSelectMultipleDate: arrSelectedDates)
                cell.selectedForLabelColor(dateSelectionColor)
                
                if cell.currentDate.isToday() {
                    cell.setTodayCellColor(dateSelectionColor)
                }
            }
            else {
                arrSelectedDates = arrSelectedDates.filter(){
                    return  !($0.isDateSameDay(cell.currentDate))
                }
                if cell.currentDate.isSaturday() || cell.currentDate.isSunday() {
                    cell.deSelectedForLabelColor(weekendTintColor)
                }
                else {
                    cell.deSelectedForLabelColor(weekdayTintColor)
                }
                if cell.currentDate.isToday() && hightlightsToday{
                    cell.setTodayCellColor(todayTintColor)
                }
                calendarDelegate?.epCalendarPicker?(self, didDeselectDate: cell.currentDate)
            }
        }
        
    }
    
    public func scrollToToday () {
        let today = NSDate()
        scrollToMonthForDate(today)
    }
    
    public func scrollToMonthForDate (date: NSDate) {

        let month = date.month()
        let year = date.year()
        let section = ((year - startYear) * 12) + month
        let indexPath = NSIndexPath(forRow:1, inSection: section-1)
        
        self.scrollToIndexpathByShowingHeader(indexPath)
    }
    
    
}
