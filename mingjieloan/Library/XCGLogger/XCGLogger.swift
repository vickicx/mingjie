//
//  XCGLogger.swift
//  XCGLogger: https://github.com/DaveWoodCom/XCGLogger
//
//  Created by Dave Wood on 2014-06-06.
//  Copyright (c) 2014 Dave Wood, Cerebral Gardens.
//  Some rights reserved: https://github.com/DaveWoodCom/XCGLogger/blob/master/LICENSE.txt
//

import Foundation

private extension Thread {
    class func dateFormatter(_ format: String, locale: Locale? = nil) -> DateFormatter? {

        let localeToUse = locale ?? Locale.current

        // These next two lines are a bit of a hack to handle the fact that .threadDictionary changed from an optional to a non-optional between Xcode 6.1 and 6.1.1
        // This lets us use the same (albeit ugly) code in both cases.
        // TODO: Clean up at some point after 6.1.1 is officially released.
        let threadDictionary: NSMutableDictionary? = Thread.current.threadDictionary
        if let threadDictionary = threadDictionary {
            var dataFormatterCache: [String:DateFormatter]? = threadDictionary.object(forKey: XCGLogger.constants.nsdataFormatterCacheIdentifier) as? [String:DateFormatter]
            if dataFormatterCache == nil {
                dataFormatterCache = [String:DateFormatter]()
            }

            let formatterKey = format + "_" + localeToUse.identifier
            if let formatter = dataFormatterCache?[formatterKey] {
                return formatter
            }

            let formatter = DateFormatter()
            formatter.locale = localeToUse
            formatter.dateFormat = format
            dataFormatterCache?[formatterKey] = formatter

            threadDictionary[XCGLogger.constants.nsdataFormatterCacheIdentifier] = dataFormatterCache

            return formatter
        }

        return nil
    }
}

// MARK: - XCGLogDetails
// - Data structure to hold all info about a log message, passed to log destination classes
public struct XCGLogDetails {
    public var logLevel: XCGLogger.LogLevel
    public var date: Date
    public var logMessage: String
    public var functionName: String
    public var fileName: String
    public var lineNumber: Int

    public init(logLevel: XCGLogger.LogLevel, date: Date, logMessage: String, functionName: String, fileName: String, lineNumber: Int) {
        self.logLevel = logLevel
        self.date = date
        self.logMessage = logMessage
        self.functionName = functionName
        self.fileName = fileName
        self.lineNumber = lineNumber
    }
}

// MARK: - XCGLogDestinationProtocol
// - Protocol for output classes to conform to
public protocol XCGLogDestinationProtocol: CustomDebugStringConvertible {
    var owner: XCGLogger {get set}
    var identifier: String {get set}
    var outputLogLevel: XCGLogger.LogLevel {get set}

    func processLogDetails(_ logDetails: XCGLogDetails)
    func processInternalLogDetails(_ logDetails: XCGLogDetails) // Same as processLogDetails but should omit function/file/line info
    func isEnabledForLogLevel(_ logLevel: XCGLogger.LogLevel) -> Bool
}

// MARK: - XCGConsoleLogDestination
// - A standard log destination that outputs log details to the console
open class XCGConsoleLogDestination : XCGLogDestinationProtocol, CustomDebugStringConvertible {
    open var owner: XCGLogger
    open var identifier: String
    open var outputLogLevel: XCGLogger.LogLevel = .debug

    open var showFileName: Bool = true
    open var showLineNumber: Bool = true
    open var showLogLevel: Bool = true
    open var dateFormatter: DateFormatter? {
        return Thread.dateFormatter("yyyy-MM-dd HH:mm:ss.SSS")
    }

    public init(owner: XCGLogger, identifier: String = "") {
        self.owner = owner
        self.identifier = identifier
    }

    open func processLogDetails(_ logDetails: XCGLogDetails) {
        var extendedDetails: String = ""
        if showLogLevel {
            extendedDetails += "[" + logDetails.logLevel.description() + "] "
        }

        if showFileName {
            extendedDetails += "[" + (logDetails.fileName as NSString).lastPathComponent + (showLineNumber ? ":" + String(logDetails.lineNumber) : "") + "] "
        }
        else if showLineNumber {
            extendedDetails += "[" + String(logDetails.lineNumber) + "] "
        }

        var formattedDate: String = logDetails.date.description
        if let unwrappedDataFormatter = dateFormatter {
            formattedDate = unwrappedDataFormatter.string(from: logDetails.date)
        }

        let fullLogMessage: String =  "\(formattedDate) \(extendedDetails)\(logDetails.functionName): \(logDetails.logMessage)\n"

        XCGLogger.logQueue.async {
            //print(fullLogMessage, terminator: "")
        }
    }

