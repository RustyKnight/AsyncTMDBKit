//
//  StopWatch.swift
//  
//
//  Created by Shane Whitehead on 21/6/2022.
//

import Foundation

class StopWatch: CustomStringConvertible {
    var startTime: Date?
    var duration: TimeInterval {
        guard let startTime = startTime else {
            return 0
        }
        return Date().timeIntervalSince(startTime)
    }
    
    var isRunning: Bool = false {
        didSet {
            if isRunning {
                startTime = Date()
            }
        }
    }
    
    var durationText: String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.second, .minute, .hour]
        formatter.zeroFormattingBehavior = .dropAll
        
        return formatter.string(from: duration) ?? "Unknown"
    }
    
    var description: String {
        return durationText
    }
    
    @discardableResult
    func start() -> StopWatch {
        isRunning = true
        return self
    }
    
}
