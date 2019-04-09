//
//  ModernTimer.swift
//  ModernUIKit
//
//  Created by Cliff Panos on 1/10/19.
//  Copyright © 2019 Clifford Panos. All rights reserved.
//

import UIKit

///
/// The delegate to receive updates from a ModernTimer
///
public protocol ModernTimerDelegate: NSObjectProtocol {
    func modernTimerDidUpdate(_ timer: ModernTimer)
}

///
/// An object that can be used to track the elapsed time of an event and update UI components at a time interval
/// - Note: This timer responds to UIApplication events to automatically pause and resume itself as necessary
///
public class ModernTimer: NSObject {
    
    /// The time interval (frequency) with which a timer should signal the delegate
    public let updateInterval: TimeInterval
    
    /// The precision to which the timer should record its elapsed time, e.g. 0.1 for every tenth of a second
    public let precisionInterval: TimeInterval

    /// The total elapsed time that the timer has been running (while the timer is paused, this value does not change)
    public private(set) var elapsedTime: TimeInterval
    
    /// The delegate signalled when the timer updates
    public weak var delegate: ModernTimerDelegate?
    
    /// The name of the timer, suitable for debugging
    public var name: String
    
    
    // MARK: - Lifecycle
    
    public init(name: String = "Modern Timer", updateInterval: TimeInterval = 1, elapsedTime: TimeInterval = 0,
                precisionInterval: TimeInterval = 0.1, delegate: ModernTimerDelegate? = nil) {
        self.precisionInterval = precisionInterval
        self.updateInterval = updateInterval
        self.elapsedTime = elapsedTime
        self.delegate = delegate
        self.name = name
        
        super.init()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(pauseTimerNotification(_:)), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(resumeTimerNotification(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    
    // MARK: - Public
    
    /// Starts the timer. Does nothing if already running, so calling this method repeatedly is safe.
    public func start() {
        if (self.timer == nil || !isRunning) && ableToStart {
            self.timer = Timer(timeInterval: precisionInterval, repeats: true, block: { [weak self](timer: Timer) in
                self?.timerDidFire()
            })
            RunLoop.current.add(self.timer!, forMode: .common)
            isRunning = true
        }
    }
    
    /// Pauses the timer
    public func pause() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
    
    /// Resumes the timer but *only* if it had been started before, i.e. if elapsed time > 0
    public func resume() {
        if elapsedTime > 0 && ableToStart {
            self.start()
        }
    }
    
    /// Stops the timer and resets the elapsed time to zero. Can be started again afterward.
    public func reset() {
        self.pause()
        elapsedTime = 0
    }
    
    /// Stops the timer, finalizes the elapsed time, and permanently disables subsequent start/pause/resume requests.
    public func stop() {
        self.pause()
        self.isStopped = true
    }
    
    ///
    /// Elapsed time should not be mutated normally, so to do so, this function must be used
    ///
    public func explicitlySetElapsedTime(_ elapsedTime: TimeInterval) {
        self.elapsedTime = elapsedTime
    }

    
    // MARK: - Private
    
    private var timer: Timer? = nil
    private var isRunning = false
    private var isStopped = false
    private var ableToStart: Bool { return !isStopped }

    @objc private func timerDidFire() {
        guard !isStopped else { return }
        elapsedTime += precisionInterval
        
//        let div = elapsedTime / updateInterval
        let integralValue = elapsedTime
        let threshold: Double = 0.001
        if abs(integralValue - integralValue.rounded(.toNearestOrAwayFromZero)) < threshold {
//            print("[\(name)] Elapsed time: \(elapsedTime.modernTimeString)")
            delegate?.modernTimerDidUpdate(self)
        }
    }
    
    @objc private func pauseTimerNotification(_ notification: Notification) {
        self.pause()
    }
    
    @objc private func resumeTimerNotification(_ notification: Notification) {
        self.resume()
    }
    
}


// MARK: Modern Time Describing

extension TimeInterval {
    
    public var modernTimeString: String {
        
        // Uncomment to display JUST seconds when less than a minute; AKA 01 instead of 00:01
//        if self < 60 {
//            return String(format: "%02i", Int(self))
//        }
        
        let integralSelf = self.rounded(.toNearestOrAwayFromZero)
        let seconds = Int(integralSelf) % 60
        let minutes = Int(integralSelf) / 60 % 60
        let secondsInHour: TimeInterval = 60 * 60

        if self < secondsInHour {
            return String(format: "%02i:%02i", minutes, seconds)
        }
        
        let hours = Int(self) / 3600
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
    }
    
}