    open func processInternalLogDetails(_ logDetails: XCGLogDetails) {
        var extendedDetails: String = ""
        if showLogLevel {
            extendedDetails += "[" + logDetails.logLevel.description() + "] "
        }

        var formattedDate: String = logDetails.date.description
        if let unwrappedDataFormatter = dateFormatter {
            formattedDate = unwrappedDataFormatter.string(from: logDetails.date)
        }

        let fullLogMessage: String =  "\(formattedDate) \(extendedDetails): \(logDetails.logMessage)\n"

        XCGLogger.logQueue.async {
            //print(fullLogMessage, terminator: "")
        }
    }

    // MARK: - Misc methods
    open func isEnabledForLogLevel (_ logLevel: XCGLogger.LogLevel) -> Bool {
        return logLevel >= self.outputLogLevel
    }

    // MARK: - DebugPrintable
    open var debugDescription: String {
        get {
            return "XCGConsoleLogDestination: \(identifier) - LogLevel: \(outputLogLevel.description()) showLogLevel: \(showLogLevel) showFileName: \(showFileName) showLineNumber: \(showLineNumber)"
        }
    }
}

// MARK: - XCGFileLogDestination
// - A standard log destination that outputs log details to a file
open class XCGFileLogDestination : XCGLogDestinationProtocol, CustomDebugStringConvertible {
    open var owner: XCGLogger
    open var identifier: String
    open var outputLogLevel: XCGLogger.LogLevel = .debug

    open var showFileName: Bool = true
    open var showLineNumber: Bool = true
    open var showLogLevel: Bool = true
    open var dateFormatter: DateFormatter? {
        return Thread.dateFormatter("yyyy-MM-dd HH:mm:ss.SSS")
    }

    fileprivate var writeToFileURL : URL? = nil {
        didSet {
            openFile()
        }
    }
    fileprivate var logFileHandle: FileHandle? = nil

    public init(owner: XCGLogger, writeToFile: AnyObject, identifier: String = "") {
        self.owner = owner
        self.identifier = identifier

        if writeToFile is NSString {
            writeToFileURL = URL(fileURLWithPath: writeToFile as! String)
        }
        else if writeToFile is URL {
            writeToFileURL = writeToFile as? URL
        }
        else {
            writeToFileURL = nil
        }

        openFile()
    }

    deinit {
        // close file stream if open
        closeFile()
    }

    // MARK: - Logging methods
    open func processLogDetails(_ logDetails: XCGLogDetails) {
        var extendedDetails: String = ""
        if showLogLevel {
            extendedDetails += "[" + logDetails.logLevel.description() + "] "
        }

        if showFileName {
            extendedDetails += "[" + (logDetails.fileName as NSString).lastPathComponent + (showLineNumber ? ":" + String(logDetails.lineNumber) : "") + "] "
        }
        else if showLineNumber {
            extendedDetails += "[" + String(logDetails.lineNumber) + "] "
        }

        var formattedDate: String = logDetails.date.description
        if let unwrappedDataFormatter = dateFormatter {
            formattedDate = unwrappedDataFormatter.string(from: logDetails.date)
        }

        let fullLogMessage: String =  "\(formattedDate) \(extendedDetails)\(logDetails.functionName): \(logDetails.logMessage)\n"

        if let encodedData = fullLogMessage.data(using: String.Encoding.utf8) {
            logFileHandle?.write(encodedData)
        }
    }

    open func processInternalLogDetails(_ logDetails: XCGLogDetails) {
        var extendedDetails: String = ""
        if showLogLevel {
            extendedDetails += "[" + logDetails.logLevel.description() + "] "
        }

        var formattedDate: String = logDetails.date.description
        if let unwrappedDataFormatter = dateFormatter {
            formattedDate = unwrappedDataFormatter.string(from: logDetails.date)
        }

        let fullLogMessage: String =  "\(formattedDate) \(extendedDetails): \(logDetails.logMessage)\n"

        if let encodedData = fullLogMessage.data(using: String.Encoding.utf8) {
            logFileHandle?.write(encodedData)
        }
    }

    // MARK: - Misc methods
    open func isEnabledForLogLevel (_ logLevel: XCGLogger.LogLevel) -> Bool {
        return logLevel >= self.outputLogLevel
    }

