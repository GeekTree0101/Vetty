import UIKit
import AsyncDisplayKit
import RxSwift
import RxCocoa
import RxOptional

import Vetty

extension Reactive where Base: ViewController {
    
    var reload: Binder<Void> {
        
        return Binder(base.node) { node, _ in
            
            node.reloadData()
        }
    }
}

class ViewController: ASViewController<ASTableNode> {
    
    let repoIdRelay = BehaviorRelay<[VettyIdentifier]>(value: [])
    let disposeBag = DisposeBag()

    init() {
        super.init(node: .init())
        self.node.dataSource = self
        self.node.delegate = self
        self.node.backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.node.view.separatorStyle = .none
        self.loadRepository()
    }

    func loadRepository() {
        
        RepoService.loadRepository(params: nil)
            .asObservable()
            .map({ $0.map({ $0 as VettyProtocol }) })
            .commits(ignoreSubModel: false)
            .bind(to: repoIdRelay)
            .disposed(by: disposeBag)
        
        // i don't waana use pagination git repo and reload only one
        repoIdRelay.skip(1)
            .map({ _ in return })
            .take(1)
            .bind(to: self.rx.reload)
            .disposed(by: disposeBag)
    }
}

extension ViewController: ASTableDataSource, ASTableDelegate {
    
    func tableNode(_ tableNode: ASTableNode,
                   numberOfRowsInSection section: Int) -> Int {
        return repoIdRelay.value.count
    }
    
    func tableNode(_ tableNode: ASTableNode,
                   nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        return {
            
            let identifiers = self.repoIdRelay.value
            guard indexPath.row < identifiers.count else { return ASCellNode() }
            return CellNode.init(repoId: identifiers[indexPath.row])
        }
    }
    
    // editable cell
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            self.node.performBatchUpdates({
                var items = self.repoIdRelay.value
                items.remove(at: indexPath.row)
                self.repoIdRelay.accept(items)
                self.node.deleteRows(at: [indexPath], with: .fade)
            }, completion: nil)
        }
    }
}
