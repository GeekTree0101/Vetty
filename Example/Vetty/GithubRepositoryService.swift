import Foundation
import RxAlamofire
import Alamofire
import RxSwift
import RxCocoa

class Network {
    
    static let shared = Network()
    
    class Network {
        static let shared = Network()
        
        func get(url: String, params: [String: Any]?) -> Single<Data> {
            return Observable.create({ operation in
                do {
                    let convertedURL = try url.asURL()
                    
                    let nextHandler: (HTTPURLResponse, Any) -> Void = { res, data in
                        do {
                            let rawData = try JSONSerialization.data(withJSONObject: data, options: [])
                            operation.onNext(rawData)
                            operation.onCompleted()
                        } catch {
                            let error = NSError(domain: "failed JSONSerialization",
                                                code: 0,
                                                userInfo: nil)
                            operation.onError(error)
                        }
                    }
                    
                    let errorHandler: (Error) -> Void = { error in
                        operation.onError(error)
                    }
                    
                    _ = RxAlamofire.requestJSON(.get,
                                                convertedURL,
                                                parameters: params,
                                                encoding: URLEncoding.default,
                                                headers: nil)
                        .subscribe(onNext: nextHandler,
                                   onError: errorHandler)
                    
                } catch {
                    let error = NSError(domain: "failed convert url",
                                        code: 0,
                                        userInfo: nil)
                    operation.onError(error)
                }
                
                return Disposables.create()
            }).asSingle()
        }
    }
}

class RepoService {
    
    enum Route {
        case basePath
        
        var path: String {
            let base = "https://api.github.com/repositories"
            
            switch self {
            case .basePath: return base
            }
        }
        
        enum Params {
            case since(Int?)
            
            var key: String {
                switch self {
                case .since: return "since"
                }
            }
            
            var value: Any? {
                switch self {
                case .since(let value): return value
                }
            }
        }
        
        static func parameters(_ params: [Params]?) -> [String: Any]? {
            guard let `params` = params else { return nil }
            var result: [String: Any] = [:]
            
            for param in params {
                result[param.key] = param.value
            }
            
            return result.isEmpty ? nil: result
        }
    }
}

extension PrimitiveSequence where Element == Data {
    // .generateArrayModel(type: MODEL_CLASS_NAME.self).subscribe ... TODO
    func generateArrayModel<T: Decodable>() -> Single<[T]> {
        return self.asObservable()
            .flatMap({ data -> Observable<[T]> in
                let array = try? JSONDecoder().decode([T].self, from: data)
                return Observable.just(array ?? [])
            })
            .asSingle()
    }
    
    func generateObjectModel<T: Decodable>() -> Single<T?> {
        return self.asObservable()
            .flatMap({ data -> Observable<T?> in
                let object = try? JSONDecoder().decode(T.self, from: data)
                return Observable.just(object ?? nil)
            })
            .asSingle()
    }
}

extension RepoService {
    
    static func loadRepository(params: [RepoService.Route.Params]?) -> Single<[Repository]> {
        return Network.shared.get(url: Route.basePath.path,
                                  params: Route.parameters(params))
            .generateArrayModel()
    }
}