    fileprivate func openFile() {
        if logFileHandle != nil {
            closeFile()
        }

        if let unwrappedWriteToFileURL = writeToFileURL {
            if let path = unwrappedWriteToFileURL.path {
                FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
                var fileError : NSError? = nil
                do {
                    logFileHandle = try FileHandle(forWritingTo: unwrappedWriteToFileURL)
                } catch let error as NSError {
                    fileError = error
                    logFileHandle = nil
                }
                if logFileHandle == nil {
                    owner._logln("Attempt to open log file for writing failed: \(fileError?.localizedDescription)", logLevel: .error)
                }
                else {
                    owner.logAppDetails(self)

                    let logDetails = XCGLogDetails(logLevel: .info, date: Date(), logMessage: "XCGLogger writing to log to: \(unwrappedWriteToFileURL)", functionName: "", fileName: "", lineNumber: 0)
                    owner._logln(logDetails.logMessage, logLevel: logDetails.logLevel)
                    processInternalLogDetails(logDetails)
                }
            }
        }
    }

    fileprivate func closeFile() {
        logFileHandle?.closeFile()
        logFileHandle = nil
    }

    // MARK: - DebugPrintable
    open var debugDescription: String {
        get {
            return "XCGFileLogDestination: \(identifier) - LogLevel: \(outputLogLevel.description()) showLogLevel: \(showLogLevel) showFileName: \(showFileName) showLineNumber: \(showLineNumber)"
        }
    }
}

// MARK: - XCGLogger
// - The main logging class
open class XCGLogger : CustomDebugStringConvertible {
    // MARK: - Constants
    public struct constants {
        public static let defaultInstanceIdentifier = "com.cerebralgardens.xcglogger.defaultInstance"
        public static let baseConsoleLogDestinationIdentifier = "com.cerebralgardens.xcglogger.logdestination.console"
        public static let baseFileLogDestinationIdentifier = "com.cerebralgardens.xcglogger.logdestination.file"
        public static let nsdataFormatterCacheIdentifier = "com.cerebralgardens.xcglogger.nsdataFormatterCache"
        public static let logQueueIdentifier = "com.cerebralgardens.xcglogger.queue"
        public static let versionString = "1.8.1"
    }

    // MARK: - Enums
    public enum LogLevel: Int, Comparable {
        case verbose
        case debug
        case info
        case warning
        case error
        case severe
        case none

        public func description() -> String {
            switch self {
                case .verbose:
                    return "Verbose"
                case .debug:
                    return "Debug"
                case .info:
                    return "Info"
                case .warning:
                    return "Warning"
                case .error:
                    return "Error"
                case .severe:
                    return "Severe"
                case .none:
                    return "None"
            }
        }
    }

    // MARK: - Properties (Options)
    open var identifier: String = ""
    open var outputLogLevel: LogLevel = .debug {
        didSet {
            for index in 0 ..< logDestinations.count {
                logDestinations[index].outputLogLevel = outputLogLevel
            }
        }
    }

    // MARK: - Properties
    open class var logQueue : DispatchQueue {
        struct Statics {
            static var logQueue = DispatchQueue(label: XCGLogger.constants.logQueueIdentifier, attributes: [])
        }

        return Statics.logQueue
    }

    open var dateFormatter: DateFormatter? {
        return Thread.dateFormatter("yyyy-MM-dd HH:mm:ss.SSS")
    }
    open var logDestinations: Array<XCGLogDestinationProtocol> = []

    public init() {
        // Setup a standard console log destination
        addLogDestination(XCGConsoleLogDestination(owner: self, identifier: XCGLogger.constants.baseConsoleLogDestinationIdentifier))
    }

    // MARK: - Default instance
    open class func defaultInstance() -> XCGLogger {
        struct statics {
            static let instance: XCGLogger = XCGLogger()
        }
        statics.instance.identifier = XCGLogger.constants.defaultInstanceIdentifier
        return statics.instance
    }
    open class func sharedInstance() -> XCGLogger {
        self.defaultInstance()._logln("sharedInstance() has been renamed to defaultInstance() to better reflect that it is not a true singleton. Please update your code, sharedInstance() will be removed in a future version.", logLevel: .info)
        return self.defaultInstance()
    }

    // MARK: - Setup methods
    open class func setup(_ logLevel: LogLevel = .debug, showLogLevel: Bool = true, showFileNames: Bool = true, showLineNumbers: Bool = true, writeToFile: AnyObject? = nil) {
        defaultInstance().setup(logLevel, showLogLevel: showLogLevel, showFileNames: showFileNames, showLineNumbers: showLineNumbers, writeToFile: writeToFile)
    }

