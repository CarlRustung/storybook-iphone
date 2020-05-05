import SpriteKit
import GameplayKit

class DeviceConnection: SKScene, MultiPlayerDelegate, KeyPadDelegate, ButtonDelegate {
    
    var bgImage, spinner: SKSpriteNode!
    var keyPad: KeyPad!
    var retryBtn: SimpleButton!
    
    required init?( coder aDecoder: NSCoder ) {
        fatalError( "NSCoder not supported" )
    }
    
    override init( size: CGSize ) {
        super.init( size: size )
        
        self.backgroundColor = UIColor.black
        
        bgImage = SKSpriteNode( imageNamed: "iPhone_connecting" )
        bgImage.position = CGPoint( x: 0, y: 0 )
        bgImage.anchorPoint = CGPoint( x: 0, y: 0 )
        bgImage.isUserInteractionEnabled = false
        bgImage.name = "background"
        addChild( bgImage )
        
        spinner = SKSpriteNode( imageNamed: "spinner_small" )
        spinner.position = CGPoint( x: 192, y: 345 )
        spinner.anchorPoint = CGPoint( x: 0.5, y: 0.5 )
        spinner.isUserInteractionEnabled = false
        spinner.zRotation = 0
        addChild( spinner )
        
        keyPad = KeyPad()
        keyPad.setDelegate( self )
        keyPad.alpha = 0
        addChild( keyPad )
        
        retryBtn = SimpleButton( "retry", delegate: self )
        retryBtn.alpha = 0
        retryBtn.position = CGPoint( x: 160, y: 45 )
        addChild( retryBtn )
        
        MultiPlayerController.comm.setDelegate( self )
        MultiPlayerController.comm.connect()
    }
    
    override func update(_ currentTime: TimeInterval) {
        spinner.zRotation -= 0.05
    }
    
    func receiveCode(code: String) {
        StoryHandler.sharedInstance.roomCode = code
        print( "Connecting with companion code #" + code )
        spinner.position = CGPoint( x: 214, y: 190 )
        spinner.alpha = 1
        keyPad.hideKeys()
        bgImage.texture = SKTexture(imageNamed: "iPhone_check-code")
        MultiPlayerController.comm.sendCompanionCode( code )
    }
    
    func buttonPressed(btnID: String) {
        switch btnID {
        case "retry":
            bgImage.texture = SKTexture( imageNamed: "iPhone_connected" )
            keyPad.reset()
            retryBtn.disable()
            retryBtn.alpha = 0
        default:
            break
        }
    }
    
    func receiveMPData(_ data: MPData) {
        switch data.event {
        case "requestCode"?:
            bgImage.texture = SKTexture( imageNamed: "iPhone_connected" )
            spinner.alpha = 0
            keyPad.alpha = 1
            break;
        case "dyadConnected"?:
            bgImage.texture = SKTexture( imageNamed: "iPhone_complete" )
            spinner.alpha = 0
            keyPad.run( SKAction.fadeOut( withDuration: 1 ) )
            bgImage.run( SKAction.fadeOut( withDuration: 1 ) ) {
                let nextScene = ReadMode( size: self.size )
                nextScene.scaleMode = .aspectFit
                self.view?.presentScene( nextScene )
            }
            break
        case "companionDenied"?:
            bgImage.texture = SKTexture( imageNamed: "iPhone_error" )
            keyPad.displayError()
            spinner.alpha = 0
            retryBtn.alpha = 1
            retryBtn.enable()
            break
        default:
            break
        }
    }
}
