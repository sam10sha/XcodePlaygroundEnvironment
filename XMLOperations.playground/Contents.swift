//: Playground - noun: a place where people can play

import UIKit

public class XMLParseTool {
    private let myXMLData: Data
    private var myXMLDoc: XMLDocument?
    
    public init(xmlData: Data) {
        myXMLData = xmlData
        myXMLDoc = nil
    }
    
    // PROPERTIES
    public var XMLDoc: XMLDocument? {
        return myXMLDoc
    }
    
    
    // MEMBER FUNCTIONS
    public func parse() {
        /* let strData = String(data: myXMLData, encoding: .utf8)
        var currentElementKey: String?
        var currentElementContent?
        
        currentElementKey = getFirstElementKey(strToParse: strData)
        if(currentElementKey != nil) {
            currentElementContent = getContentsOfFirstElementOfKey(strtoParse: strData, elementKey: currentElementKey)
            if(currentElementContent != nil) {
                myXMLDoc = XMLDocument(rootName: currentElementKey)
            }
            else {
                return
            }
        } */
    }
    
    
    private func getFirstElementKey(strToParse string: String) -> String? {
        let strArray: Array = Array(string)
        var j: Int = -1
        
        for i in 0 ..< string.count {
            if j < 0 && strArray[i] == "<" {
                j = i + 1
            }
            else if j >= 0 && strArray[i] == ">" {
                return String(string[String.Index(encodedOffset: j) ..< String.Index(encodedOffset: i)])
            }
        }
        return nil
    }
    
    
    fileprivate static func getContentsOfNthElementOfKey(xmlToParse string: String, elementKey key: String, nthElement n: Int) -> String? {
        let startTag = "<\(key)>"
        let endTag = "</\(key)>"
        
        var startIndices: [String.Index] = []
        var endIndices: [String.Index] = []
        
        var searchRange = string.startIndex ..< string.endIndex
        while let range = string.range(of: startTag, options: .caseInsensitive, range: searchRange) {
            searchRange = range.upperBound..<searchRange.upperBound
            startIndices.append(range.upperBound)
        }
        
        searchRange = string.startIndex ..< string.endIndex
        while let range = string.range(of: endTag, options: .caseInsensitive, range: searchRange) {
            searchRange = range.upperBound..<searchRange.upperBound
            endIndices.append(range.lowerBound)
        }
        
        if startIndices.count != endIndices.count ||
            n > startIndices.count - 1 {
            
            return nil
        }
        
        let startIndex = startIndices[n].encodedOffset
        let endIndex = endIndices[endIndices.count - n - 1].encodedOffset
        return String(string[String.Index(encodedOffset: startIndex) ..< String.Index(encodedOffset: endIndex)])
    }
    
    
    
    /* fileprivate static func getContentsOfNthElementOfKey(strtoParse string: String, elementKey key: String, nthElement n: Int) -> String? {
        let startTag = "<\(key)>"
        let endTag = "</\(key)>"
        
        var elementLowerBound: Int = -1
        var elementUpperBound: Int = -1
        
        var currentStr = string
        var tagLocation: Range<String.Index>?
        var skipped: Int = -1
        while(skipped < n) {
            tagLocation = currentStr.range(of: startTag)
            if(tagLocation != nil) {
                skipped += 1
                currentStr = String(currentStr[tagLocation!.upperBound...])
            }
            else {
                return nil
            }
        }
        
        elementLowerBound = tagLocation!.upperBound.encodedOffset
        
        var numElementsOpen = 0
        var startTagLocation: Range<String.Index>?
        var endTagLocation: Range<String.Index>?
        repeat {
            startTagLocation = currentStr.range(of: startTag)
            endTagLocation = currentStr.range(of: endTag)
            
            if endTagLocation == nil {
                return nil
            } else if startTagLocation == nil {
                if(numElementsOpen == 0) {
                    elementUpperBound = endTagLocation!.lowerBound.encodedOffset
                } else {
                    numElementsOpen -= 1
                    currentStr = String(currentStr[endTagLocation!.upperBound...])
                }
            } else if startTagLocation!.lowerBound.encodedOffset < endTagLocation!.lowerBound.encodedOffset {
                numElementsOpen += 1
                currentStr = String(currentStr[startTagLocation!.upperBound...])
            } else {
                numElementsOpen -= 1
                currentStr = String(currentStr[endTagLocation!.upperBound...])
            }
        } while(elementUpperBound < 0)
        
        return String(string[String.Index(encodedOffset: elementLowerBound) ..< String.Index(encodedOffset: elementLowerBound + elementUpperBound)])
    } */
    
    /* fileprivate static func getContentsOfNthElementOfKey_2(strtoParse string: String, elementKey key: String, nthElement n: Int) -> String? {
        let startTag = "<\(key)>"
        let endTag = "</\(key)>"
        
        var skipped: Int = -1
        var i: Int = 0
        var j: Int = -1
        while(i < string.count - startTag.count + 1 && j < 0) {
            if string[String.Index(encodedOffset: i) ..< String.Index(encodedOffset: i+startTag.count)] == startTag {
                skipped += 1
                
                if(skipped == n) {
                    j = i + startTag.count
                }
            }
            i += 1
        }
        
        if(j >= 0) {
            var numElementsOpen: Int = 0
            i = j;
            while(i < string.count - endTag.count + 1) {
                if string[String.Index(encodedOffset: i) ..< String.Index(encodedOffset: i+startTag.count)] == startTag {
                    numElementsOpen += 1
                }
                else if string[String.Index(encodedOffset: i) ..< String.Index(encodedOffset: i+endTag.count)] == endTag {
                    if(numElementsOpen == 0) {
                        return String(string[String.Index(encodedOffset: j) ..< String.Index(encodedOffset: i)])
                    }
                    numElementsOpen -= 1
                }
                
                i += 1
            }
        }
        
        return nil
    } */
}



do {
    let fileURL = Bundle.main.url(forResource: "result", withExtension: "xml")
    let result = try String(contentsOf: fileURL!, encoding: .utf8)
    
    let part = XMLParseTool.getContentsOfNthElementOfKey(xmlToParse: result, elementKey: "part", nthElement: 0)
    print(part!)
} catch {
    print("Error reading file")
}







/* let x = "<parts><part><part>hello world</part></part></parts>"
let z = ""
let y = XMLParseTool.getContentsOfNthElementOfKey(xmlToParse: x, elementKey: "part", nthElement: 0)

print("y = \(y ?? "nil")") */

