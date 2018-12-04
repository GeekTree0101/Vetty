import Quick
import Nimble
import RxTest
import RxSwift
import RxCocoa
import RxBlocking
@testable import Vetty

class VettySpec: QuickSpec {
    
    func runRunLoop() {
        
        for _ in 0 ..< 10 {
            let currentRunLoop = CFRunLoopGetCurrent()
            DispatchQueue.main.async {
                CFRunLoopStop(currentRunLoop)
            }
            
            CFRunLoopWakeUp(currentRunLoop)
            CFRunLoopRun()
        }
    }
    
    override func spec() {
        
        context("Vetty Data Provider Unit Test") {
            
            var repositories: [Repository]!
            
            beforeEach {
                
                let bundle = Bundle(for: type(of: self))
                let url = bundle.url(forResource: "Repository", withExtension: "json")!
                let data = try! Data(contentsOf: url)
                
                repositories = try? JSONDecoder().decode([Repository].self, from: data)
                Vetty.shared.clear()
                Vetty.shared.commit(repositories, ignoreSubModel: false)
                self.runRunLoop()
            }
            
            it("should be success parse json to repositories") {
        
                expect(repositories.count).to(equal(100))
            }
            
            it("should be read target model") {

                let repo = Vetty.shared.read(type: Repository.self, uniqueKey: "\(repositories.first!.id)")
                expect(repo?.id).to(equal(1))
                expect(repo?.id).to(equal(repositories.first?.id))
            }
            
            it("should be success to commit") {
                
                let repo = Vetty.shared.read(type: Repository.self, uniqueKey: "\(repositories.first!.id)")
                expect(repo?.desc).to(equal("Vetty Description"))
                repo?.desc = "Updated Description Test"
                Vetty.shared.commit(repo!, ignoreSubModel: true)
                
                let updatedRepo = Vetty.shared.read(type: Repository.self, uniqueKey: "\(repositories.first!.id)")
                expect(updatedRepo?.desc).to(equal("Updated Description Test"))
            }
        }
        
        context("Vetty+Extension Unit Test") {
            
            var repositories: [Repository]!
            let disposeBag = DisposeBag()
            
            beforeEach {
                
                let bundle = Bundle(for: type(of: self))
                let url = bundle.url(forResource: "Repository", withExtension: "json")!
                let data = try! Data(contentsOf: url)
                
                repositories = try? JSONDecoder().decode([Repository].self, from: data)
                
                Vetty.shared.clear()
                self.runRunLoop()
            }
            
            it("should be commit") {
                
                let repositoryIdsObservable = Observable.just(repositories)
                    .commits()
                
                let expectedIds = repositories.map({ $0.map({ "\($0.id)" })})
                
                expect(try! repositoryIdsObservable.toBlocking().single().map({ $0.id }))
                    .to(equal(expectedIds))
                self.runRunLoop()
            }
            
            it("should be read target model") {
                Vetty.shared.commit(repositories, ignoreSubModel: true)
                self.runRunLoop()
                let repoObservable = Vetty.rx.model(type: Repository.self, uniqueKey: "1")
                expect(try! repoObservable.toBlocking().first()??.id).to(equal(repositories.first!.id))
            }
            
            it("should be mutate target model") {
                Vetty.shared.commit(repositories, ignoreSubModel: true)
                self.runRunLoop()
                
                expect(repositories.first!.id).to(equal(1))
                expect(repositories.first!.desc).to(equal("Vetty Description"))
                
                let repoObservable = Vetty.rx.model(type: Repository.self, uniqueKey: "1")
                
                Observable.just("Update Desc")
                    .mutate(with: repoObservable,
                            { repo, text -> Repository? in
                                repo?.desc = text
                                return repo
                    }).disposed(by: disposeBag)
                
                self.runRunLoop()
                expect(try! repoObservable.toBlocking().first()??.desc).to(equal("Update Desc"))
            }
        }
    }
}

