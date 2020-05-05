import SpriteKit

class VariationButton: SKSpriteNode {
    
    var selected: SKSpriteNode!
    var dg : ButtonDelegate!
    
    init( _ btnImageNamed: String, delegate: ButtonDelegate ) {
        let bgTexture: SKTexture = SKTexture( imageNamed: "Select-" + btnImageNamed )
        selected = SKSpriteNode( imageNamed: "Select-" + btnImageNamed + "-Active" )
        
        dg = delegate;
        
        super.init( texture: bgTexture, color: UIColor.black, size: bgTexture.size() )
        
        self.anchorPoint = CGPoint( x: 0.5, y: 0.5 )
        selected.anchorPoint = CGPoint( x: 0.5, y: 0.5 )
        selected.alpha = 0;
        addChild( selected )
        
        self.name = btnImageNamed
    }
    
    func select () {
        self.disable()
        selected.removeAllActions()
        selected.run( SKAction.fadeAlpha( to: 1, duration: 0.12 ) )
    }
    
    func deselect () {
        self.enable()
        selected.removeAllActions()
        selected.run( SKAction.fadeAlpha( to: 0, duration: 0.12 ) )
    }
    
    func enable() {
        self.isUserInteractionEnabled = true
    }
    
    func disable() {
        self.isUserInteractionEnabled = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dg.buttonPressed( btnID: self.name! )
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