    open func setup(_ logLevel: LogLevel = .debug, showLogLevel: Bool = true, showFileNames: Bool = true, showLineNumbers: Bool = true, writeToFile: AnyObject? = nil) {
        outputLogLevel = logLevel;

        if let unwrappedLogDestination: XCGLogDestinationProtocol = logDestination(XCGLogger.constants.baseConsoleLogDestinationIdentifier) {
            if unwrappedLogDestination is XCGConsoleLogDestination {
                let standardConsoleLogDestination = unwrappedLogDestination as! XCGConsoleLogDestination

                standardConsoleLogDestination.showLogLevel = showLogLevel
                standardConsoleLogDestination.showFileName = showFileNames
                standardConsoleLogDestination.showLineNumber = showLineNumbers
                standardConsoleLogDestination.outputLogLevel = logLevel
            }
        }

        logAppDetails()

        if let unwrappedWriteToFile : AnyObject = writeToFile {
            // We've been passed a file to use for logging, set up a file logger
            let standardFileLogDestination: XCGFileLogDestination = XCGFileLogDestination(owner: self, writeToFile: unwrappedWriteToFile, identifier: XCGLogger.constants.baseFileLogDestinationIdentifier)

            standardFileLogDestination.showLogLevel = showLogLevel
            standardFileLogDestination.showFileName = showFileNames
            standardFileLogDestination.showLineNumber = showLineNumbers
            standardFileLogDestination.outputLogLevel = logLevel

            addLogDestination(standardFileLogDestination)
        }
    }

