import SpriteKit

protocol ResponseButtonDelegate {
    func responseButtonPressed(_ btn: ResponseButton )
}

class ResponseButton: SKSpriteNode {
    
    var dg : ResponseButtonDelegate!
    var highlightKeyPress: SKAction!
    var lineReference:Int = 0
    var responseType = ""
    
    init(_ btnID:String, rspType: String, delegate: ResponseButtonDelegate ) {
        let upTexture: SKTexture = SKTexture( imageNamed: "rsp-" + rspType )
        super.init( texture: upTexture, color: UIColor.black, size: upTexture.size() )
        
        self.dg = delegate;
        self.name = btnID
        self.isUserInteractionEnabled = false
        self.anchorPoint = CGPoint( x: 0.5, y: 0.5 )
    }
    
    func select() {
        self.texture = SKTexture( imageNamed: "rsp-" + self.responseType + "-selected" )
        disable()
    }
    
    func deselect() {
        self.texture = SKTexture( imageNamed: "rsp-" + self.responseType )
        enable()
    }
    
    func setResponse(_ rspType: String, lineRef: Int ) {
        self.responseType = rspType
        self.lineReference = lineRef
        self.texture = SKTexture( imageNamed: "rsp-" + rspType )
    }
    
    func enable() {
        self.isUserInteractionEnabled = true
    }
    
    func disable() {
        self.isUserInteractionEnabled = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if( self.isUserInteractionEnabled ) {
            dg.responseButtonPressed( self )
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
