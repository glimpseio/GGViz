import Foundation


extension GGSceneGraph {
    /// Returns the root `Mark` of the scenegraph
    public var root: SceneMark {
        get {
            switch self {
                case .markCase(let mark): return mark
            }
        }

        set {
            self = .init(newValue)
        }
    }
}

extension GGSceneGraph.SceneMark {
    /// The children of this group scene, or nil if it is not a group scene
    public var children: [GGSceneGraph.SceneMark]? {
        get {
            switch self {
            case .markGroupCase(let x):
                return (x.items?.compactMap(\.items).joined()).map(Array.init)
            default:
                return nil
            }
        }
    }
}

public extension GGSceneGraph {
    /// One of the possible items
    typealias SceneItem = OneOf<ItemGroup>
        .Or<ItemArc>
        .Or<ItemArea>
        .Or<ItemImage>
        .Or<ItemLine>
        .Or<ItemPath>
        .Or<ItemRect>
        .Or<ItemRule>
        .Or<ItemSymbol>
        .Or<ItemText>
        .Or<ItemTrail>
}


public extension GGSceneGraph.SceneMark {
//    var name: String? {
//        get {
//            asOneOf[routing: \.name, \.name, \.name, \.name, \.name, \.name, \.name, \.name, \.name, \.[routing: \.name, \.name]]
//        }
//    }

    var sceneItems: [GGSceneGraph.SceneItem]? {
        switch self {
        case .markGroupCase(let x):
            return x.items?.map(oneOf)
        case .markArcCase(let x):
            return x.items?.map(oneOf)
        case .markAreaCase(let x):
            return x.items?.map(oneOf)
        case .markImageCase(let x):
            return x.items?.map(oneOf)
        case .markLineCase(let x):
            return x.items?.map(oneOf)
        case .markPathCase(let x):
            return x.items?.map(oneOf)
        case .markRectCase(let x):
            return x.items?.map(oneOf)
        case .markRuleCase(let x):
            return x.items?.map(oneOf)
        case .markSymbolCase(let x):
            return x.items?.map(oneOf)
        case .markTextCase(let x):
            return x.items?.map({ oneOf(oneOf($0)) })
        case .markTrailCase(let x):
            return x.items?.map({ oneOf(oneOf($0)) })
        }
    }
}


public extension GGSceneGraph.SceneItem {
    /// The X coordinate of the item
    var x: Double? {
        get {
            self[routing: \.x, \.x, \.x, \.x, \.x, \.x, \.x, \.x, \.x, \.[routing: \.x, \.x]]
        }

        set {
            self[routing: \.x, \.x, \.x, \.x, \.x, \.x, \.x, \.x, \.x, \.[routing: \.x, \.x]] = newValue
        }
    }

    /// The Y coordinate of the item
    var y: Double? {
        get {
            self[routing: \.y, \.y, \.y, \.y, \.y, \.y, \.y, \.y, \.y, \.[routing: \.y, \.y]]
        }

        set {
            self[routing: \.y, \.y, \.y, \.y, \.y, \.y, \.y, \.y, \.y, \.[routing: \.y, \.y]] = newValue
        }
    }

    /// The width of the item
    var width: Double? {
        get {
            self[routing: \.width, \.width, \.width, \.width, \.width, \.width, \.width, \.width, \.width, \.[routing: \.width, \.width]]
        }

        set {
            self[routing: \.width, \.width, \.width, \.width, \.width, \.width, \.width, \.width, \.width, \.[routing: \.width, \.width]] = newValue
        }
    }

    /// The height of the item
    var height: Double? {
        get {
            self[routing: \.height, \.height, \.height, \.height, \.height, \.height, \.height, \.height, \.height, \.[routing: \.height, \.height]]
        }

        set {
            self[routing: \.height, \.height, \.height, \.height, \.height, \.height, \.height, \.height, \.height, \.[routing: \.height, \.height]] = newValue
        }
    }

}

