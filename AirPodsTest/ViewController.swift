//
//  ViewController.swift
//  AirPodsTest
//
//  Created by Craig Lane on 10/16/18.
//  Copyright © 2018 CraigLn. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

  @IBOutlet weak var audioSessionSwitch: UISwitch!

  @IBOutlet weak var currentInputLabel: UILabel!
  @IBOutlet weak var currentOutputLabel: UILabel!
  @IBOutlet weak var currentReasonLabel: UILabel!

  @IBOutlet weak var previousInputLabel: UILabel!
  @IBOutlet weak var previousOutputLabel: UILabel!
  @IBOutlet weak var previousReasonLabel: UILabel!

  @IBOutlet weak var forceSpeakerButton: UIButton!
  @IBOutlet weak var forceReceiverButton: UIButton!
  @IBOutlet weak var forceAirPodsButton: UIButton!
    
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    try? AVAudioSession.sharedInstance().setCategory(.playAndRecord,
                                                mode: .voiceChat,
                                                options: [.allowBluetooth, .allowBluetoothA2DP])

    currentInputLabel.text = AVAudioSession.sharedInstance().currentRoute.inputs.first?.portName ?? "None"
    currentOutputLabel.text = AVAudioSession.sharedInstance().currentRoute.outputs.first?.portName ?? "None"

    NotificationCenter.default.addObserver(self,
                                           selector: #selector(routeChanged(_:)),
                                           name: AVAudioSession.routeChangeNotification,
                                           object: nil)
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  @IBAction func activateAudioSessionSwitch(_ sender: UISwitch) {
    if sender.isOn {
      guard let _ = try? AVAudioSession.sharedInstance().setActive(true, options: AVAudioSession.SetActiveOptions.notifyOthersOnDeactivation) else {
        sender.setOn(false, animated: true)
        return
      }

      forceSpeakerButton.isEnabled = true
      forceReceiverButton.isEnabled = true
      forceAirPodsButton.isEnabled = true
    } else {
      try? AVAudioSession.sharedInstance().setActive(false, options: AVAudioSession.SetActiveOptions.notifyOthersOnDeactivation)

      forceSpeakerButton.isEnabled = false
      forceReceiverButton.isEnabled = false
      forceAirPodsButton.isEnabled = false
    }
  }

  @IBAction func forceOverrideSpeaker(_ sender: UIButton) {
    try? AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
  }

  @IBAction func forceOverrideReceiver(_ sender: UIButton) {
    if let builtInMicPort = portDescription(from: AVAudioSession.Port.builtInMic) {
      try? AVAudioSession.sharedInstance().setPreferredInput(builtInMicPort)
    }
  }

  @IBAction func forceOverrideAirPods(_ sender: UIButton) {
    if let airPodsPort = portDescription(from: AVAudioSession.Port.bluetoothHFP) {
      try? AVAudioSession.sharedInstance().setPreferredInput(airPodsPort)
    }
  }

  func portDescription(from port: AVAudioSession.Port) -> AVAudioSessionPortDescription? {
    guard let portDescription = AVAudioSession.sharedInstance()
      .availableInputs?.filter({ $0.portType == port }).first else {
        return nil
    }

    return portDescription
  }

  @objc func routeChanged(_ notification: Notification) {
    guard let prevoiusRoute = notification.userInfo?[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription,
          let reasonRawValue = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt,
          let reason = AVAudioSession.RouteChangeReason(rawValue: reasonRawValue) else {
      return
    }

    DispatchQueue.main.sync {
      previousInputLabel.text = prevoiusRoute.inputs.first?.portName ?? currentInputLabel.text
      previousOutputLabel.text = prevoiusRoute.outputs.first?.portName ?? currentOutputLabel.text
      previousReasonLabel.text = currentReasonLabel.text

      currentInputLabel.text = AVAudioSession.sharedInstance().currentRoute.inputs.first?.portName ?? "None"
      currentOutputLabel.text = AVAudioSession.sharedInstance().currentRoute.outputs.first?.portName ?? "None"
      currentReasonLabel.text = audioSessionReasonDescription(reason)
    }
  }

  func audioSessionReasonDescription(_ reason: AVAudioSession.RouteChangeReason) -> String {
    switch(reason) {
    case .unknown:
      return "unknown"
    case .newDeviceAvailable:
      return "newDeviceAvailable"
    case .oldDeviceUnavailable:
      return "oldDeviceUnavailable"
    case .categoryChange:
      return "categoryChange"
    case .override:
      return "override"
    case .wakeFromSleep:
      return "wakeFromSleep"
    case .noSuitableRouteForCategory:
      return "noSuitableRouteForCategory"
    case .routeConfigurationChange:
      return "routeConfigurationChange"
    }
  }
}

