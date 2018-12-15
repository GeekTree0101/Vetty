import Foundation
import Vetty

class Repository: VettyProtocol {
    
    var uniqueKey: VettyIdentifier {
        return id
    }
    
    var id: Int = -1
    var user: User?
    var repositoryName: String?
    var desc: String?
    var isPrivate: Bool = false
    var isForked: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case user = "owner"
        case repositoryName = "full_name"
        case desc = "description"
        case isPrivate = "private"
        case isForked = "fork"
    }
    
    func commitSubModelIfNeeds() {
        
        Vetty.shared.commitIfNeeds(user)
    }
}

class User: VettyProtocol {
    
    var uniqueKey: VettyIdentifier {
        return username
    }
    
    var username: String = ""
    var profileURL: URL?
    
    enum CodingKeys: String, CodingKey {
        case username = "login"
        case profileURL = "avatar_url"
    }
    
    func commitSubModelIfNeeds() {
        // nothing
    }
}
