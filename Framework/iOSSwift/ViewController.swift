//
//  ViewController.swift
//  iOSSwift
//
//  Created by C.W. Betts on 10/3/14.
//
//

import UIKit
import CocoaLumberjack
import CocoaLumberjackSwift

class ViewController: UIViewController {
    var stashFileLogger: DDFileLogger!
    var logTimer: Timer!
    var rollTimer: Timer!
    let logQueue = OperationQueue()
    var readTimer: Timer!

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.

        logTimer = Timer.scheduledTimer(timeInterval: Double(0.03), target: self, selector: #selector(logSomething), userInfo: nil, repeats: true)
        readTimer = Timer.scheduledTimer(timeInterval: Double(0.07), target: self, selector: #selector(readSomething), userInfo: nil, repeats: true)
        rollTimer = Timer.scheduledTimer(timeInterval: Double(0.12), target: self, selector: #selector(rollFile), userInfo: nil, repeats: true)
        self.logQueue.maxConcurrentOperationCount = 1

        if let documentsPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let manager = DDLogFileManagerDefault(logsDirectory: documentsPathString)!
            stashFileLogger = DDFileLogger(logFileManager: manager)
            // We don't expect large file sizes
            stashFileLogger.maximumFileSize = 0
            stashFileLogger.rollingFrequency = 0
            stashFileLogger.logFileManager.maximumNumberOfLogFiles = 1
        } else {
            fatalError("Cannot find documents directory")
        }
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

    @objc func readSomething() {
        logQueue.addOperation {
            guard let logFilePath = self.stashFileLogger.logFileManager.sortedLogFilePaths.first else { return }
            guard let longLogString = try? String(contentsOfFile: logFilePath, encoding: .utf8) else { return }
            var logs: [String] = []
            let allLinesFromCurrentFile = longLogString.components(separatedBy: "\n").reversed()
            print(allLinesFromCurrentFile.count)
        }
    }

    @objc func logSomething() {
        logQueue.addOperation {
            let msg = DDLogMessage.init(message: String(repeating: "t", count: 4000), level: DDLogLevel.error, flag: .error, context: 0, file: "", function: "", line: 0, tag: nil, options: [], timestamp: nil)
            for i in 0...100 {
                self.stashFileLogger.log(message: msg)
            }
        }
    }

    @objc func rollFile() {
        logQueue.addOperation { [self] in
            self.stashFileLogger.rollLogFile {

            }
        }
    }

}

