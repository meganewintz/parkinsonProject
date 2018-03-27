//
//  PracticesSet.swift
//  parkinsonProject
//
//  Created by Thierry WINTZ on 28/02/2018.
//  Copyright © 2018 Mégane WINTZ. All rights reserved.
//

import Foundation

class PracticesSet {

    private var practices : [Practice]
    private var delegates : [PracticeSetDelegate]
    private var dao : DAOpracticeProtocol?
    
    
    /// init
    ///
    /// initialize an 'PracticesSet', empty.
    ///
    internal init(dao : DAOpracticeProtocol?){
        practices = [Practice]()
        delegates = [PracticeSetDelegate]()
        self.dao = dao
    }
    
    
    /// addPractice
    ///
    /// add a practice to the set
    ///
    /// - Parameters:
    ///   - practice: `Practice`
    /// - Returns : 'PracticesSet' with the practice enter in parameter
    @discardableResult
    public func addPractice(practice : Practice) -> PracticesSet {
        practices.append(practice)
        for d in delegates {
            d.practiceAdded(at: self.count-1)
        }
        return self
    }
    
    
    /// updatePractice
    ///
    /// updates a practice with a new value
    ///
    /// - Parameters:
    ///   - old: `Practice`
    ///   - new: Practice
    /// - Returns : 'PracticeSet' with the practice updated
    @discardableResult
    func updatePractice(old : Practice, new : Practice) -> PracticesSet {
        if let index=practices.index(where : { $0 === old }) {
            practices[index] = new
            for d in delegates {
                d.practiceUpdated(at : index)
            }
        }
        return self
    }
    
    
    /// count
    ///
    /// number of `Practice` in the set
    ///
    /// - Returns : 'Int'
    public var count : Int {
        return practices.count
    }
    
    
    /// contains
    ///
    /// - Parameters:
    ///   - activity: `Practice`
    /// - Returns : True if the practice is in the set
    func contains(practice : Practice) -> Bool {
        return practices.contains(where: { $0 === practice })
    }
    
    
    /// percentageOfSuccess
    ///
    /// percentage of practice in the set with the proprietiy "isDone" = True
    ///
    /// - Returns : Int percentage of practice in the set with the proprietiy "isDone" = True
    func percentageOfSuccess() -> Float {
        var success : Int = 0
        var finished : Int = 0
        for practice in practices {
            if practice.isDone {
                success += 1
            }
            if practice.isDone || practice.isCancelled {
                finished += 1
            }
        }
        if finished == 0 {
            return 1
        } else {
            return Float(success) / Float(self.count) * 100
        }
    }
    
    
    /// practicesOf
    ///
    /// give the practices occuring during the period enter in paramater
    ///
    /// - Parameters:
    ///   - day1: `Date`
    ///   - dat2: 'Date'
    /// - Returns : 'PracticesSet' with all the practices in this practicesSet occur during the dates enter in paramater
    
    
    /// addDelegate
    ///
    /// add a delegate to this model
    ///
    /// - Parameters:
    ///   - delegate: `Delegate`
    @discardableResult
    func addDelegate(delegate : PracticeSetDelegate) -> PracticesSet {
        if !delegates.contains(where: { $0 === delegate }) {
            delegates.append(delegate)
        }
        return self
    }
    
    
    /// removeDelegate
    ///
    /// remove a delegate to this model
    ///
    /// - Parameters:
    ///   - delegate: `Delegate`
    @discardableResult
    func removeDelegate(delegate : PracticeSetDelegate) -> PracticesSet {
        if let index = delegates.index(where: { $0 === delegate }) {
            delegates.remove(at: index)
        }
        return self
    }

    
    @discardableResult
    func validatePractice(dateNextPractice date : Date) -> PracticesSet {
        if let practice = lastUncheckedPractice(){
            practice.isDone = true;
        }
        let nextPractice = Practice()
        nextPractice.dateFirstReminder = date
        self.addPractice(practice: nextPractice)
        return self
    }
    
    
    @discardableResult
    func delayPractice() -> PracticesSet {
        if let practice = lastUncheckedPractice(){
            practice.reminderNb += 1
            if practice.reminderNb == 4 {
                practice.isCancelled = true
            }
        }
        return self
    }
    
    
    @discardableResult
    func cancelPractice(dateNextPractice date : Date) -> PracticesSet {
        if let practice = lastUncheckedPractice(){
            practice.isCancelled = true;
        }
        let nextPractice = Practice()
        nextPractice.dateFirstReminder = date
        self.addPractice(practice: nextPractice)
        return self
    }
    
    
    /// returns the next practice not validated or not cancelled
    private func lastUncheckedPractice() -> Practice? {
        return practices.filter({ !$0.isDone }).min(by: { $0.dateNextReminder()! < $1.dateNextReminder()! })
    }
}
