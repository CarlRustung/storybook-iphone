import SpriteKit

protocol ButtonDelegate {
    func buttonPressed( btnID: String )
}

class SimpleButton: SKSpriteNode {
    
    var down : SKSpriteNode!
    var dg : ButtonDelegate!
    var highlightKeyPress: SKAction!
    
    init(_ btnID:String, delegate: ButtonDelegate ) {
        let upTexture: SKTexture = SKTexture( imageNamed: "btn-" + btnID )
        down = SKSpriteNode( imageNamed: "btn-" + btnID + "-down" )
        
        dg = delegate;
        
        super.init( texture: upTexture, color: UIColor.black, size: upTexture.size() )
        
        self.name = btnID
        
        highlightKeyPress = SKAction.fadeAlpha( to: 0, duration: 0.2 )
        
        self.anchorPoint = CGPoint( x: 0.5, y: 0.5 )
        down.anchorPoint = CGPoint( x: 0.5, y: 0.5 )
        down.alpha = 0;
        addChild( down )
    }
    
    func enable() {
        self.isUserInteractionEnabled = true
        self.texture = SKTexture( imageNamed: "btn-" + self.name! )
    }
    
    func disable() {
        self.isUserInteractionEnabled = false
        self.texture = SKTexture( imageNamed: "btn-" + self.name! + "-disabled" )
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dg.buttonPressed( btnID: self.name! )
        down.removeAllActions()
        down.alpha = 1
        down.run( highlightKeyPress )
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
