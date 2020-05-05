import Foundation

class StoryHandler {
    var multiPlayerID:String
    var currentPage:Int
    var roomCode:String
    var flags:Dictionary<String, String>
    
    class var sharedInstance:StoryHandler {
        struct Singleton {
            static let instance = StoryHandler()
        }
        
        return Singleton.instance
    }
    
    init() {
        multiPlayerID = "declareCompanion"
        currentPage = 0
        roomCode = "0000"
        flags = [String:String]()
    }
}
