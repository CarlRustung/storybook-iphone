import SpriteKit

protocol KeyDelegate {
    func receiveKeyPress( keyID: String )
}

class Key: SKSpriteNode {
    
    var down : SKSpriteNode!
    var keyPad : KeyDelegate!
    var highlightKeyPress: SKAction!
    
    init(_ keyID:String, delegate: KeyDelegate ) {
        let upTexture: SKTexture = SKTexture( imageNamed: "btn-" + keyID )
        down = SKSpriteNode( imageNamed: "btn-" + keyID + "-down" )
        
        keyPad = delegate;
        
        super.init( texture: upTexture, color: UIColor.black, size: upTexture.size() )
        
        self.name = keyID
        
        highlightKeyPress = SKAction.fadeAlpha( to: 0, duration: 0.2 )
        
        self.anchorPoint = CGPoint( x: 0, y: 0 )
        down.anchorPoint = CGPoint( x: 0, y: 0 )
        down.alpha = 0;
        addChild( down )
    }
    
    func enable() {
        self.isUserInteractionEnabled = true
    }
    
    func disable() {
        self.isUserInteractionEnabled = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        keyPad.receiveKeyPress( keyID: self.name! )
        down.removeAllActions()
        down.alpha = 1
        down.run( highlightKeyPress )
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