    // MARK: - Logging methods
    open class func logln(_ logMessage: String, logLevel: LogLevel = .debug, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        self.defaultInstance().logln(logMessage, logLevel: logLevel, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }

    open func logln(_ logMessage: String, logLevel: LogLevel = .debug, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        let date = Date()

        var logDetails: XCGLogDetails? = nil
        for logDestination in self.logDestinations {
            if (logDestination.isEnabledForLogLevel(logLevel)) {
                if logDetails == nil {
                    logDetails = XCGLogDetails(logLevel: logLevel, date: date, logMessage: logMessage, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
                }

                logDestination.processLogDetails(logDetails!)
            }
        }
    }

    open class func exec(_ logLevel: LogLevel = .debug, closure: () -> () = {}) {
        self.defaultInstance().exec(logLevel, closure: closure)
    }

    open func exec(_ logLevel: LogLevel = .debug, closure: () -> () = {}) {
        if (!isEnabledForLogLevel(logLevel)) {
            return
        }

        closure()
    }

    open func logAppDetails(_ selectedLogDestination: XCGLogDestinationProtocol? = nil) {
        let date = Date()

        var buildString = ""
        if let infoDictionary = Bundle.main.infoDictionary {
            if let CFBundleShortVersionString = infoDictionary["CFBundleShortVersionString"] as? String {
                buildString = "Version: \(CFBundleShortVersionString) "
            }
            if let CFBundleVersion = infoDictionary["CFBundleVersion"] as? String {
                buildString += "Build: \(CFBundleVersion) "
            }
        }

        let processInfo: ProcessInfo = ProcessInfo.processInfo
        let XCGLoggerVersionNumber = XCGLogger.constants.versionString

        let logDetails: Array<XCGLogDetails> = [XCGLogDetails(logLevel: .info, date: date, logMessage: "\(processInfo.processName) \(buildString)PID: \(processInfo.processIdentifier)", functionName: "", fileName: "", lineNumber: 0),
            XCGLogDetails(logLevel: .info, date: date, logMessage: "XCGLogger Version: \(XCGLoggerVersionNumber) - LogLevel: \(outputLogLevel.description())", functionName: "", fileName: "", lineNumber: 0)]

        for logDestination in (selectedLogDestination != nil ? [selectedLogDestination!] : logDestinations) {
            for logDetail in logDetails {
                if !logDestination.isEnabledForLogLevel(.info) {
                    continue;
                }

                logDestination.processInternalLogDetails(logDetail)
            }
        }
    }

    // MARK: - Convenience logging methods
    open class func verbose(_ logMessage: String, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        self.defaultInstance().verbose(logMessage, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }

    open func verbose(_ logMessage: String, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        self.logln(logMessage, logLevel: .verbose, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }

    open class func debug(_ logMessage: String, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        self.defaultInstance().debug(logMessage, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }

    open func debug(_ logMessage: String, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        self.logln(logMessage, logLevel: .debug, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }

    open class func info(_ logMessage: String, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        self.defaultInstance().info(logMessage, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }

    open func info(_ logMessage: String, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        self.logln(logMessage, logLevel: .info, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }

    open class func warning(_ logMessage: String, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        self.defaultInstance().warning(logMessage, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }

    open func warning(_ logMessage: String, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        self.logln(logMessage, logLevel: .warning, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }
    
    open class func error(_ logMessage: String, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        self.defaultInstance().error(logMessage, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }

    open func error(_ logMessage: String, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        self.logln(logMessage, logLevel: .error, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }
    
    open class func severe(_ logMessage: String, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        self.defaultInstance().severe(logMessage, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }

    open func severe(_ logMessage: String, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        self.logln(logMessage, logLevel: .severe, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }

    open class func verboseExec(_ closure: () -> () = {}) {
        self.defaultInstance().exec(XCGLogger.LogLevel.verbose, closure: closure)
    }

    open func verboseExec(_ closure: () -> () = {}) {
        self.exec(XCGLogger.LogLevel.verbose, closure: closure)
    }
    
    open class func debugExec(_ closure: () -> () = {}) {
        self.defaultInstance().exec(XCGLogger.LogLevel.debug, closure: closure)
    }

    open func debugExec(_ closure: () -> () = {}) {
        self.exec(XCGLogger.LogLevel.debug, closure: closure)
    }
    
    open class func infoExec(_ closure: () -> () = {}) {
        self.defaultInstance().exec(XCGLogger.LogLevel.info, closure: closure)
    }

    open func infoExec(_ closure: () -> () = {}) {
        self.exec(XCGLogger.LogLevel.info, closure: closure)
    }
    
    open class func warningExec(_ closure: () -> () = {}) {
        self.defaultInstance().exec(XCGLogger.LogLevel.warning, closure: closure)
    }

    open func warningExec(_ closure: () -> () = {}) {
        self.exec(XCGLogger.LogLevel.warning, closure: closure)
    }

    open class func errorExec(_ closure: () -> () = {}) {
        self.defaultInstance().exec(XCGLogger.LogLevel.error, closure: closure)
    }

    open func errorExec(_ closure: () -> () = {}) {
        self.exec(XCGLogger.LogLevel.error, closure: closure)
    }
    
    open class func severeExec(_ closure: () -> () = {}) {
        self.defaultInstance().exec(XCGLogger.LogLevel.severe, closure: closure)
    }

    open func severeExec(_ closure: () -> () = {}) {
        self.exec(XCGLogger.LogLevel.severe, closure: closure)
    }

    // MARK: - Misc methods
    open func isEnabledForLogLevel (_ logLevel: XCGLogger.LogLevel) -> Bool {
        return logLevel >= self.outputLogLevel
    }

    open func logDestination(_ identifier: String) -> XCGLogDestinationProtocol? {
        for logDestination in logDestinations {
            if logDestination.identifier == identifier {
                return logDestination
            }
        }

        return nil
    }

    open func addLogDestination(_ logDestination: XCGLogDestinationProtocol) -> Bool {
        let existingLogDestination: XCGLogDestinationProtocol? = self.logDestination(logDestination.identifier)
        if existingLogDestination != nil {
            return false
        }

        logDestinations.append(logDestination)
        return true
    }

    open func removeLogDestination(_ logDestination: XCGLogDestinationProtocol) {
        removeLogDestination(logDestination.identifier)
    }

    open func removeLogDestination(_ identifier: String) {
        logDestinations = logDestinations.filter({$0.identifier != identifier})
    }

    // MARK: - Private methods
    fileprivate func _logln(_ logMessage: String, logLevel: LogLevel = .debug) {
        let date = Date()

        var logDetails: XCGLogDetails? = nil
        for logDestination in self.logDestinations {
            if (logDestination.isEnabledForLogLevel(logLevel)) {
                if logDetails == nil {
                    logDetails = XCGLogDetails(logLevel: logLevel, date: date, logMessage: logMessage, functionName: "", fileName: "", lineNumber: 0)
                }

                logDestination.processInternalLogDetails(logDetails!)
            }
        }
    }

    // MARK: - DebugPrintable
    open var debugDescription: String {
        get {
            var description: String = "XCGLogger: \(identifier) - logDestinations: \r"
            for logDestination in logDestinations {
                description += "\t \(logDestination.debugDescription)\r"
            }

            return description
        }
    }
}

// Implement Comparable for XCGLogger.LogLevel
public func < (lhs:XCGLogger.LogLevel, rhs:XCGLogger.LogLevel) -> Bool {
    return lhs.rawValue < rhs.rawValue
}

// This operation shouldn't be required, since providing < is all that is needed, however, the compiler crashes when optimization is enabled.
// Adding this operator works around the optimization bug.
// Thanks to @beltex https://github.com/beltex for helping to narrow this down.
public func >= (lhs:XCGLogger.LogLevel, rhs:XCGLogger.LogLevel) -> Bool {
    return lhs.rawValue > rhs.rawValue || lhs.rawValue == rhs.rawValue
}
