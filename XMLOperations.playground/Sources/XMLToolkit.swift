import Foundation

public protocol XMLElement: CustomStringConvertible {
    var XMLKey: String { get }
    var description: String { get }
}

public struct XMLValue: CustomStringConvertible, XMLElement {
    private let myXMLKey: String
    private let myXMLElement: String
    
    public init(xmlKey: String, xmlElement: String) {
        myXMLKey = xmlKey
        myXMLElement = xmlElement
    }
    
    // Properties
    public var XMLKey: String {
        return myXMLKey
    }
    
    public var XMLElement: String {
        return myXMLElement
    }
    
    public var description: String {
        return "<\(myXMLKey)>\(myXMLElement)</\(myXMLKey)>"
    }
}

public struct XMLNode: CustomStringConvertible, XMLElement {
    private var myXMLKey: String
    private var myXMLElements: [XMLElement]
    
    public init(elementKey: String) {
        myXMLKey = elementKey
        myXMLElements = []
    }
    
    // Properties
    public var XMLKey: String {
        return myXMLKey
    }
    
    public var description: String {
        var output = "<\(myXMLKey)>"
        for element in myXMLElements {
            output += "\(element)"
        }
        output += "</\(myXMLKey)>"
        return output
    }
    
    
    // Member functions
    public mutating func addElement(element: XMLElement) {
        myXMLElements.append(element)
    }
    
    public func getElement(_ key: String) -> XMLElement? {
        for element in myXMLElements {
            if element.XMLKey == key {
                return element
            }
        }
        return nil
    }
}

public struct XMLDocument: CustomStringConvertible {
    
    private let myRootName: String
    private var myXMLElements: [XMLElement]
    
    public init(rootName: String) {
        myRootName = rootName
        myXMLElements = [XMLNode]()
    }
    
    // Properties
    public var RootName: String {
        return myRootName
    }
    
    public var XMLElements: [XMLElement] {
        return myXMLElements
    }
    
    public var description: String {
        var output = "<\(myRootName)>"
        for i in 0 ..< myXMLElements.count {
            output += "\(myXMLElements[i])"
        }
        output += "</\(myRootName)>"
        return output
    }
    
    public var data: Data {
        return description.data(using: .utf8)!
    }
    
    
    // Member functions
    public mutating func addXMLElement(xmlElement: XMLElement) {
        myXMLElements.append(xmlElement)
    }
}
