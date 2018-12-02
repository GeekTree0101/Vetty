//
//  Vetty.swift
//  Vetty
//
//  Created by Geektree0101 on 12/01/18.
//  Copyright © 2018 Geektree0101. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class Vetty: NSObject {
    
    public static let shared = Vetty.init()
    private var dataContainer: [String: VettyProtocol] = [:]
    private let queue = DispatchQueue(label: "Vetty.ModelProvider.queue",
                                      qos: .default,
                                      attributes: .concurrent)
    internal let emitter = PublishSubject<VettyProtocol?>()
    
    
    /**
     Commit New or Updated Model Object
     
     - parameters:
     - model: Model inherits from VettyProtocol
     - ignoreSubModel: ignore automatically commit sub-model
     
     - returns: VettyIdentifier
     
     - author: Geektree0101
     */
    @discardableResult public func commit(_ model: VettyProtocol,
                                          ignoreSubModel: Bool = true) -> VettyIdentifier {
        
        queue.async(flags: .barrier) {
            
            if !ignoreSubModel {
                model.automaticallyCommitSubModelIfNeeds()
            }
            self.dataContainer[model.identifierForProvider()] = model
            self.emitter.onNext(model)
        }
        
        return model.uniqueKey
    }
    
    
    /**
     Commit New or Updated Model Array
     
     - parameters:
     - models: Model Array inherits from VettyProtocol
     - ignoreSubModel: ignore automatically commit sub-model
     
     - returns: Array<VettyIdentifier>
     
     - author: Geektree0101
     */
    @discardableResult public func commit(_ models: [VettyProtocol],
                                          ignoreSubModel: Bool = true) -> [VettyIdentifier] {
        
        return models.map({ self.commit($0, ignoreSubModel: ignoreSubModel) })
    }
    
    
    /**
     Commit Optional New or Updated Model Object
     
     - parameters:
     - model: Optional Model inherits from VettyProtocol
     - ignoreSubModel: ignore automatically commit sub-model
     
     - returns: Optinal<VettyIdentifier>
     
     - author: Geektree0101
     */
    @discardableResult public func commitIfNeeds(_ model: VettyProtocol?,
                                                 ignoreSubModel: Bool = true) -> VettyIdentifier? {
        
        guard let model = model else { return nil }
        return self.commit(model, ignoreSubModel: ignoreSubModel)
    }
    
    
    /**
     Commit Optional New or Updated Model Array
     
     - parameters:
     - model: Optional Model Array inherits from VettyProtocol
     - ignoreSubModel: ignore automatically commit sub-model
     
     - returns: Optinal<Array<VettyIdentifier>>
     
     - author: Geektree0101
     */
    @discardableResult public func commitIfNeeds(_ models: [VettyProtocol]?,
                                                 ignoreSubModel: Bool = true) -> [VettyIdentifier]? {
        
        guard let models = models else { return nil }
        return self.commit(models, ignoreSubModel: ignoreSubModel)
    }
    
    /**
     Read Model Object from dataContainer
     
     - parameters:
     - type: Model type which inherits from VettyProtocol
     - id: VettyIdentifier (Model identifier)
     
     - returns: Optinal<Array<VettyIdentifier>>
     
     - author: Geektree0101
     */
    public func read<T: VettyProtocol>(type: T.Type, uniqueKey: VettyIdentifier) -> T? {
        
        var model: T?
        queue.sync {
            let identifier = T.identifierForProvider(uniqueKey)
            model = self.dataContainer[identifier] as? T
        }
        return model
    }
    
    public func clear() {
        
        queue.sync {
            self.dataContainer = [:]
        }
    }
}
