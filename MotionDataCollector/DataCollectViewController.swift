//
//  DataCollectViewController.swift
//  motiondatawriter
//
//  Created by 조기현 on 2020/12/19.


import UIKit
import Foundation
import CoreMotion
import AVFoundation


class DataCollectViewController: UIViewController {
	@IBOutlet weak var segmentedControl: UISegmentedControl!
	@IBOutlet weak var fileCountLabel: UILabel!
	@IBOutlet weak var rowCountLabel: UILabel!
	@IBOutlet weak var startButton: UIButton!
	
	private let fileManager = FileManager.default
	private let synthesizer = AVSpeechSynthesizer()
	private let segments = ["standing", "running"]
	private var rows = [String]()
	private var timer: Timer?
	private let interval = 1.0 / 10.0
	private let maxRowCount = 600
	
	private lazy var motion: CMMotionManager = {
		let manager = CMMotionManager()
		assert(manager.isDeviceMotionAvailable)
		manager.deviceMotionUpdateInterval = interval
		manager.showsDeviceMovementDisplay = true
		manager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical)
		return manager
	}()
	
	private lazy var header: String = {
		let header = motion.deviceMotion?.titles.reduce("") { $0 + ",\($1)"}
		return header ?? ""
	}()
	
	

	override func viewDidLoad() {
		super.viewDidLoad()
		setup()
		rowCountLabel.text = "0/\(maxRowCount)"
		updateFileCountLabel()
	}
	
	func setup() {
		segments.forEach { component in
			do {
				let subDirPath = directoryPath.appendingPathComponent(component).path
				if fileManager.fileExists(atPath: subDirPath) { return }
				
				try FileManager.default.createDirectory(
					atPath: subDirPath,
					withIntermediateDirectories: true,
					attributes: nil
				)
			}catch {
				print(error.localizedDescription)
			}
		}
	}
	
	
	@IBAction func startButtonClickAction(_ sender: Any) {
		startTimer()
	}
	
	@IBAction func segmentedControlValueChangedAction(_ sender: Any) {
		updateFileCountLabel()
	}
	
	func updateFileCountLabel() {
		fileCountLabel.text = fileCount.description
	}
	
	func enableViews(_ isEnabled: Bool) {
		startButton.isEnabled = isEnabled
		segmentedControl.isEnabled = isEnabled
	}
}

// MARK: - Collect Motion Data

extension DataCollectViewController {
	private func startTimer() {
		timer?.invalidate()
		enableViews(false)
		
		let timer = Timer(fire: Date(),
					  interval: interval,
					  repeats: true) { _ in self.collectData()}
		RunLoop.current.add(timer, forMode: RunLoop.Mode.default)
		self.timer = timer
	}
	
	private func collectData() {
		guard let data = motion.deviceMotion else { return }
		
		if rows.count == maxRowCount {
			save()
			enableViews(true)
			timer?.invalidate()
			synthesizer.speak(text: "Complete")
		}
		
		let row = makeRow(motion: data)
		rows.append(row)
	}
	
	private func save() {
		let text = ([header] + rows).joined(separator: "\n")
		let filePath = subDirectoryPath.appendingPathComponent("\(nextFileName).csv")
		filePath.write(text: text)
		rows = []
		updateFileCountLabel()
	}
	
	private func makeRow(motion: CMDeviceMotion) -> String {
		let line = "\(rows.count)" + motion.data.reduce("") {$0 + ",\($1)"}
		rowCountLabel.text = "\(rows.count)/\(maxRowCount)"
		return line
	}
}


// MARK: - FileManager

extension DataCollectViewController {
	var directoryPath: URL {
		guard
			let url = fileManager.urls(
				for: .documentDirectory,
				in: .userDomainMask
			).first
		else { fatalError() }
		
		return url
	}
	
	var subDirectoryPath: URL {
		let component = segments[segmentedControl.selectedSegmentIndex]
		return directoryPath.appendingPathComponent(component)
	}
	
	
	var subDirectoryContents: [String] {
		do {
			return try FileManager.default.contentsOfDirectory(atPath: subDirectoryPath.path)
		} catch {
			fatalError()
		}
	}
	
	var fileCount: Int {
		subDirectoryContents.count
	}
	
	var nextFileName: String {
		return UUID().description
		
//		var maxNum = 0
//		subDirectoryContents.forEach { fullName in
//			guard
//				let fileName = fullName.components(separatedBy: ".").first,
//				let num = Int(fileName)
//			else { return }
//			maxNum = max(maxNum, num)
//		}
//		return maxNum + 1
	}
}


extension CMDeviceMotion {
	var data: [Double] {
		let data = [
			attitude.roll,
			attitude.pitch,
			attitude.yaw,
			gravity.x,
			gravity.y,
			gravity.z,
			rotationRate.x,
			rotationRate.y,
			rotationRate.z,
			userAcceleration.x,
			userAcceleration.y,
			userAcceleration.z,
		]
		return data
	}
	
	var titles: [String] {
		let titles = [
			"attitude.roll",
			"attitude.pitch",
			"attitude.yaw",
			"gravity.x",
			"gravity.y",
			"gravity.z",
			"rotationRate.x",
			"rotationRate.y",
			"rotationRate.z",
			"userAcceleration.x",
			"userAcceleration.y",
			"userAcceleration.z",
		]
		return titles
	}
}

extension URL {
	func write(text: String) {
		do {
			try text.write(to: self, atomically: false, encoding: .utf8)
		} catch {
			print(error.localizedDescription)
		}
	}
}

extension AVSpeechSynthesizer {
	func speak(text: String) {
		if isSpeaking {
			stopSpeaking(at: .immediate)
		}

		let utterance = AVSpeechUtterance(string: text)
		utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
		utterance.rate = 0.5

		speak(utterance)
	}
}
