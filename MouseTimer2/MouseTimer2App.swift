//
//  main.swift
//  MouseTimer
//
//  Created by VEEKAY on 23.12.2024.
//

import SwiftUI
import Cocoa
import AVFoundation

@main
struct MouseTimer2App: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    // Core components
    private var statusItem: NSStatusItem!
    private var timer: Timer?
    private var startTime: Date?
    private var lastMouseLocation: NSPoint?
    private var audioPlayer: AVAudioPlayer?
    
    // Initialize sound for reset notification
    private func setupSound() {
        if let soundURL = Bundle.main.url(forResource: "bonk", withExtension: "wav") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.prepareToPlay()
            } catch {
                print("Error loading sound: \(error)")
            }
        }
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the status item in the menubar
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "00:00:00"
        
        // Set up the menu
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
        
        // Initialize the timer
        startTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
        
        // Setup mouse monitoring
        setupMouseMonitoring()
        setupSound()
    }
    
    private func setupMouseMonitoring() {
        // Store initial mouse location
        lastMouseLocation = NSEvent.mouseLocation
        
        // Create a timer to check mouse movement
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.checkMouseMovement()
        }
    }
    
    private func checkMouseMovement() {
        let currentLocation = NSEvent.mouseLocation
        if let lastLocation = lastMouseLocation, lastLocation != currentLocation {
            // Mouse has moved - reset timer
            resetTimer()
            // Play sound
            audioPlayer?.play()
        }
        lastMouseLocation = currentLocation
    }
    
    private func updateTimer() {
        guard let start = startTime else { return }
        
        let elapsed = Int(-start.timeIntervalSinceNow)
        let hours = elapsed / 3600
        let minutes = (elapsed % 3600) / 60
        let seconds = elapsed % 60
        
        let timeString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        statusItem.button?.title = timeString
    }
    
    private func resetTimer() {
        startTime = Date()
        statusItem.button?.title = "00:00:00"
    }

}
