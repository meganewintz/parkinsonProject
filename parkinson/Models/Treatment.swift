//
//  Treatment.swift
//  parkinsonProject
//
//  Created by Thierry WINTZ on 28/02/2018.
//  Copyright © 2018 Mégane WINTZ. All rights reserved.
//

import Foundation

class Treatment	 {
    
    public var name : String
    public var description : String
    public var type : String
    public var doses : DoseSet
    public var endDate : Date

    private var dailyDoses : [DailyDose]
    
    /// init
    ///
    /// initialize a 'Treatment' with his name, his description, his type and his frequency
    ///
    /// - Parameters:
    ///   - name: `String`
    ///   - description:  `String`
    ///   - type : String
    ///   - frequency : String
    internal init(name : String, description : String, type : String, endDate : Date){
        self.name = name
        self.description = description
        self.type = type
        self.doses = DoseSet()
        self.dailyDoses = [DailyDose]()
        self.endDate = endDate
    }
    
    
    /// isFinished
    ///
    /// - Returns : 'Bool' indicates if the treatment is finished
    func isFinished() -> Bool {
        return Date() > endDate
    }
    
    
    /// dateNextTreatment
    ///
    /// give the date of the next dose programed if there is one
    ///
    /// - Returns : 'Date?' the date of the next dose programed
    public func dateNextTreatment() -> Date? {
        let dose = nextDailyDose()
        let nextDate = Calendar.current.nextDate(after: Date(), matching: DateComponents(hour : dose.hour, minute : dose.minute), matchingPolicy: .nextTime)
        if nextDate! > endDate {
            return nil
        } else {
            return nextDate
        }
    }
    
    
    /// nextDoseQuantity
    ///
    /// give the quantity of drug of the next dose programmed
    ///
    /// - Returns : 'Int?' the quantity of the next dose programmed
    public func nextDoseQuantity() -> Int? {
        if dateNextTreatment() == nil {
            return nil
        } else {
            return nextDailyDose().quantity
        }
    }
    
    
    /// addDailyDose
    ///
    /// add the quantity property with a daily period for a dose
    ///
    /// - Parameters:
    ///   - dailyDose: `DailyDose`
    ///
    /// - Returns : the treatment with the daily dose added
    public func addDailyDose(dailyDose : DailyDose) -> Treatment {
        dailyDoses.append(dailyDose)
        dailyDoses.sort(by:{ $0.dailyPeriod < $1.dailyPeriod } )
        return self
    }
    
    
    /// dailyDoseCount
    ///
    /// returns the number of daily doses programmed
    ///
    /// - Returns : Int the number of daily doses programmed
    public var dailyDoseCount : Int {
        return dailyDoses.count
    }
    
    
    /// getDailyDose
    ///
    /// returns the i-th Dailydose sorted by ascending hour
    ///
    /// - Parameters:
    ///   - i: int
    ///
    /// - Returns : 'DailyDose?' the i-th dose of the day
    public func getDailyDose(index i : Int) -> DailyDose? {
        guard i>=0 && i<self.dailyDoseCount else { return nil }
        return dailyDoses[i]
    }
    
    
    /// removeDailyDose
    ///
    /// remove the i-th dose of the day, sorted by ascending hour
    ///
    /// - Parameters:
    ///   - i:Int
    ///
    /// - Returns : Treatment without the i-th daily dose in parameter
    public func removeDailyDose(i : Int) -> Treatment {
        dailyDoses.remove(at : i)
        return self
    }
    
    
    /// nextDailyDose
    ///
    /// - Returns : 'DailyDose' the next daily dose
    private func nextDailyDose() -> DailyDose {
        guard dailyDoses.count > 0 else { fatalError("No daily dose for the treatment") }
        let currentDate = Date()
        let hour = Calendar.current.component(.hour, from: currentDate)
        let minute = Calendar.current.component(.minute, from: currentDate)
        
        var nextDose = dailyDoses.filter({ $0.hour > hour || ($0.hour == hour && $0.minute > minute) }).min(by : { $0.hour < $1.hour || ($0.hour == $1.hour && $0.minute < $1.minute) })
        if nextDose == nil {
            // no more dose today, then take the first of tomorrow
            nextDose = dailyDoses[0]
        }
        return nextDose!
    }
}
