import SpriteKit

protocol KeyPadDelegate {
    func receiveCode( code: String )
}

class KeyPad: SKNode, KeyDelegate {
    var buttons:Array<Key>!
    var eraseButton:Key!
    var inputCode:String!
    var delegate:KeyPadDelegate!
    var numberDisplay: SKLabelNode!
    
    override init(){
        super.init()
        
        let xPos: Array<Int> = [ 205, 24, 115 ]
        let yPos: Int = 181
        var row: Int = -1
        
        inputCode = ""
        
        buttons = Array<Key>()
        
        for i in 0...9 {
            buttons.append( Key( String(i), delegate: self ) )
        }
        
        for i in 1...9 {
            if ( (i-1)%3 == 0 ) {
                row += 1
            }
            
            buttons[i].position = CGPoint( x: xPos[i%3], y: yPos - row * 54 )
            addChild( buttons[i] )
            buttons[i].enable()
        }
        
        row += 1
        
        buttons.append( Key( "0", delegate: self ) )
        buttons[10].position = CGPoint(x: xPos[2]-1, y: yPos - row * 54 )
        addChild( buttons[10] )
        buttons[10].enable()
        
        eraseButton = Key( "erase", delegate: self )
        eraseButton.position = CGPoint(x: xPos[1], y: yPos - row * 54 )
        addChild( eraseButton )
        eraseButton.enable()
        
        numberDisplay = SKLabelNode( text: "" )
        numberDisplay.fontName = "MiloSerifOT-Bold"
        numberDisplay.fontSize = 64
        numberDisplay.fontColor = UIColor(red: 68/255, green: 218/255, blue: 1, alpha: 1)
        numberDisplay.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        numberDisplay.position = CGPoint( x: 24, y: 260 )
        addChild( numberDisplay )
    }
    
    func setDelegate(_ delegate: KeyPadDelegate ) {
        self.delegate = delegate
    }
    
    func hideKeys() {
        for button in buttons {
            button.alpha = 0
            button.disable()
        }
        
        eraseButton.alpha = 0
        eraseButton.disable()
    }
    
    func reset() {
        for button in buttons {
            button.alpha = 1
            button.enable()
        }
        
        eraseButton.alpha = 1
        eraseButton.enable()
        
        numberDisplay.text = ""
        numberDisplay.fontColor = UIColor(red: 68/255, green: 218/255, blue: 1, alpha: 1)
    }
    
    func displayError() {
        numberDisplay.fontColor = UIColor(red: 1, green: 102/255, blue: 0, alpha: 1)
    }
    
    func receiveKeyPress(keyID: String) {
        let char:Character = keyID.first!
        
        if ( char == "e" ) {
            if ( inputCode.count > 0 ) {
                inputCode.removeLast()
            }
        } else {
            inputCode.append( char )
        }
        
        numberDisplay.text = inputCode
        
        if ( inputCode.count == 4 ) {
            delegate.receiveCode( code: inputCode )
            inputCode.removeLast(4)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
