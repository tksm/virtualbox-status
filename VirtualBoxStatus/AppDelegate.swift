//
//  AppDelegate.swift
//  VirtualBoxStatus
//
//  Created by tkusumi on 1/3/16.
//  Copyright © 2016 tkusumi. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var statusMenu: NSMenu!
    var refreshTimer: NSTimer!
    var isRefreshing = false
    let refreshInterval: Double = 15
    let icon = "🐟"
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        statusItem.menu = statusMenu
        statusItem.title = "-" + icon
        
        refreshTimer = NSTimer.scheduledTimerWithTimeInterval(refreshInterval, target: self, selector: "refresh", userInfo: nil, repeats: true)
        refresh()
    }

    func refresh() {
        if(isRefreshing) {
            NSLog("already refreshing")
            return
        }
        isRefreshing = true
        
        let runningVMs = VBoxManage.listRunningVMs()
        statusMenu.removeAllItems()
        
        statusMenu.addItem(NSMenuItem(title: "Refresh", action: Selector("refresh"), keyEquivalent: ""))
        statusMenu.addItem(NSMenuItem.separatorItem())

        runningVMs.forEach { (vm) -> () in
            let menuItem = NSMenuItem(title: vm.name, action: nil, keyEquivalent: "")
            let subMenu = NSMenu()
            menuItem.submenu = subMenu
            let haltMenuItem = NSMenuItem(title: "send acpipowerbutton", action: Selector("acpipowerbuttonClicked:"), keyEquivalent: "")
            haltMenuItem.representedObject = vm.uuid
            
            subMenu.addItem(haltMenuItem)
            statusMenu.addItem(menuItem)
        }
        statusMenu.addItem(NSMenuItem.separatorItem())
        statusMenu.addItem(NSMenuItem(title: "Quit", action: Selector("quitClicked:"), keyEquivalent: ""))

        statusItem.title = String(format:"%d%@", runningVMs.count, icon)
        isRefreshing = false
    }
    
    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }
    
    @IBAction func acpipowerbuttonClicked(sender: NSMenuItem) {
        NSLog("send acpipowebutton to " + (sender.representedObject as! String))
        VBoxManage.sendAcpiPowerButton(sender.representedObject! as! String)
    }

}

