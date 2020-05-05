import SpriteKit
import SocketIO

protocol MultiPlayerDelegate {
    func receiveMPData(_ data: MPData )
}

protocol TalkModeMPDelegate {
    // Passing line references
    func getLineReference()
    func startListeningTurn(_ lineRef: Int )
    
    // Passing responses
    func setResponse(_ responseType: String )
}

protocol ReadModeMPDelegate {
    func setPage( _ pageNo: String )
    func turnPage()
}

struct MPData: Codable {
    let event: String?
    let message: String?
}

////// MULTIPLAYER CONTROLLER (SINGLETON)

final class MultiPlayerController {
    
    let appDeclaration:String = "declareCompanion"
    
    //v-v-v-- Copy paste safe zone
    
    static let comm = MultiPlayerController()
    let serverURL:URL = URL( string: "https://storybook.eu.ngrok.io/" )!
    
    var manager: SocketManager!
    var socket: SocketIOClient!
    
    var delegate:MultiPlayerDelegate!
    var talkModeDelegate:TalkModeMPDelegate!
    var readModeDelegate:ReadModeMPDelegate!
    
    private init() {
        manager = SocketManager( socketURL: serverURL, config: [ .log( false ), .compress ] )
        socket = manager.defaultSocket
        
        
        //// DEVICE CONNECTION
        
        socket.on( clientEvent: .connect ) {data, ack in
            print( "Connected to server." )
        }
        
        socket.on( "requestAppRole" ) { data, ack in
            self.socket.emit( self.appDeclaration )
        }
        
        socket.on( "dyadConnected" ) { data, ack in
            self.tellDelegate( event: "dyadConnected", message: "N/A" )
        }
        
        socket.on( "companionConnectionCode" ) { data, ack in
            if let code = data[0] as? String {
                StoryHandler.sharedInstance.roomCode = code
                self.tellDelegate( event: "connectionCode", message: code )
            }
        }
        
        socket.on( "requestCompanionCode" ) { data, ack in
            self.tellDelegate(event: "requestCode", message: "N/A")
        }
        
        socket.on( "companionDenied" ) { data, ack in
            self.tellDelegate( event: "companionDenied", message: "N/A" )
        }
        
        //// TALK MODE
        
        socket.on( "talkModeReadingHasEnded" ) { data, ack in
            self.talkModeDelegate.getLineReference()
        }
        
        
        socket.on( "talkModeStartListening" ) { data, ack in
            if let lineReference = data[0] as? Int {
                self.talkModeDelegate.startListeningTurn( lineReference )
            }
        }
        
        socket.on( "talkModeSetResponse" ) { data, ack in
            if let responseType = data[0] as? String {
                self.talkModeDelegate.setResponse( responseType )
            }
        }
        
        //// READ MODE
        socket.on( "readModeSetPage" ) { data, ack in
            if let pageNo = data[0] as? String {
                self.readModeDelegate.setPage( pageNo )
            }
        }
        
        socket.on( "readModeTurnPage" ) { data, ack in
            self.readModeDelegate.turnPage()
        }
    }
    
    func connect() {
        socket.connect()
    }
    
    func setDelegate(_ page: MultiPlayerDelegate ){
        delegate = page
    }
    
    func setTalkModeDelegate(_ page: TalkModeMPDelegate ){
        talkModeDelegate = page
    }
    
    func setReadModeDelegate(_ page: ReadModeMPDelegate ){
        readModeDelegate = page
    }
    
    func tellDelegate( event: String, message: String ) {
        let msg:MPData = MPData(event: event, message: message)
        self.delegate!.receiveMPData( msg )
    }
    
    //// COMPANION CONNECTION
    func sendCompanionCode(_ code: String ) {
        socket.emit( "connectCompanion", code );
    }
    
    //// READ MODE
    func sendReadModePageNo(_ pageNo:Float ) {
        socket.emit( "readModeSetPage", StoryHandler.sharedInstance.roomCode, String( pageNo ) );
    }
    
    func sendReadModePageTurn() {
        socket.emit( "readModePageTurn", StoryHandler.sharedInstance.roomCode );
    }
    
    //// TALK MODE
    func talkModeEndReading() {
        socket.emit( "talkModeEndReading", StoryHandler.sharedInstance.roomCode );
    }
    
    func sendNextLineReference(_ lineRef: Int ){
        socket.emit( "talkModeNextLineReference", StoryHandler.sharedInstance.roomCode, lineRef );
    }
    
    func talkModeSendResponse( responseType: String ) {
        socket.emit( "talkModeListenerResponse", StoryHandler.sharedInstance.roomCode, responseType );
    }
}
