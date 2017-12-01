import Foundation

public struct TCPClient {
    private var myInput: InputStream?
    private var myOutput: OutputStream?
    
    public init(serverIP: String, serverPortNum: Int) {
        Stream.getStreamsToHost(withName: serverIP, port: serverPortNum, inputStream: &myInput, outputStream: &myOutput)
    }
    
    // Connection options
    public func openConnectionStreams() {
        myInput?.open()
        myOutput?.open()
    }
    
    public func closeConnectionStreams() {
        myInput?.close()
        myOutput?.close()
    }
    
    
    // I/O Operations
    public func transmitData(storage: Data) -> Bool {
        let numBytesTransmitted = storage.withUnsafeBytes {
            myOutput?.write($0, maxLength: storage.count)
        }
        if(numBytesTransmitted! < 0) {
            return false
        }
        else {
            return true
        }
    }
    
    public func receiveData(storage: inout Data?, expectedNumBytes maxBytes: Int) -> Bool {
        let byteFrame = 2048
        var numBytesToRead = 0
        var numBytesReceived = 0
        var dataBuffer: Data?
        storage = Data(count: 0)
        
        print("TCPClient: expectedNumBytes = \(maxBytes)")
        while(numBytesReceived < maxBytes) {
            print("TCPClient: numBytesReceived = \(numBytesReceived)")
            print("TCPClient: numBytesToRead = \(numBytesToRead)")
            if(maxBytes - numBytesReceived < byteFrame) {
                numBytesToRead = maxBytes - numBytesReceived
            } else {
                numBytesToRead = byteFrame
            }
            dataBuffer = Data(count: numBytesToRead)
            let bytesReadFromBuffer = dataBuffer!.withUnsafeMutableBytes {
                myInput?.read($0, maxLength: numBytesToRead)
            }
            if(bytesReadFromBuffer! <= 0) {
                print("Failed to receive packet")
                return false
            } else {
                storage!.append(dataBuffer!)
                numBytesReceived += bytesReadFromBuffer!
            }
        }
        
        print("Number of bytes received: \(numBytesReceived)")
        
        return true
    }
    
    public func receiveData_2(storage: inout Data) -> Bool {
        let numBytesReceived = storage.withUnsafeMutableBytes {
            myInput?.read($0, maxLength: storage.count)
        }
        if(numBytesReceived! < 0) {
            return false
        }
        else {
            return true
        }
    }
}

