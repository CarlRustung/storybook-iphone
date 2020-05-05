import SpriteKit
import GameplayKit

class ReadMode: SKScene {
    
    var sceneScript: ReadModePageData!
    
    var currentPageNumber:Float = 1
    var currentPage: ReadModePage!
    
    var illustrationView: IllustrationView!
    
    override init( size: CGSize ) {
        super.init( size: size )
    }
    
    override func didMove( to view: SKView ) {
        illustrationView = IllustrationView( view )
        
        illustrationView.position = CGPoint( x: 0, y: 0 )
        addChild( illustrationView )
        
        MultiPlayerController.comm.setReadModeDelegate( self )
        loadSceneJSON( "readingData" )
    }
    
    func loadSceneJSON(_ fileName: String ) {
        if let path = Bundle.main.path( forResource: fileName, ofType: "json" ) {
            do {
                let readingData = try Data( contentsOf: URL( fileURLWithPath: path ), options: .mappedIfSafe )
                sceneScript = try! JSONDecoder().decode( ReadModePageData.self, from: readingData )
            } catch {
                //
            }
        }
        
        currentPage = getPageWithPageNo( currentPageNumber )
        
        if let iV = illustrationView {
            iV.loadPage( currentPage )
        }
        
        /* TODO: UPDATE -> Move to IllustrationView class
        if let pageChoices:Array<Float> = currentPage.pageChoices {
            var choices:Array<ReadModePage> = Array<ReadModePage>()
            for pageNum in pageChoices {
                choices.append( getPageWithPageNum( pageNum ) )
            }
            illustrationView.loadChoices( choices )
        }
        */
    }
    
    func getPageWithPageNo(_ pageNo:Float ) -> ReadModePage {
        return sceneScript.pages.filter{ $0.pageNo == pageNo }[0]
    }
    
    //// SKScene Functions
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    required init?( coder aDecoder: NSCoder ) {
        fatalError( "NSCoder not supported" )
    }
}


//// MULTIPLAYER EVENTS

extension ReadMode: ReadModeMPDelegate {
    func turnPage() {
        //print( "Turning page..." )
        currentPageNumber += 1
        
        currentPage = getPageWithPageNo( currentPageNumber )
        illustrationView.loadPage( currentPage )
    }
    
    func setPage(_ pageNo: String ) {
        print( "Received page no: " + pageNo )
        
        let page:ReadModePage = getPageWithPageNo( Float( pageNo )! )
        illustrationView.loadPage( page )
    }
}
