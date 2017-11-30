//: Playground - noun: a place where people can play

import UIKit

let amadaIPAddr = "10.3.0.136"
let amadaPortNum = 6612
//let amadaPortNum = 8000




do {
    let fileURL = Bundle.main.url(forResource: "batch", withExtension: "xml")
    let fileContents = try String(contentsOf: fileURL!, encoding: String.Encoding.utf8)
    print("File: batch.txt");
    print("File contents:")
    print(fileContents)
    
    
    // Initialize connection
    let fileClient = CoreCommunicator(serverIP: amadaIPAddr, serverPortNum: amadaPortNum)
    fileClient.openConnectionStreams()
    
    var fileSize = UInt32(fileContents.count)
    withUnsafeMutablePointer(to: &fileSize, {
        switchEndianFormat(bytes: UnsafeMutableRawPointer($0), numBytes: 4)
    })
    
    
    // Server communication
    var sizeResponse: Data?
    var serverResponse: Data?
    
    print("Sending size...")
    fileClient.transmitData(storage: Data(bytes: &fileSize, count: 4))
    print("Size sent")
    
    print("Sending file...")
    fileClient.transmitData(storage: fileContents.data(using: .utf8)!)
    print("File sent")
    
    print("Receiving size...")
    fileClient.receiveData(storage: &sizeResponse, expectedNumBytes: 4)
    //fileClient.receiveData_2(storage: &sizeResponse)
    print("Size received")
    
    print("Receiving response...")
    var size = sizeResponse!.withUnsafeBytes({(sizePtr: UnsafePointer<Int32>) in
        sizePtr.pointee
    })
    switchEndianFormat(bytes: &size, numBytes: 4)
    print("Number of bytes expected: \(size)")
    fileClient.receiveData(storage: &serverResponse, expectedNumBytes: Int(size))
    //fileClient.receiveData_2(storage: &serverResponse!)
    print("Response received")
    print("")
    
    print("Response:")
    print(String(data: serverResponse!, encoding: .utf8)!)
} catch {
    print("Error reading file")
}
