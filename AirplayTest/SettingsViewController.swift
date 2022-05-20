//
//  SettingsViewController.swift
//  AirplayTest
//
//  Created by Tomas Kohout on 19.05.2022.
//

import Foundation
import UIKit
import AVFoundation

class SettingsViewController: UIViewController {
    let session = AVAudioSession.sharedInstance()

    @IBOutlet var audioSessionButton: UIButton!
    @IBOutlet var categoryButton: UIButton!
    @IBOutlet var overrideOutputButton: UIButton!
    @IBOutlet var stackView: UIStackView!

    var isActive: Bool = true
    var category: AVAudioSession.Category = .playback
    var categoryOptions: AVAudioSession.CategoryOptions = []

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        do {
            try session.setCategory(category)
            try session.setActive(isActive)
        }
        catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        AVAudioSession.CategoryOptions.allCases.forEach { option in
            let aSwitch = UISwitch()
            aSwitch.addTarget(self, action: #selector(optionSwitched), for: .valueChanged)
            aSwitch.tag = Int(option.rawValue)
            let label = UILabel()
            label.text = "\(option)"
            let hStack = UIStackView(arrangedSubviews: [aSwitch, label])
            hStack.spacing = 10
            hStack.axis = .horizontal
            stackView.addArrangedSubview(hStack)
        }

        self.updateState()
    }

    @IBAction func toggleAudioSession() {
        catchAndAlert {
            isActive = !isActive
            try session.setActive(isActive, options: [.notifyOthersOnDeactivation])
            self.updateState()
        }
    }

    @IBAction func changeCategory() {
        let alert = UIAlertController(title: "Change category", message: nil, preferredStyle: .actionSheet)

        AVAudioSession.Category.allCases.forEach { category in
            alert.addAction(UIAlertAction(title: "\(category)", style: .default) { _ in
                self.category = category
                self.updateCategory()
            })
        }


        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    @IBAction func overrideOutput() {
        let alert = UIAlertController(title: "Override output", message: nil, preferredStyle: .actionSheet)

        let overrides: [AVAudioSession.PortOverride] = [
            .none,
            .speaker,
        ]

        overrides.forEach { override in
            alert.addAction(UIAlertAction(title: "\(override)", style: .default) { _ in
                self.catchAndAlert {
                    try self.session.overrideOutputAudioPort(override)
                    self.updateState()
                }
            })
        }


        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    @objc func optionSwitched(aSwitch: UISwitch) {
        let optionRaw = UInt(aSwitch.tag)
        let option = AVAudioSession.CategoryOptions(rawValue: optionRaw)

        if aSwitch.isOn {
            categoryOptions.update(with: option)
        } else {
            categoryOptions.remove(option)
        }

        updateCategory()
    }

    func updateCategory() {
        self.catchAndAlert {
            try self.session.setCategory(category, options: categoryOptions)
            self.updateState()
        }
    }

    func updateState() {
        audioSessionButton.setTitle(isActive ? "Disable audio session" : "Enable audio session", for: .normal)
        categoryButton.setTitle("Change category (\(category))", for: .normal)
    }

    func catchAndAlert(_ closure: () throws -> Void ) {
        do {
            try closure()
        } catch let error {
            let err = error as NSError

            let message: String
            if let code = AVAudioSession.ErrorCode(rawValue: err.code) {
                message = "\(code)"
            } else {
                message = "\(error)"
            }
            let alert = UIAlertController(title: "Error while setting session", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
        }
    }
    
}


extension AVAudioSession.Category: CustomStringConvertible, CaseIterable {
    public static var allCases: [AVAudioSession.Category] {
        [
            .ambient,
            .soloAmbient,
            .playback,
            .record,
            .playAndRecord,
            .multiRoute
        ]
    }

    public var description: String {
        switch self {
        case .ambient:
            return "ambient"
        case .soloAmbient:
            return "soloAmbient"
        case .playback:
            return "playback"
        case .record:
            return "record"
        case .playAndRecord:
            return "playAndRecord"
        case .multiRoute:
            return "multiRoute"
        default:
            return "?"
        }
    }
}

extension AVAudioSession.PortOverride: CustomStringConvertible {
    public var description: String {
        switch self {
        case .speaker:
            return "speaker"
        case .none:
            return "none"
        @unknown default:
            return "?"
        }
    }
}


extension AVAudioSession.CategoryOptions: CustomStringConvertible, CaseIterable {
    public static var allCases: [AVAudioSession.CategoryOptions] {
        return [
            .mixWithOthers,
            .duckOthers,
            .allowBluetooth,
            .defaultToSpeaker,
            .interruptSpokenAudioAndMixWithOthers,
            .allowBluetoothA2DP,
            .allowAirPlay,
            .overrideMutedMicrophoneInterruption
        ]
    }


    public var description: String {
        switch self {
        case .mixWithOthers:
            return "mixWithOthers"
        case .duckOthers:
            return "duckOthers"
        case .allowBluetooth:
            return "allowBluetooth"
        case .defaultToSpeaker:
            return "defaultToSpeaker"
        case .interruptSpokenAudioAndMixWithOthers:
            return "interruptSpokenAudioAndMixWithOthers"
        case .allowBluetoothA2DP:
            return "allowBluetoothA2DP"
        case .allowAirPlay:
            return "allowAirPlay"
        case .overrideMutedMicrophoneInterruption:
            return "overrideMutedMicrophoneInterruption"
        default:
            return "?"
        }
    }
}

extension AVAudioSession.ErrorCode: CustomStringConvertible {
    public var description: String {
        switch self {
        case .none:
            return "none"
        case .mediaServicesFailed:
            return "mediaServicesFailed"
        case .isBusy:
            return "isBusy"
        case .incompatibleCategory:
            return "incompatibleCategory"
        case .cannotInterruptOthers:
            return "cannotInterruptOthers"
        case .missingEntitlement:
            return "missingEntitlement"
        case .siriIsRecording:
            return "siriIsRecording"
        case .cannotStartPlaying:
            return "cannotStartPlaying"
        case .cannotStartRecording:
            return "cannotStartRecording"
        case .badParam:
            return "badParam"
        case .insufficientPriority:
            return "insufficientPriority"
        case .resourceNotAvailable:
            return "resourceNotAvailable"
        case .unspecified:
            return "unspecified"
        case .expiredSession:
            return "expiredSession"
        case .sessionNotActive:
            return "sessionNotActive"
        @unknown default:
            return "unknown(\(rawValue))"
        }
    }
}
