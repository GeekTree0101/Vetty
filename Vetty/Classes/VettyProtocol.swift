//
//  VettyProtocol.swift
//  Vetty
//
//  Created by Geektree0101 on 12/01/18.
//  Copyright © 2018 Geektree0101. All rights reserved.
//

import Foundation

public protocol VettyProtocol: Decodable {
    
    var uniqueKey: VettyIdentifier { get }
    func commitSubModelIfNeeds()
}

extension VettyProtocol {
    
    typealias TargetModel = Self
    
    internal static func identifierForProvider(_ uniqueKey: VettyIdentifier) -> String {
        return "\(TargetModel.self)-\(uniqueKey.id)"
    }
    
    internal func identifierForProvider() -> String {
        return "\(TargetModel.self)-\(self.uniqueKey.id)"
    }
    
    internal func automaticallyCommitSubModelIfNeeds() {
        (self as TargetModel).commitSubModelIfNeeds()
    }
}

/**
 Vetty Model Identifier
 
 - important: Model have to inherit VettyProtocol!
 
 - author: Geektree0101
 */
public protocol VettyIdentifier {
    
    var id: String { get }
}

extension Int: VettyIdentifier {
    
    public var id: String {
        return "\(self)"
    }
}

extension String: VettyIdentifier {
    
    public var id: String {
        return self
    }
}
