import SpriteKit

class TripletSelectorDraggable: SKSpriteNode {
    
    var btnID:String = "tsDraggable"
    var down : SKSpriteNode!
    var tripletPosition:TripletPosition = .unknown
    
    init( btnImageNamed: String ) {
        let bgTexture: SKTexture = SKTexture( imageNamed: "Draggable-" + btnImageNamed )
        down = SKSpriteNode( imageNamed: "Draggable-" + btnImageNamed + "-Down" )
        
        super.init( texture: bgTexture, color: UIColor.black, size: bgTexture.size() )
        
        self.btnID = btnImageNamed
        
        self.anchorPoint = CGPoint( x: 0.5, y: 0.5 )
        down.anchorPoint = CGPoint( x: 0.5, y: 0.5 )
        down.alpha = 0;
        addChild( down )
        
        self.isUserInteractionEnabled = false
    }
    
    func setDownState () {
        down.removeAllActions()
        down.run( SKAction.fadeAlpha( to: 1, duration: 0.12 ) )
    }
    
    func setUpState () {
        down.removeAllActions()
        down.run( SKAction.fadeAlpha( to: 0, duration: 0.12 ) )
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
