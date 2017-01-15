//
//  InterfaceController.swift
//  Watch Extension
//
//  Created by Nick Uzelac on 1/14/17.
//  Copyright © 2017 Simplex HackAZ. All rights reserved.
//

import Foundation
import WatchKit
import WatchConnectivity
import CoreMotion
import UIKit
import HealthKit



class InterfaceController: WKInterfaceController {
    
    //properties
    var maxAccel: Double = 0.0
    let motionManager = CMMotionManager()
    
    var workoutActive = false
    var workoutSession: HKWorkoutSession?
    var healthStore = HKHealthStore()
    let heartRateType:HKQuantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier .heartRate)!
    let heartRateUnit = HKUnit(from: "count/min")
    var currentQuery : HKQuery?
    
    let ACCEL_THRESHOLD = 6.0
    let UPPER_HR_THRESHOLD = 70.0
    let LOWER_HR_THRESHOLD = 40.0
    
    
    //UI Outlets
    @IBOutlet var heartRateLabel: WKInterfaceLabel!
    @IBOutlet var maxLabel: WKInterfaceLabel!
    func resetAccel() {
        self.maxAccel = 0.0
        motionManager.startAccelerometerUpdates(
            to: OperationQueue.current!,
            withHandler: { (data: CMAccelerometerData?, error: Error?) -> Void in
                
                let X = fabs(data!.acceleration.x)
                let Y = fabs(data!.acceleration.y)
                let Z = fabs(data!.acceleration.z)
                let netAccel = sqrt((X*X) + (Y*Y) + (Z*Z))
                
                if (netAccel > self.maxAccel) {
                    self.maxAccel = netAccel
                    self.maxLabel.setText(String(format: "%.2f", self.maxAccel))
                }
                
                if (netAccel > self.ACCEL_THRESHOLD){
                    self.triggerAccelEmerg()
                }
                
                if (error != nil) {
                    print("/(error)")
                }
        }
        )
    }
    
    
    //functions
    func triggerAccelEmerg() {
        stopSensors()
        presentController(withName: "AccelEmergController", context: nil)
    }
    
    func triggerHREmerg() {
        stopSensors()
        presentController(withName: "HREmergController", context: nil)
    }
    
    func stopSensors() {
        stopHeartRateSensor()
        self.motionManager.stopAccelerometerUpdates()
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        motionManager.accelerometerUpdateInterval = 0.1
    }
    
    override func willActivate() {
        super.willActivate()
        resetAccel()
        
        guard HKHealthStore.isHealthDataAvailable() == true else {
            heartRateLabel.setText("n/a")
            return
        }
        
        let dataTypes = Set(arrayLiteral: heartRateType)
        healthStore.requestAuthorization(toShare: nil, read: dataTypes, completion: {
            success, error in
            print(error ?? success)
        })
        
        activateHeartRateSensor()
        
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        
        stopSensors()
    }
    
}

extension InterfaceController: HKWorkoutSessionDelegate {
    
    func activateHeartRateSensor() {
        
        if (workoutSession != nil) {
            return
        }
        
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .other
        configuration.locationType = .indoor
        
        do {
            workoutSession = try HKWorkoutSession(configuration: configuration)
            workoutSession?.delegate = self
        } catch let error as NSError {
            // Perform proper error handling here...
            fatalError("*** Unable to create the workout session: \(error.localizedDescription) ***")
        }
        
        healthStore.start(workoutSession!)
        print("workoutSession Started")
        
    }
    
    func stopHeartRateSensor() {
        self.workoutActive = false
        if let workout = self.workoutSession {
            healthStore.end(workout)
        }
    }
    
    func workoutDidStart(_ date : Date) {
        let query = self.createStreamingHeartRateQuery(workoutStartDate: date)
        self.currentQuery = query
        healthStore.execute(query)
    }
    
    func workoutDidEnd(_ date : Date) {
        healthStore.stop(self.currentQuery!)
        heartRateLabel.setText("-")
        workoutSession = nil
    }
    
    func createStreamingHeartRateQuery(workoutStartDate: Date) -> HKQuery {
        let datePredicate = HKQuery.predicateForSamples(withStart: workoutStartDate, end: nil, options: .strictEndDate)
        
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate])
        
        let heartRateQuery = HKAnchoredObjectQuery(type: heartRateType, predicate: predicate, anchor: nil, limit: Int(HKObjectQueryNoLimit), resultsHandler: {
            (query, samples, deletedObjects, anchor, error) -> Void in
            self.updateHeartRate(samples)
        })
        
        heartRateQuery.updateHandler = {(query, samples, deleteObjects, newAnchor, error) -> Void in
            self.updateHeartRate(samples)
        }
        
        return heartRateQuery
    }
    
    func updateHeartRate(_ samples: [HKSample]?) {
        let heartRateSamples = samples as? [HKQuantitySample]
        
        DispatchQueue.main.async {
            guard let sample = heartRateSamples?.first else{return}
            let value = sample.quantity.doubleValue(for: self.heartRateUnit)
            print("Heart Rate: " + String(value))
            self.heartRateLabel.setText(String(UInt16(value)))
            self.compareHeartRate(heartRate: value)
        }
    }
    
    func compareHeartRate(heartRate : Double) {
        if (heartRate > UPPER_HR_THRESHOLD || heartRate < LOWER_HR_THRESHOLD) {
            print("Extreme HR detected")
            triggerHREmerg()
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        print("Workout Session State Changed")
        switch toState {
        case .running:
            print("Started workout")
            workoutDidStart(date)
        case .ended:
            print("Ended workout")
            workoutDidEnd(date)
        default:
            print("Unexpected workout session state \(toState)")
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("Workout Failed")
    }
}
