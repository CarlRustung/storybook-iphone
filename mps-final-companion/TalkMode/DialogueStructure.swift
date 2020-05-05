struct Dialogue:Codable {
    let description:String
    let icebreaker:Int
    let firstResponse:Int
    let lines: Array<Line>
}

struct Line:Codable {
    let id:Int
    let character:String
    let responses:Array<Response>
}

struct Response:Codable {
    let type:String
    let words:String
    let lineReference:Int
    let inventory:String?
    let flagCompanion:Bool?
    let flagLocation:String?
    
    private enum CodingKeys: String, CodingKey {
        case type = "responseType"
        case words = "words_EN"
        case lineReference = "lineReference"
        case inventory = "inventory"
        case flagCompanion = "flag_companion"
        case flagLocation = "flag_location"
    }
}
