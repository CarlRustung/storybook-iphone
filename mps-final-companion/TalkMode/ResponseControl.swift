import SpriteKit

class ResponseControl: SKNode, ResponseButtonDelegate {
    
    var buttons:Array<ResponseButton>!
    var characterPortrait: CharacterPortrait!
    var nextLineReference:Int = 0
    var currentResponseType:String = "neutral"
    
    override init(){
        super.init()
        
        buttons = Array<ResponseButton>()
        
        for i in 0 ... 2 {
            let btn = ResponseButton( "btn" + String(i), rspType: "ph", delegate: self )
            btn.position = CGPoint( x: i * 72, y: 0 )
            btn.zRotation = .pi * 0.5
            buttons.append( btn )
            addChild( btn )
        }
    }
    
    // vvv------ CODE SHARED BETWEEN STORYBOOK AND COMPANION. SAFE COPY/PASTE ZONE BEGINS HERE
    
    func setCharacter(_ charPortrait:CharacterPortrait ) {
        self.characterPortrait = charPortrait
    }
    
    func armButtons( btnIndex: Int, responseType: String, lineReference: Int ) {
        buttons[btnIndex].setResponse( responseType, lineRef: lineReference )
    }
    
    func setSelected(_ rspType: String ) { // TODO: Neutral response always in the middle --- but should keep current “mood”... Hmm.
        for button in buttons {
            if ( rspType == button.responseType ) {
                button.select()
            } else {
                button.deselect()
            }
        }
    }
    
    func enable() {
        for btn in buttons {
            btn.enable()
        }
    }
    
    func disable() {
        for btn in buttons {
            btn.disable()
        }
    }
    
    func responseButtonPressed( _ btn: ResponseButton ) {
        characterPortrait!.setResponse( btn.responseType )
        MultiPlayerController.comm.talkModeSendResponse( responseType: btn.responseType )
        self.nextLineReference = btn.lineReference
        self.currentResponseType = btn.responseType
        
        for button in buttons {
            if btn === button {
                button.select()
            } else {
                button.deselect()
            }
        }
    }
    
    required init?( coder aDecoder: NSCoder ) {
        fatalError( "init(coder:) has not been implemented" )
    }
}

