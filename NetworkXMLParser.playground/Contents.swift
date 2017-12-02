//: Playground - noun: a place where people can play

import UIKit


private func readFile(output: inout Data?, numCharsRead: inout Int32) -> Bool {
    var success = true
    let fileURL = Bundle.main.url(forResource: "batch", withExtension: "xml")
    if(fileURL != nil) {
        do {
            let fileContents = try String(contentsOf: fileURL!, encoding: .utf8)
            output = fileContents.data(using: .utf8)
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
                if(tcpClient.receiveData(storage: &receptionData, expectedNumBytes: Int(numReceptionBytes)) ==  true) {
                    success = true
                }
            }
        }
    }
    
    tcpClient.closeConnectionStreams()
    
    return success
}


class XMLParseHandler_2: NSObject, XMLParserDelegate {
    var currentElementKey: String?
    var currentPartNode: XMLNode?
    
    var resultReport: XMLValue?
    var resultPartNodes: [XMLNode] = []
    
    // Properties
    var Report: XMLValue? {
        return resultReport
    }
    
    var Parts: [XMLNode] {
        return resultPartNodes
    }
    
    
    // Member functions
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        currentElementKey = elementName
        if(elementName == "part") {
            currentPartNode = XMLNode(elementKey: elementName)
        }
    }
    
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        if(string != "") {
            if(currentElementKey != nil) {
                if(currentElementKey == "report") {
                    resultReport = XMLValue(xmlKey: currentElementKey!, xmlElement: string)
                } else if(currentElementKey == "part_name" ||
                    currentElementKey == "part_size" ||
                    currentElementKey == "part_time" ||
                    currentElementKey == "part_nc") {
                    
                    if(currentPartNode != nil) {
                        let xmlVal = XMLValue(xmlKey: currentElementKey!, xmlElement: string)
                        currentPartNode?.addElement(element: xmlVal)
                    }
                }
            }
        }
    }
    
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if(elementName == "part" && currentPartNode != nil) {
            resultPartNodes.append(currentPartNode!)
            currentPartNode = nil
        }
        currentElementKey = nil
    }
}

class XMLParseHandler: NSObject, XMLParserDelegate {
    private var myCurrentXMLElementKey: String?
    private var myXMLElements: [XMLValue] = []
    
    var Parts: [XMLValue] {
        return myXMLElements
    }
    
    // Member functions
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        myCurrentXMLElementKey = elementName
    }
    
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        if myCurrentXMLElementKey != nil {
            let xmlValue = XMLValue(xmlKey: myCurrentXMLElementKey!, xmlElement: string)
            myXMLElements.append(xmlValue)
            myCurrentXMLElementKey = nil
        }
    }
}



func parseJobResultsXML(resultsDataToParse data: Data) -> XMLDocument {
    let xmlParser = XMLParser(data: data)
    let xmlParseHandler = XMLParseHandler_2()
    xmlParser.delegate = xmlParseHandler
    xmlParser.parse()
    
    var xmlDoc = XMLDocument(rootName: "result")
    var partsNode = XMLNode(elementKey: "parts")
    let report = xmlParseHandler.Report
    
    let parts = xmlParseHandler.Parts
    for part in parts {
        partsNode.addElement(element: part)
    }
    xmlDoc.addXMLElement(xmlElement: partsNode)
    if(report != nil) {
        xmlDoc.addXMLElement(xmlElement: report!)
    }
    return xmlDoc
}




func printReport(xmlDoc: XMLDocument) {
    var report: XMLValue?
    var index = 0
    while index < xmlDoc.XMLElements.count &&
        xmlDoc.XMLElements[index].XMLKey != "report" {
            
            index += 1
    }
    if(index < xmlDoc.XMLElements.count) {
        report = (xmlDoc.XMLElements[index] as! XMLValue)
        print(report!.XMLElement)
    }
}

func printParts(xmlDoc: XMLDocument) {
    var index = 0
    while index < xmlDoc.XMLElements.count &&
        xmlDoc.XMLElements[index].XMLKey != "parts" {
            
            index += 1
    }
    if(index < xmlDoc.XMLElements.count) {
        let parts = xmlDoc.XMLElements[index] as! XMLNode
        for part in parts.XMLElements {
            for element in (part as! XMLNode).XMLElements {
                print("\((element as! XMLValue).XMLKey): \((element as! XMLValue).XMLElement)")
            }
            print("")
        }
    }
}

func printNumberOfElementsInXMLDoc(xmlDoc: XMLDocument) {
    print(xmlDoc.XMLElements.count)
}









var transmissionData: Data?
var receptionData: Data?
var transmissionSize: Int32 = 0

// reading batch file to send to server
if(readFile(output: &transmissionData, numCharsRead: &transmissionSize) == true) {
    if(communicateFileWithServer(transmissionData: transmissionData!, transmissionSize: transmissionSize, receptionData: &receptionData) == true) {
        let xmlParseToolPart = XMLSingleElementParseTool(xmlData: receptionData!, keyToParse: "part")
        let xmlParseToolReport = XMLSingleElementParseTool(xmlData: receptionData!, keyToParse: "report")
        
        
        var partIndex = 0
        var partsList: [String] = []
        var report = xmlParseToolReport.getContentsOfNthElementOfKey(nthElement: 0)
        while let part = xmlParseToolPart.getContentsOfNthElementOfKey(nthElement: partIndex) {
            partsList.append(part)
            partIndex += 1
        }
    }
}
print("Done")









