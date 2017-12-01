//: Playground - noun: a place where people can play

import UIKit

do {
    let fileURL = Bundle.main.url(forResource: "batch", withExtension: "xml")
    let fileContents = try String(contentsOf: fileURL!, encoding: String.Encoding.utf8)
    print("File: batch.xml");
    print("File contents:")
    print(fileContents)
    
    
} catch {
    print("Error reading file")
}


private func readFile(output: inout Data?, numCharsRead: inout Int32) -> Bool {
    var success = true
    let fileURL = Bundle.main.url(forResource: "batch", withExtension: "xml")
    if(fileURL != nil) {
        do {
            var count = 0
            let fileContents = try String(contentsOf: fileURL!, encoding: .utf8)
            let output = fileContents.data(using: .utf8)
            numCharsRead = Int32(fileContents.count)
        } catch {
            success = false
        }
    }
    else {
        success = false
    }
    return success
}

private func communicateFileWithServer(transmissionData: Data, transmissionSize: Int32, receptionData: inout Data?) -> Bool {
    let IP_ADDR = "10.3.0.136"
    let PORT_NUM = 6612         // Quoter application
    //let PORT_NUM = 8000       // Generic server
    
    var success = false
    var mutableTransmitSize = transmissionSize
    var receptionSize: Data?
    switchEndianFormat(bytes: &mutableTransmitSize, numBytes: MemoryLayout<Int32>.stride)
    
    let tcpClient = TCPClient(serverIP: IP_ADDR, serverPortNum: PORT_NUM)
    tcpClient.openConnectionStreams()
    
    if(tcpClient.transmitData(storage: Data(bytes: &mutableTransmitSize, count: MemoryLayout<Int32>.stride)) == true) {
        if(tcpClient.transmitData(storage: transmissionData) == true) {
            if(tcpClient.receiveData(storage: &receptionSize, expectedNumBytes: 4) == true) {
                var numReceptionBytes: Int32 = receptionSize!.withUnsafeBytes({(receptionSizePtr: UnsafePointer<Int32>) in
                    return receptionSizePtr.pointee
                })
                switchEndianFormat(bytes: &numReceptionBytes, numBytes: MemoryLayout<Int32>.stride)
                NSLog("NetworkCommunicator: Number of bytes expected to be received: \(numReceptionBytes)")
                if(tcpClient.receiveData(storage: &receptionData, expectedNumBytes: Int(numReceptionBytes)) ==  true) {
                    success = true
                }
            }
        }
    }
    
    tcpClient.closeConnectionStreams()
    
    return success
}
