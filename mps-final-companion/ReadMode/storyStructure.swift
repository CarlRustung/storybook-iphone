enum ReadModeInteractionType: String {
    case endPage = "endPage"
    case endScene = "endScene"
    case hotspots = "hotspots"
    case charSelect = "charSelect"
    case charDesc = "charDesc"
    case tripletSelector = "tripletSelector"
    case flagRedirect = "flagRedirect"
}

struct ReadModePageData: Codable {
    let pages: Array<ReadModePage>
}

struct ReadModePage: Codable {
    let pageNo: Float
    let ixType: String
    let illustration: String?
    let text: String?
    let choices: Array<HotspotChoice>?
    let characterData: CharacterData?
    let forCharacter: String?
    let descriptions: CharacterDescriptions?
    let movables: Array<String>?
    let setFlags: Array<String>?
    let checkFlagKey: String?
    let redirectByFlag: Array<FlagRedirectData>?
}


//// HOTSPOTS

struct HotspotChoice: Codable {
    let toPage: Float
    let hotspot: HotspotData
    let setFlag: Flag
}

struct HotspotData: Codable {
    let illustration: String
    let xPos: Float
    let yPos: Float
}


//// CHARACTER SELECT

struct CharacterData: Codable {
    let toPage: Float
    let name: String
    let look: FlagSelection
    let interest: FlagSelection
}

struct CharacterDescriptions: Codable {
    let lookFlag: String
    let interestFlag: String
    let values: Array<CharacterDescription>
}

struct CharacterDescription: Codable {
    let look: String
    let description: Array<DescriptionByInterest>
}

struct DescriptionByInterest: Codable {
    let interest: String
    let characterDescription: String
}


//// REDIRECTION BY FLAG

struct FlagRedirectData: Codable {
    let flagValue: String
    let redirectFlagKey: String
    let redirect:Array<FlagRedirect>
}

struct FlagRedirect: Codable {
    let flagValue: String
    let toPage: Float
}

struct Flag: Codable {
    let key: String
    let value: String
}

struct FlagSelection: Codable {
    let key: String
    let values: Array<String>
}
