import SpriteKit

class CharacterPortrait: SKSpriteNode {
    
    init(_ charName: String ) {
        let charTexture: SKTexture = SKTexture( imageNamed: "char-" + charName + "-neutral" )
        super.init( texture: charTexture, color: UIColor.black, size: charTexture.size() )
        
        self.name = charName
        self.isUserInteractionEnabled = false
        self.anchorPoint = CGPoint( x: 0, y: 1 )
    }
    
    func setResponse(_ responseType:String ) {
        self.texture = SKTexture( imageNamed: "char-" + self.name! + "-" + responseType )
    }
    
    required init( coder aDecoder: NSCoder ) {
        fatalError( "init(coder:) has not been implemented" )
    }
}
