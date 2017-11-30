import Foundation

// Byte operations
public func switchEndianFormat(bytes: UnsafeMutableRawPointer, numBytes: Int) {
    let uintBytes = bytes.assumingMemoryBound(to: UInt8.self)
    let numSwaps = numBytes / 2
    var holdByte: UInt8?
    
    for i: Int in 0 ..< numSwaps {
        holdByte = uintBytes[i]
        uintBytes[i] = uintBytes[numBytes - i - 1]
        uintBytes[numBytes - i - 1] = holdByte!
    }
}
