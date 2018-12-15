import Foundation
import RxSwift
import RxCocoa

import Vetty

class CellViewModel {
    
    // output
    var desc: Observable<String?>
    var profileURL: Observable<URL?>
    var username: Observable<String?>
    
    // input
    let didTapDesc = PublishRelay<Void>()
    let didTapProfile = PublishRelay<Void>()
    
    let disposeBag = DisposeBag()
    

    init(_ repoId: VettyIdentifier) {
        
        let repoObservable = Vetty.rx.model(type: Repository.self, uniqueKey: repoId)
        
        let userObservable = repoObservable
            .filterNil()
            .map { $0.user?.uniqueKey }
            .asModel(type: User.self)
        
        desc = repoObservable.map { $0?.desc }
        profileURL = userObservable.map({ $0?.profileURL })
        username = userObservable.map({ $0?.username })
        
        didTapDesc.map { _ in return "Did Tap Description" }
            .mutate(with: repoObservable,
                    ignoreSubModel: true,
                    { repo, newDesc -> Repository? in
                        repo?.desc = newDesc
                        return repo
            })
            .disposed(by: disposeBag)
        
        didTapProfile
            .map { _ in return "DID TAP Profile" }
            .mutate(with: userObservable,
                    ignoreSubModel: true,
                    { user, newName -> User? in
                        user?.profileURL = URL(string: "https://avatars1.githubusercontent.com/u/19504988?s=460&v=4")
                        return user
            })
            .disposed(by: disposeBag)
    }
}
