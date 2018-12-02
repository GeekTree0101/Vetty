import Foundation
import RxSwift
import RxCocoa

import Vetty

class RepoViewModel {
    
    // output
    var desc: Observable<String?>
    
    // input
    let didTapDesc = PublishRelay<Void>()
    
    let disposeBag = DisposeBag()
    
    init(_ observable: Observable<Repository?>) {
        
        desc = observable.map { $0?.desc }
        
        didTapDesc.map { _ in return "Did Tap Description" }
            .mutate(with: observable,
                    ignoreSubModel: true,
                    { repo, newDesc -> Repository? in
                        repo?.desc = newDesc
                        return repo
            })
            .disposed(by: disposeBag)
    }
}

class UserViewModel {
    
    // output
    var profileURL: Observable<URL?>
    var username: Observable<String?>
    
    // input
    let didTapProfile = PublishRelay<Void>()
    
    let disposeBag = DisposeBag()
    
    init(_ observable: Observable<User?>) {
        
        profileURL = observable.map({ $0?.profileURL })
        username = observable.map({ $0?.username })
        
        didTapProfile
            .map { _ in return "DID TAP Profile" }
            .mutate(with: observable,
                    ignoreSubModel: true,
                    { user, newName -> User? in
                        user?.profileURL = URL(string: "https://avatars1.githubusercontent.com/u/19504988?s=460&v=4")
                        return user
            })
            .disposed(by: disposeBag)
    }
}
