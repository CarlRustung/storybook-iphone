import SpriteKit

class HotspotButton: SKSpriteNode {
    
    var dg : ButtonDelegate!
    var pageNo:Float
    var setFlag:Flag!
    
    init(_ imgName:String, delegate: ButtonDelegate ) {
        let upTexture: SKTexture = SKTexture( imageNamed: imgName )
        
        dg = delegate;
        self.pageNo = 0;
        
        super.init( texture: upTexture, color: UIColor.black, size: upTexture.size() )
        
        self.isUserInteractionEnabled = false
        self.name = imgName
        
        self.anchorPoint = CGPoint( x: 0.5, y: 0.5 )
    }
    
    func enable( toPage:Float, flag: Flag ) {
        self.pageNo = toPage
        self.isUserInteractionEnabled = true
        self.setFlag = flag
    }
    
    func disable() {
        self.isUserInteractionEnabled = false
    }
    
    override func touchesBegan( _ touches: Set<UITouch>, with event: UIEvent? ) {
        self.disable()
        dg.buttonPressed( btnID: self.name! )
        
        if let flag = setFlag {
            StoryHandler.sharedInstance.flags[flag.key] = flag.value
        }
    }
    
    required init( coder aDecoder: NSCoder ) {
        fatalError( "init(coder:) has not been implemented" )
    }
}
