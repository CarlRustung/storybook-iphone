//
//   TODO:
//   - Implement OK-button
//   - - Store flags
//


import SpriteKit

enum TripletPosition:Int {
    case unknown = -1
    case top = 2
    case middle = 1
    case bottom = 0
}

class TripletSelector: SKSpriteNode {
    
    var selectedNode: TripletSelectorDraggable!
    var targetNode: TripletSelectorDraggable!
    
    var areas:Array<CGFloat> = Array<CGFloat>()
    var emptyPosition:TripletPosition = .unknown
    
    var markers:Array<SKSpriteNode> = Array<SKSpriteNode>()
    var nodes:Array<TripletSelectorDraggable> = Array<TripletSelectorDraggable>()
    
    var toPage:Float = 0
    var flagKeys:Array<String>!
    
    var okBtn:SimpleButton!
    var nodeX:CGFloat = 0
    
    var isDragging:Bool
    
    init() {
        self.isDragging = false
        
        let bgTexture: SKTexture = SKTexture( imageNamed: "read-mode-placeholder" )
        super.init( texture: bgTexture, color: UIColor.black, size: bgTexture.size() )
        
        self.anchorPoint = CGPoint( x: 0, y: 0 )
        self.isUserInteractionEnabled = true
        self.name = "no-drag"
        
        let sH:CGFloat = self.size.height
        nodeX = self.size.width * 0.3
        
        areas = [ 0, sH/3, sH/3 * 2, sH ]
        
        okBtn = SimpleButton( "ok", delegate: self )
        okBtn.position = CGPoint( x: self.size.width - 60, y: 50 )
        okBtn.disable()
        addChild( okBtn )
    }
    
    func loadPage( _ page:ReadModePage ) {
        
        let sH:CGFloat = self.size.height
        
        if let tP:Float = page.toPage {
            self.toPage = tP
        }
        
        if let bg = page.illustration {
            self.texture = SKTexture( imageNamed: bg )
        }
        
        if let fKeys = page.setFlags {
            flagKeys = fKeys
        }
        
        if let m = page.movables {
            for i in 0 ... m.count - 1 {
                let yPos = ( CGFloat(i) * ( sH/3 ) ) + ( sH/6 )
                
                let mrk:SKSpriteNode = SKSpriteNode( imageNamed: "drag-marker" )
                let nd:TripletSelectorDraggable = TripletSelectorDraggable( btnImageNamed: m[i] )
                
                mrk.anchorPoint = CGPoint( x: 0.5, y: 0.5 )
                mrk.position = CGPoint( x: nodeX, y: yPos )
                
                nd.position = CGPoint( x: nodeX, y: yPos )
                nd.tripletPosition = getTripletPosition( yPos )
                
                markers.append( mrk )
                nodes.append( nd )
            }
        }
        
        for mrk in markers {
            addChild( mrk )
        }
        
        for nd in nodes {
            addChild( nd )
        }
        
        okBtn.enable()
    }
    
    func clear() {
        self.texture = SKTexture( imageNamed: "read-mode-placeholder" )
        markers.removeAll()
        nodes.removeAll()
        removeAllChildren()
    }
    
    // ON PRESS
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch:UITouch = touches.first!
        let touchedNode = self.atPoint( (touch.location( in: self )) )
        
        // Assign “selectedNode” to the pressed node
        if( touchedNode is TripletSelectorDraggable ) {
            self.isDragging = true
            selectedNode = touchedNode as! TripletSelectorDraggable
            selectedNode.setDownState()
            emptyPosition = getTripletPosition( selectedNode.position.y )
        }
    }
    
    // ON MOVE
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch:UITouch = touches.first!
        
        if self.isDragging {
            let scenePos = touch.location( in: self )
            let prevPos = touch.previousLocation( in: self )
            let toPosY = selectedNode.position.y + ( scenePos.y - prevPos.y )
            
            selectedNode.position.y = toPosY
            selectedNode.tripletPosition = getTripletPosition( toPosY )
            checkVacancy( selectedNode.tripletPosition )
        }
    }
    
    func checkVacancy( _ tp:TripletPosition ) {
        targetNode = nil
        
        for nd in nodes {
            if nd != selectedNode {
                if nd.tripletPosition == tp {
                    targetNode = nd
                }
            }
            nd.position.x = nodeX
        }
        
        if let tn:TripletSelectorDraggable = targetNode {
            tn.position.x = nodeX + 40
        }
        
    }
    
    // ON RELEASE
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.isDragging = false
        
        
        // Snap node to nearest marker
        if let sn:TripletSelectorDraggable = selectedNode {
            sn.setUpState()
            sn.run( SKAction.move( to: getTruePosition( sn.tripletPosition ), duration: 0.12 ) )
        }
        
        // Move “occuping” node to selectedNode’s now empty spot
        if let tn:TripletSelectorDraggable = targetNode {
            tn.tripletPosition = emptyPosition
            tn.run( SKAction.move( to: getTruePosition( emptyPosition ), duration: 0.12 ) )
        }
        
        // “Unassign” selectedNode and targetNodes
        selectedNode = nil
        targetNode = nil
        emptyPosition = .unknown
    }
    
    ///// HELPER FUNCTIONS

    func getTripletPosition ( _ y:CGFloat ) -> TripletPosition {
        var tP:TripletPosition = .unknown
        
        if( y >= areas[0] && y <= areas[1] ) {
            tP = .bottom
        } else if( y >= areas[1] && y <= areas[2] ) {
            tP = .middle
        } else if( y >= areas[2] && y <= areas[3] ) {
            tP = .top
        }
        
        return tP
    }
    
    func getTruePosition ( _ tp: TripletPosition ) -> CGPoint {
        return CGPoint( x: nodeX, y: areas[ tp.rawValue ] + self.size.height / 6 )
    }
    
    required init?( coder aDecoder: NSCoder ) {
        fatalError( "init(coder:) has not been implemented" )
    }
}

extension TripletSelector: ButtonDelegate {
    func buttonPressed( btnID: String ) {
        switch btnID {
        case "ok":
            okBtn.disable()
            for nd in nodes {
                switch nd.tripletPosition {
                case .top:
                    MultiPlayerController.comm.shareFlag( key: flagKeys[0], value: nd.btnID )
                    break
                case .middle:
                    MultiPlayerController.comm.shareFlag( key: flagKeys[1], value: nd.btnID )
                    break
                case .bottom:
                    MultiPlayerController.comm.shareFlag( key: flagKeys[2], value: nd.btnID )
                    break
                default:
                    break
                }
            }
            break
        default:
            break
        }
        
        MultiPlayerController.comm.sendReadModePageNo( self.toPage )
    }
    
    
}
