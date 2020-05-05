import SpriteKit
import GameplayKit

class TalkMode: SKScene, ButtonDelegate {
    let storyCharacter = "Jeb" // Make sure this is not the same as in Storybook!
    var sceneScript: Dialogue!
    
    var responseControl: ResponseControl!
    var progressButton: SimpleButton!
    var words:SKLabelNode!
    var charPortraitLeft: CharacterPortrait!
    var charPortraitRight: CharacterPortrait!
    
    // TODO: Find out where to set these
    var currentLine = 0
    var nextLine = 0
    
    let hideResponseControls: SKAction = SKAction.moveTo( y: -100, duration: 0.3 )
    let showResponseControls: SKAction = SKAction.moveTo( y: 84, duration: 0.3 )
    
    let hideProgressButton: SKAction = SKAction.moveTo( x: 350, duration: 0.3 )
    let showProgressButton: SKAction = SKAction.moveTo( x: 282, duration: 0.3 )
    
    required init?( coder aDecoder: NSCoder ) {
        fatalError( "NSCoder not supported" )
    }
    
    override init( size: CGSize ) {
        super.init( size: size )
        
        self.backgroundColor = UIColor.white
        
        MultiPlayerController.comm.setTalkModeDelegate( self )
        loadSceneJSON( "storyData" )
    }
    
    func initScene() { // CAUTION: MOST OF THIS DIFFERS BETWEEN COMPANION AND STORYBOOK, DO NOT COPY/PASTE
        print( "Loaded dialogue: " + sceneScript.description )
        
        currentLine = sceneScript.icebreaker
        nextLine = sceneScript.firstResponse
        
        charPortraitLeft = CharacterPortrait( getCharacterNameFromLineReference( isIcebreaker() ? currentLine : nextLine ) )
        charPortraitLeft.zRotation = .pi * 0.5
        charPortraitLeft.position = CGPoint( x: 0, y: 110 )
        addChild( charPortraitLeft )
        
        charPortraitRight = CharacterPortrait( getCharacterNameFromLineReference( isIcebreaker() ? nextLine : currentLine ) )
        charPortraitRight.zRotation = .pi * 0.5
        charPortraitRight.position = CGPoint( x: 0, y: 110 + charPortraitLeft.size.width )
        addChild( charPortraitRight )
        
        responseControl = ResponseControl()
        responseControl.position = CGPoint( x: 90, y: -100 )
        responseControl.setCharacter( charPortraitLeft )
        addChild( responseControl )
        
        progressButton = SimpleButton( "progress", delegate: self )
        progressButton.position = CGPoint( x: 360, y: 530 )
        progressButton.zRotation = .pi * 0.5
        progressButton.enable()
        addChild( progressButton )
        
        words = SKLabelNode( text: "Loading conversation" )
        words.position = CGPoint( x: 20, y: 20 )
        words.zRotation = .pi * 0.5
        words.preferredMaxLayoutWidth = 520
        words.numberOfLines = 0
        words.verticalAlignmentMode = .top
        words.horizontalAlignmentMode = .left
        words.lineBreakMode = .byWordWrapping
        words.fontName = "MiloSerifOT"
        words.fontSize = 20
        
        words.fontColor = UIColor.black
        words.alpha = 0
        addChild( words )
        
        if( isIcebreaker() ) {
            startReadingTurn()
        } else {
            startListeningTurn( nextLine )
        }
    }
    

    // vvv------ CODE SHARED BETWEEN STORYBOOK AND COMPANION. SAFE COPY/PASTE ZONE BEGINS HERE
    
    ///// TURN TAKING LOOP
    
    // Start reading turn
    func startReadingTurn() {
        // Show progress button
        progressButton.run( showProgressButton ){
            self.progressButton.enable()
        }
        
        // Hide and disable response controls
        responseControl.disable()
        responseControl.run( hideResponseControls )
        
        // Populate text field
        if ( currentLine > 0 ) {
            words.text = getWords( getLine( currentLine ), responseControl.currentResponseType )
            words.alpha = 1
        } else {
            endScene()
        }
    }
    
    // Reader presses progress button.
    func endReadingTurn() {
        // Hide text
        words.alpha = 0
        
        // Tell server the reading has ended
        MultiPlayerController.comm.talkModeEndReading()
        
        // Hide and disable progress button
        progressButton.disable()
        progressButton.run( hideProgressButton )
    }
    
    func endScene() {
        print( "Time to change the scene somewhere around here." )
    }
    
    // Button delegate function
    func buttonPressed( btnID: String ) {
        switch btnID {
        case "progress" :
            endReadingTurn()
            break
        default :
            break
        }
    }
    
    func updateResponseButtons() { // updates response buttons to nextLine responses
        if( nextLine > 0 ) {
            let line:Line = sceneScript.lines.filter { $0.id == nextLine }[0]
            for i in 0 ... 2 {
                responseControl.armButtons( btnIndex: i, responseType: line.responses[i].type, lineReference: line.responses[i].lineReference )
            }
            responseControl.setSelected( "neutral" )
        } else {
            print( "...aaand SCENE! It’s a wrap." )
        }
    }
    
    // Check if this device is the conversation “icebreaker” or not
    func isIcebreaker() -> Bool {
        return getCharacterNameFromLineReference( sceneScript.icebreaker ) == self.storyCharacter ? true : false
    }
    
    func getLine(_ lineRef: Int ) -> Line {
        return sceneScript.lines.filter { $0.id == lineRef }[0]
    }
    
    func getWords(_ line:Line, _ rspType: String ) -> String {
        let response:Response = line.responses.filter { $0.type == rspType }[0]
        return response.words
    }
    
    // Check what character has a given line (by lineRef)
    func getCharacterNameFromLineReference(_ lineReference:Int ) -> String {
        let line:Line = sceneScript.lines.filter { $0.id == lineReference }[0]
        return line.character
    }
    
    // Load and parse JSON (based on DialogueStructure class)
    func loadSceneJSON(_ fileName: String ) {
        if let path = Bundle.main.path( forResource: fileName, ofType: "json" ) {
            do {
                let dialogueData = try Data( contentsOf: URL( fileURLWithPath: path ), options: .mappedIfSafe )
                sceneScript = try! JSONDecoder().decode( Dialogue.self, from: dialogueData )
            } catch {
                //
            }
        }
        
        initScene()
    }
    
    override func update(_ currentTime: TimeInterval ) {
        // Called before each frame is rendered
    }
}

extension TalkMode: TalkModeMPDelegate {
    
    func getLineReference() {
        // Send nextLineReference to next listener
        MultiPlayerController.comm.sendNextLineReference( responseControl.nextLineReference );
        currentLine = nextLine
        startReadingTurn()
    }
    
    func startListeningTurn( _ lineRef: Int ) { // Called from MultiPlayerController
        nextLine = lineRef
        
        // Show and enable response controls
        responseControl.run( showResponseControls ){
            self.updateResponseButtons()
            self.responseControl.enable()
        }
    }
    
    // Changes (and synchronizes) character portraits
    func setResponse(_ responseType: String ) { // DELEGATE FUNCTION
        charPortraitRight.setResponse( responseType )
    }
    
}
