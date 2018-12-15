//
//  Vetty+Extension.swift
//  Vetty
//
//  Created by Geektree0101 on 12/01/18.
//  Copyright © 2018 Geektree0101. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension ObservableType {
    
    /**
     Model Mutating ObservableType
     
     - parameters:
     - observable: Observable<VettyProtocol>
     - ignoreSubModel: ignore automatically commit sub-model
     
     - returns: Disposable
     
     - author: Geektree0101
     */
    public func mutate<T: VettyProtocol>(with observable: Observable<T?>,
                                          ignoreSubModel: Bool = true,
                                          _ transform: @escaping (T?, Self.E) throws -> T?) -> Disposable {
        return self.withLatestFrom(observable) { ($1, $0) }
            .map(transform)
            .bind(to: Vetty.shared.rx.mutate(ignoreSubModel: ignoreSubModel))
    }
}

extension Observable where Element == VettyIdentifier? {
    
    /**
     Convert to Taget Model
     
     - parameters:
     - type: VettyProtocol inherited model
     
     - returns: Observable<VettylProtocol?>
     
     - author: Geektree0101
     */
    public func asModel<T: VettyProtocol>(type: T.Type) -> Observable<T?> {
        
        return self.asObservable()
            .filter { $0 != nil }
            .map { $0! }
            .take(1)
            .flatMap { Vetty.rx.model(type: type, uniqueKey: $0) }
    }
}

extension ObservableType where E: VettyProtocol {
    
    /**
     Commit Model of Object ObservableType
     
     - important: reference -> Vetty.swift commit method
     
     - parameters:
     - ignoreSubModel: ignore automatically commit sub-model
     
     - returns: Observable<VettyIdentifier>
     
     - author: Geektree0101
     */
    public func commit(ignoreSubModel: Bool) -> Observable<VettyIdentifier> {
        
        return self.map({ Vetty.shared.commit($0, ignoreSubModel: ignoreSubModel) })
    }
}

extension ObservableType where E: Sequence, E.Iterator.Element: VettyProtocol {
    
    /**
     Commit Model of Array ObservableType
     
     - important: reference -> Vetty.swift commit method
     
     - parameters:
     - ignoreSubModel: ignore automatically commit sub-model
     
     - returns: Observable<VettyIdentifier>
     
     - author: Geektree0101
     */
    public func commits(ignoreSubModel: Bool = true) -> Observable<[VettyIdentifier]> {
        
        return self.map({ $0.map({ Vetty.shared.commit($0, ignoreSubModel: ignoreSubModel) })})
    }
}

extension Reactive where Base: Vetty {
    
    /**
     Create observable model from Vetty
     
     - parameters:
     - type: VettyModel type
     - uniqueKey: VettyIdentifier
     
     - returns: Observable<VettyProtocol>
     
     - author: Geektree0101
     */
    public static func model<T: VettyProtocol>(type: T.Type,
                                               uniqueKey: VettyIdentifier) -> Observable<T?> {
        
        return Vetty.shared.rx.model(type: type, uniqueKey: uniqueKey)
    }
    
    
    /**
     Model Mutating ObservableType
     
     - parameters:
     - ignoreSubModel: ignore automatically commit sub-model
     
     - returns: Binder<Optional<VettyProtocol>>
     
     - author: Geektree0101
     */
    public func mutate(ignoreSubModel: Bool = true) -> Binder<VettyProtocol?> {
        
        return Binder(base) { provider, model in
            guard let model = model else { return }
            provider.commit(model, ignoreSubModel: ignoreSubModel)
        }
    }
    
    
    private func model<T: VettyProtocol>(type: T.Type,
                                         uniqueKey: VettyIdentifier) -> Observable<T?> {
        
        let identifier = T.identifierForProvider(uniqueKey)
        return base.emitter
            .filter({ $0?.identifierForProvider() == identifier })
            .map { $0 as? T }
            .startWith(base.read(type: type, uniqueKey: uniqueKey))
            .share(replay: 1, scope: .whileConnected)
    }
}
