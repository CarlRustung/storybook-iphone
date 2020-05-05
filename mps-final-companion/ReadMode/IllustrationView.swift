import SpriteKit

class IllustrationView: SKSpriteNode, ButtonDelegate {
    
    var hotspots:Array<HotspotButton>
    var charSelect:CharacterSelector!
    var tripletSelector:TripletSelector!
    
    init( _ view:SKView ) {
        
        let tex: SKTexture = SKTexture( imageNamed: "read-mode-placeholder" )
        self.hotspots = Array<HotspotButton>()
        
        super.init( texture: tex, color: UIColor.black, size: tex.size() )
        
        charSelect = CharacterSelector( view )
        tripletSelector = TripletSelector()
        
        self.isUserInteractionEnabled = false
        self.anchorPoint = CGPoint( x: 0, y: 0 )
    }
    
    func loadPage( _ page:ReadModePage ) {
        
        switch page.ixType {
        
        case ReadModeInteractionType.paragraph.rawValue:
            if let bgImageNamed:String = page.illustration {
                self.texture = SKTexture( imageNamed: bgImageNamed )
                removeAllChildren()
            }
            
            break
        
        // Hotspot page
        case ReadModeInteractionType.hotspots.rawValue:
            
            if let bgImageNamed:String = page.illustration {
                self.texture = SKTexture( imageNamed: bgImageNamed )
            }
            
            removeAllChildren()
            
            if let hotspots:Array<HotspotChoice> = page.choices {
                self.loadHotspots( hotspots )
            }
            
            break
         
        // Character select page
        case ReadModeInteractionType.charSelect.rawValue:
            removeAllChildren()
            
            if let cData = page.characterData {
                if let cSel = charSelect {
                    cSel.loadCharacter( cData )
                    addChild( cSel )
                }
            }
            
            break
         
        // Character description page
        case ReadModeInteractionType.charDesc.rawValue:
            if let illName:String = page.illustration {
                self.texture = SKTexture( imageNamed: illName )
                removeAllChildren()
            }
            
            break
        
        // Triplet selector page
        case ReadModeInteractionType.tripletSelector.rawValue:
            removeAllChildren()
            tripletSelector.loadPage( page )
            addChild( tripletSelector )
            
            break
        
        // Flag redirect page
        case ReadModeInteractionType.flagRedirect.rawValue:
            //print( "Page type: Flag redirect" )
            break
          
        // End page
        case ReadModeInteractionType.endPage.rawValue:
            
            if let illName:String = page.illustration {
                self.texture = SKTexture( imageNamed: illName )
                removeAllChildren()
            }
            
            break
            
        // End scene
        case ReadModeInteractionType.endScene.rawValue:
            
            if let illName:String = page.illustration {
                self.texture = SKTexture( imageNamed: illName )
                removeAllChildren()
            }
            
            break
        
        // Default (probably an error)
        default:
            print( "Read mode interaction type not recognized (" + page.ixType + ")" )
            break
        }
        
        /* TODO: implement tripletselector and character select
        if let interaction: String = page.interaction {
            //print( interaction )
            self.texture = SKTexture( imageNamed: interaction )
        }
        */
    }
    
    func loadHotspots( _ choices:Array<HotspotChoice> ) {
        for spot in hotspots {
            spot.disable()
        }
        
        clearHotSpots()
        
        for c in choices {
            let btn:HotspotButton = HotspotButton( c.hotspot.illustration, delegate: self )
            hotspots.append( btn )
            
            btn.position = CGPoint( x: CGFloat( c.hotspot.xPos ) * ( self.size.width * 0.01 ), y: CGFloat( c.hotspot.yPos ) * ( self.size.height * 0.01 ) )
            self.hotspots.append( btn )
            addChild( btn )
            
            btn.enable( toPage: c.toPage, flag: c.setFlag );
        }
    }
    
    func clearHotSpots () {
        hotspots.removeAll()
        removeAllChildren()
    }
    
    func buttonPressed( btnID: String ) {
        print( "clicked: " + btnID )
        var pageNo:Float = 0
        
        for spot in hotspots {
            if ( spot.name == btnID ) {
                pageNo = spot.pageNo
                MultiPlayerController.comm.sendReadModePageNo( pageNo )
                break
            }
        }
    }
    
    required init?( coder aDecoder: NSCoder ) {
        fatalError( "init(coder:) has not been implemented" )
    }
}

