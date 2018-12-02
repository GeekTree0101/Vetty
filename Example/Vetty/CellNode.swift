import Foundation
import AsyncDisplayKit
import RxSwift
import RxCocoa

import Vetty

class CellNode: ASCellNode {
    
    typealias Node = CellNode
    
    struct Attribute {
        
        static let profileSize: CGSize = CGSize(width: 50.0, height: 50.0)
        static let placeHolderColor: UIColor = UIColor.gray.withAlphaComponent(0.2)
    }
    
    // nodes
    lazy var userProfileNode = { () -> ASNetworkImageNode in
        
        let node = ASNetworkImageNode()
        node.style.preferredSize = Attribute.profileSize
        node.cornerRadius = 25.0
        node.clipsToBounds = true
        node.placeholderColor = Attribute.placeHolderColor
        node.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        node.borderWidth = 0.5
        return node
    }()
    
    lazy var usernameNode = { () -> ASTextNode in
        
        let node = ASTextNode()
        node.maximumNumberOfLines = 1
        node.placeholderColor = Attribute.placeHolderColor
        return node
    }()
    
    lazy var descriptionNode = { () -> ASTextNode in
        
        let node = ASTextNode()
        node.placeholderColor = Attribute.placeHolderColor
        node.maximumNumberOfLines = 2
        node.truncationAttributedText =
            NSAttributedString(string: " ...More",
                               attributes: Node.moreSeeAttributes)
        node.isUserInteractionEnabled = true
        return node
    }()
    
    let disposeBag = DisposeBag()
    let userViewModel: UserViewModel
    let repoViewModel: RepoViewModel
    
    init(repoId: VettyIdentifier) {
        let repoObservable = Vetty.rx.model(type: Repository.self, uniqueKey: repoId)
        
        let userObservable = repoObservable
            .filterNil()
            .map { $0.user?.uniqueKey }
            .filterNil()
            .take(1)
            .flatMap { Vetty.rx.model(type: User.self, uniqueKey: $0) }
        
        self.repoViewModel = .init(repoObservable)
        self.userViewModel = .init(userObservable)
        
        super.init()
        self.selectionStyle = .none
        self.automaticallyManagesSubnodes = true
        
        // TODO: Migration RxCocoa-Texture
        
        repoViewModel.desc
            .subscribe(onNext: { [weak self] desc in
                self?.descriptionNode.attributedText =
                    NSAttributedString(string: desc ?? "", attributes: Node.descAttributes)
                self?.setNeedsLayout()
            })
            .disposed(by: disposeBag)
        
        userViewModel.profileURL
            .subscribe(onNext: { [weak self] url in
                self?.userProfileNode.setURL(url, resetToDefault: true)
            })
            .disposed(by: disposeBag)
        
        userViewModel.username
            .subscribe(onNext: { [weak self] username in
                self?.usernameNode.attributedText =
                    NSAttributedString(string: username ?? "", attributes: Node.usernameAttributes)
                self?.setNeedsLayout()
            })
            .disposed(by: disposeBag)
        
        
        self.userProfileNode.addTarget(self,
                                       action: #selector(didTapProfile),
                                       forControlEvents: .touchUpInside)
        
        self.descriptionNode.addTarget(self,
                                       action: #selector(didTapDesc),
                                       forControlEvents: .touchUpInside)
    }
    
    @objc func didTapProfile() {
        
        self.userViewModel.didTapProfile.accept(())
    }
    
    @objc func didTapDesc() {
        
        self.repoViewModel.didTapDesc.accept(())
    }
}

extension CellNode {
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let contentLayout = contentLayoutSpec()
        contentLayout.style.flexShrink = 1.0
        contentLayout.style.flexGrow = 1.0
        
        userProfileNode.style.flexShrink = 1.0
        userProfileNode.style.flexGrow = 0.0
        
        let stackLayout = ASStackLayoutSpec(direction: .horizontal,
                                            spacing: 10.0,
                                            justifyContent: .start,
                                            alignItems: .center,
                                            children: [userProfileNode,
                                                       contentLayout])
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10.0,
                                                      left: 10.0,
                                                      bottom: 10.0,
                                                      right: 10.0),
                                 child: stackLayout)
    }
    
    private func contentLayoutSpec() -> ASLayoutSpec {
        
        let elements = [self.usernameNode,
                        self.descriptionNode].filter { $0.attributedText?.length ?? 0 > 0 }
        return ASStackLayoutSpec(direction: .vertical,
                                 spacing: 5.0,
                                 justifyContent: .start,
                                 alignItems: .stretch,
                                 children: elements)
    }
}

extension CellNode {
    
    static var usernameAttributes: [NSAttributedString.Key: Any] {
        
        return [NSAttributedString.Key.foregroundColor: UIColor.black,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20.0)]
    }
    
    static var descAttributes: [NSAttributedString.Key: Any] {
        
        return [NSAttributedString.Key.foregroundColor: UIColor.darkGray,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15.0)]
    }
    
    static var moreSeeAttributes: [NSAttributedString.Key: Any] {
        
        return [NSAttributedString.Key.foregroundColor: UIColor.darkGray,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15.0, weight: .medium)]
    }
}
