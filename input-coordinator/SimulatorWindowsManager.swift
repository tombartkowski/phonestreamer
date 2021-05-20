//
//  SimulatorWindowsManager.swift
//  SimulatorsManager
//
//  Created by Tomasz Bartkowski on 10/05/2021.
//

import Foundation

@objc
class SimulatorWindowsManager: NSObject {
    // MARK: Lifecycle

    required init(simulatorPid: pid_t) {
        Logger.log(content: "Creating Simulator windows.")
        self.simulatorPid = simulatorPid
        super.init()

        updateWindows()

        let app_ref = AXUIElementCreateApplication(simulatorPid)
        axObserver = getAXObserverCreate(simulatorPid) { (
            _ axObserver: AXObserver,
            axElement: AXUIElement,
            notification: CFString,
            userData: UnsafeMutableRawPointer?
        ) -> Void in
            guard let userData = userData else {
                return
            }
            let application = Unmanaged<SimulatorWindowsManager>.fromOpaque(userData)
                .takeUnretainedValue()
            application.callback(axObserver, axElement: axElement, notification: notification)
            }

            addCFRunLoopSource(axObserver!)

            let selfPtr = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
            addAXObserverNotification(axObserver!, app_ref, kAXMainWindowChangedNotification, selfPtr)
    }

    // MARK: Internal
    
    var currentlyActiveWindow: String = ""
    
    func updateWindows() {
        Logger.log(content: "Updating Simulator windows.")
        let simulatorApp = AXUIElementCreateApplication(simulatorPid)
        var simulatorWindowsRef: CFArray?

        AXUIElementCopyAttributeValues(
            simulatorApp,
            kAXWindowsAttribute as CFString,
            0,
            99999,
            &simulatorWindowsRef
        )
        let simulatorWindows = (simulatorWindowsRef as? [AXUIElement]) ?? []
        simulatorWindows.forEach { window in
            var windowTitleRef: CFTypeRef?
            AXUIElementCopyAttributeValue(window, kAXTitleAttribute as CFString, &windowTitleRef)
            if let windowTitle = windowTitleRef as? String {
                windowsMap[windowTitle] = window
            }
            
            var isCurrentlyMain: CFTypeRef?
            AXUIElementCopyAttributeValue(window, kAXMainAttribute as CFString, &isCurrentlyMain)
            
            if isCurrentlyMain as! Bool{
                currentlyActiveWindow = windowTitleRef as! String
            }
            
        }
        Logger.log(content: "Simulator windows found - \(windowsMap.keys).")
    }

    
    var axObserver: AXObserver!

    var callback: (() -> Void)?
    func callback(
        _: AXObserver,
        axElement: AXUIElement,
        notification _: CFString
    ) {
        var windowTitleRef: CFTypeRef?
        AXUIElementCopyAttributeValue(axElement, kAXTitleAttribute as CFString, &windowTitleRef)
        callback?()
    }

    func activateWindow(_ title: String, _ completion: @escaping () -> ()) {
        Logger.log(content: "Started activating window - \(title).")
        
        if (title + " – 14.4") == currentlyActiveWindow {
            completion()
            return
        }
        
        guard let window = windowsMap[title + " – 14.4"] else { return }
        
        callback = { [weak self] in
            self?.currentlyActiveWindow = title + " – 14.4"
            Logger.log(content: "Activating window finished - \(title).")
            completion()
            self?.callback = nil
        }
        AXUIElementSetAttributeValue(
            window,
            kAXMainAttribute as CFString,
            kCFBooleanTrue as CFTypeRef
        )
    }

    // MARK: Private

    private let simulatorPid: pid_t
    private var windowsMap = [String: AXUIElement]()
    
    
}
