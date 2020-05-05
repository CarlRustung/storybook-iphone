import SpriteKit

class CharacterSelector: SKSpriteNode {

    var skView:SKView!
    
    var swiper:SKSpriteNode!
    var swiperEnabled:Bool = false
    
    var okBtn:SimpleButton!
    var btnLeft:VariationButton!
    var btnRight:VariationButton!
    
    var toPage:Float = 0
    var charName:String!
    var charLooks:Array<String>!
    var lookFlagKey:String!
    var charInterest:String!
    var interestFlagKey:String!
    
    var currentLook:Int = 0
    
    init( _ view:SKView ) {
        let bgTexture: SKTexture = SKTexture( imageNamed: "read-mode-placeholder" )
        super.init( texture: bgTexture, color: UIColor.black, size: bgTexture.size() )
    
        skView = view
        
        self.anchorPoint = CGPoint( x: 0, y: 0 )
        
        swiper = SKSpriteNode( imageNamed: "read-mode-placeholder" )
        swiper.anchorPoint = CGPoint( x: 0, y: 0 )
        initSwipeGesture()
    }
    
    func loadCharacter( _ data: CharacterData ) {
        reset()
        
        addChild( swiper )
        
        toPage = data.toPage
        
        charName = data.name
        charLooks = data.look.values
        
        lookFlagKey = data.look.key
        interestFlagKey = data.interest.key
        
        self.texture = SKTexture( imageNamed: charName + "-BG" )
        
        btnLeft = VariationButton( data.interest.values[0], delegate: self )
        btnLeft.position = CGPoint( x: 60, y: 100 )
        btnLeft.enable()
        addChild( btnLeft )
        
        btnRight = VariationButton( data.interest.values[1], delegate: self )
        btnRight.position = CGPoint( x: self.size.width - 60, y: 100 )
        btnRight.enable()
        addChild( btnRight )
        
        okBtn = SimpleButton( "ok", delegate: self )
        okBtn.position = CGPoint( x: self.size.width * 0.5, y: 50 )
        okBtn.disable()
        addChild( okBtn )
        
        updateSwiper()
        swiperEnabled = true
    }
    
    func reset() {
        removeAllChildren()
        currentLook = 0
        charName = nil
        charInterest = nil
        
        if charLooks != nil {
            charLooks.removeAll()
        }
    }
    
    func initSwipeGesture() {
        if let view:SKView = skView {
            let swipeLeftRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeLeftDetected(swipe:)))
            swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirection.left
            view.addGestureRecognizer( swipeLeftRecognizer )
            
            let swipeRightRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeRightDetected(swipe:)))
            swipeRightRecognizer.direction = UISwipeGestureRecognizerDirection.right
            view.addGestureRecognizer( swipeRightRecognizer )
        }
    }
    
    @objc func swipeLeftDetected( swipe:UISwipeGestureRecognizer ) {
        if swiperEnabled {
            currentLook -= 1
            if currentLook == -1 {
                currentLook = charLooks.count - 1
            }
            
            updateSwiper()
        }
    }
    
    @objc func swipeRightDetected( swipe:UISwipeGestureRecognizer ) {
        if swiperEnabled {
            currentLook += 1
            if currentLook == charLooks.count {
                currentLook = 0
            }
            
            updateSwiper()
        }
    }
    
    func updateSwiper() {
        if( charInterest != nil ) {
            swiper.texture = SKTexture( imageNamed: charName + "-" + charLooks[currentLook] + "-" + charInterest )
        } else {
            swiper.texture = SKTexture( imageNamed: charName + "-" + charLooks[currentLook] )
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError( "init(coder:) has not been implemented" )
    }
}

extension CharacterSelector: ButtonDelegate {
    func buttonPressed( btnID: String ) {
        switch btnID {
        case btnLeft.name:
            btnLeft.select()
            btnRight.deselect()
            charInterest = btnID
            okBtn.enable()
            updateSwiper()
            break
            
        case btnRight.name:
            btnRight.select()
            btnLeft.deselect()
            charInterest = btnID
            updateSwiper()
            okBtn.enable()
            break
        
        case "ok":
            okBtn.disable()
            
            swiperEnabled = false
            
            MultiPlayerController.comm.shareFlag( key: lookFlagKey, value: charLooks[ currentLook ] )
            MultiPlayerController.comm.shareFlag( key: interestFlagKey, value: charInterest )
            MultiPlayerController.comm.sendReadModePageNo( toPage )
            
            break
        
        default:
            break
        }
    }
}
