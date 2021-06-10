import Foundation
import MiscKit

extension Scenegraph {
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

    /// Retrurns the flattened tree of all the `SceneMark` items in this tree
    @inlinable public func flattened(depthFirst: Bool = true) -> [(index: IndexPath, element: SceneMark)] {
        treenumerate(root: self.root, depthFirst: depthFirst, children: \.children.faulted)
    }
}

extension Scenegraph.SceneMark {
    /// The children of this group scene, or nil if it is not a group scene
    @inlinable public var children: [Self]? {
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

extension Scenegraph {
    /// The total number of `SceneItem` instances in this graph
    @inlinable public var totalItemCount: Int {
        flattened().compactMap(\.element.sceneItems).map(\.count).reduce(0, +)
    }
}


/// An abstraction of a mark item
public protocol MarkItem {
    associatedtype ItemType : SceneItem
    var items: [ItemType]? { get set }

    var markType: SceneItemMark { get }

    /// The name of this mark
    var name: String? { get }

    /// The accessibiliy role of this mark
    var role: String? { get }

    /// A human-readable description of this mark
    var description: String? { get }

    /// The screenreader-friendly description of this mark
    var aria: Bool? { get }

    /// Whether the mark is interactive or not
    var interactive: Bool? { get }

    /// The z-index of this mark
    var zindex: Double? { get }
}

public enum SceneItemMark : String {
    case group
    case arc
    case area
    case image
    case line
    case path
    case rect
    case rule
    case symbol
    case text
    case trail
}

/// An abstraction of a scene item
public protocol SceneItem {

    /// The type of mark this scene item represents
    var markType: SceneItemMark { get }

    var x: Double? { get }
    var y: Double? { get }
    var width: Double? { get }
    var height: Double? { get }
    var zindex: Double? { get }

    // var x2: Double? { get } // only on rule
    // var y2: Double? { get } // only on rule

    var opacity: Double? { get }
    var fill: Scenegraph.Paint? { get }
    var fillOpacity: Double? { get }

    var stroke: Scenegraph.Paint? { get }
    var strokeOpacity: Double? { get }
    var strokeWidth: Double? { get }
    var strokeCap: Scenegraph.LiteralButtOrCapOrRound? { get }
    var strokeJoin: Scenegraph.LiteralMiterOrRoundOrBevel? { get }
    var strokeMiterLimit: Double? { get }
    var strokeDash: [Double]? { get }
    var strokeDashOffset: Double? { get }


    var cursor: String? { get }
    var href: String? { get }

    //var tooltip: Tooltip? { get }
    var description: String? { get }

    var aria: Bool? { get }
    var ariaRole: String? { get }
    var ariaRoleDescription: String? { get }
}

extension Scenegraph.MarkGroup : MarkItem {
    public var markType: SceneItemMark {
        .group
    }
}

extension Scenegraph.MarkArc : MarkItem {
    public var markType: SceneItemMark {
        .arc
    }
}


extension Scenegraph.MarkArea : MarkItem {
    public var markType: SceneItemMark {
        .area
    }
}


extension Scenegraph.MarkImage : MarkItem {
    public var markType: SceneItemMark {
        .image
    }
}


extension Scenegraph.MarkLine : MarkItem {
    public var markType: SceneItemMark {
        .line
    }
}


extension Scenegraph.MarkPath : MarkItem {
    public var markType: SceneItemMark {
        .path
    }
}


extension Scenegraph.MarkRect : MarkItem {
    public var markType: SceneItemMark {
        .rect
    }
}


extension Scenegraph.MarkRule : MarkItem {
    public var markType: SceneItemMark {
        .rule
    }
}


extension Scenegraph.MarkSymbol : MarkItem {
    public var markType: SceneItemMark {
        .symbol
    }
}


extension Scenegraph.MarkText : MarkItem {
    public var markType: SceneItemMark {
        .text
    }
}


extension Scenegraph.MarkTrail : MarkItem {
    public var markType: SceneItemMark {
        .trail
    }
}



extension Scenegraph.ItemGroup : SceneItem {
    public var markType: SceneItemMark {
        .group
    }
}

extension Scenegraph.ItemArc : SceneItem {
    public var markType: SceneItemMark {
        .arc
    }
}


extension Scenegraph.ItemArea : SceneItem {
    public var markType: SceneItemMark {
        .area
    }
}


extension Scenegraph.ItemImage : SceneItem {
    public var markType: SceneItemMark {
        .image
    }
}


extension Scenegraph.ItemLine : SceneItem {
    public var markType: SceneItemMark {
        .line
    }
}


extension Scenegraph.ItemPath : SceneItem {
    public var markType: SceneItemMark {
        .path
    }
}


extension Scenegraph.ItemRect : SceneItem {
    public var markType: SceneItemMark {
        .rect
    }
}


extension Scenegraph.ItemRule : SceneItem {
    public var markType: SceneItemMark {
        .rule
    }
}


extension Scenegraph.ItemSymbol : SceneItem {
    public var markType: SceneItemMark {
        .symbol
    }
}


extension Scenegraph.ItemText : SceneItem {
    public var markType: SceneItemMark {
        .text
    }
}


extension Scenegraph.ItemTrail : SceneItem {
    public var markType: SceneItemMark {
        .trail
    }
}




public extension Scenegraph {
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

extension Scenegraph.SceneItem : SceneItem {
    public var markType: SceneItemMark {
        // self[routing: \.markType, \.markType, \.markType, \.markType, \.markType, \.markType, \.markType, \.markType, \.markType, \.[routing: \.markType, \.markType]]
        self[routing: (\.markType, \.markType, \.markType, \.markType, \.markType, \.markType, \.markType, \.markType, \.markType, { $0[routing: (\.markType, \.markType)] } )]
    }

    public var zindex: Double? {
        self[routing: \.zindex, \.zindex, \.zindex, \.zindex, \.zindex, \.zindex, \.zindex, \.zindex, \.zindex, \.[routing: \.zindex, \.zindex]]
    }

    public var opacity: Double? {
        self[routing: \.opacity, \.opacity, \.opacity, \.opacity, \.opacity, \.opacity, \.opacity, \.opacity, \.opacity, \.[routing: \.opacity, \.opacity]]
    }

    public var fill: Scenegraph.Paint? {
        self[routing: \.fill, \.fill, \.fill, \.fill, \.fill, \.fill, \.fill, \.fill, \.fill, \.[routing: \.fill, \.fill]]
    }

    public var fillOpacity: Double? {
        self[routing: \.fillOpacity, \.fillOpacity, \.fillOpacity, \.fillOpacity, \.fillOpacity, \.fillOpacity, \.fillOpacity, \.fillOpacity, \.fillOpacity, \.[routing: \.fillOpacity, \.fillOpacity]]
    }

    public var stroke: Scenegraph.Paint? {
        self[routing: \.stroke, \.stroke, \.stroke, \.stroke, \.stroke, \.stroke, \.stroke, \.stroke, \.stroke, \.[routing: \.stroke, \.stroke]]
    }

    public var strokeOpacity: Double? {
        self[routing: \.strokeOpacity, \.strokeOpacity, \.strokeOpacity, \.strokeOpacity, \.strokeOpacity, \.strokeOpacity, \.strokeOpacity, \.strokeOpacity, \.strokeOpacity, \.[routing: \.strokeOpacity, \.strokeOpacity]]
    }

    public var strokeWidth: Double? {
        self[routing: \.strokeWidth, \.strokeWidth, \.strokeWidth, \.strokeWidth, \.strokeWidth, \.strokeWidth, \.strokeWidth, \.strokeWidth, \.strokeWidth, \.[routing: \.strokeWidth, \.strokeWidth]]
    }

    public var strokeCap: Scenegraph.LiteralButtOrCapOrRound? {
        self[routing: \.strokeCap, \.strokeCap, \.strokeCap, \.strokeCap, \.strokeCap, \.strokeCap, \.strokeCap, \.strokeCap, \.strokeCap, \.[routing: \.strokeCap, \.strokeCap]]
    }

    public var strokeJoin: Scenegraph.LiteralMiterOrRoundOrBevel? {
        self[routing: \.strokeJoin, \.strokeJoin, \.strokeJoin, \.strokeJoin, \.strokeJoin, \.strokeJoin, \.strokeJoin, \.strokeJoin, \.strokeJoin, \.[routing: \.strokeJoin, \.strokeJoin]]
    }

    public var strokeMiterLimit: Double? {
        self[routing: \.strokeMiterLimit, \.strokeMiterLimit, \.strokeMiterLimit, \.strokeMiterLimit, \.strokeMiterLimit, \.strokeMiterLimit, \.strokeMiterLimit, \.strokeMiterLimit, \.strokeMiterLimit, \.[routing: \.strokeMiterLimit, \.strokeMiterLimit]]
    }

    public var strokeDash: [Double]? {
        self[routing: \.strokeDash, \.strokeDash, \.strokeDash, \.strokeDash, \.strokeDash, \.strokeDash, \.strokeDash, \.strokeDash, \.strokeDash, \.[routing: \.strokeDash, \.strokeDash]]
    }

    public var strokeDashOffset: Double? {
        self[routing: \.strokeDashOffset, \.strokeDashOffset, \.strokeDashOffset, \.strokeDashOffset, \.strokeDashOffset, \.strokeDashOffset, \.strokeDashOffset, \.strokeDashOffset, \.strokeDashOffset, \.[routing: \.strokeDashOffset, \.strokeDashOffset]]
    }

    public var cursor: String? {
        self[routing: \.cursor, \.cursor, \.cursor, \.cursor, \.cursor, \.cursor, \.cursor, \.cursor, \.cursor, \.[routing: \.cursor, \.cursor]]
    }

    public var href: String? {
        self[routing: \.href, \.href, \.href, \.href, \.href, \.href, \.href, \.href, \.href, \.[routing: \.href, \.href]]
    }

    public var description: String? {
        self[routing: \.description, \.description, \.description, \.description, \.description, \.description, \.description, \.description, \.description, \.[routing: \.description, \.description]]
    }

    public var aria: Bool? {
        self[routing: \.aria, \.aria, \.aria, \.aria, \.aria, \.aria, \.aria, \.aria, \.aria, \.[routing: \.aria, \.aria]]
    }

    public var ariaRole: String? {
        self[routing: \.ariaRole, \.ariaRole, \.ariaRole, \.ariaRole, \.ariaRole, \.ariaRole, \.ariaRole, \.ariaRole, \.ariaRole, \.[routing: \.ariaRole, \.ariaRole]]
    }

    public var ariaRoleDescription: String? {
        self[routing: \.ariaRoleDescription, \.ariaRoleDescription, \.ariaRoleDescription, \.ariaRoleDescription, \.ariaRoleDescription, \.ariaRoleDescription, \.ariaRoleDescription, \.ariaRoleDescription, \.ariaRoleDescription, \.[routing: \.ariaRoleDescription, \.ariaRoleDescription]]
    }


}

public extension Scenegraph.SceneMark {
//    var name: String? {
//        get {
//            asOneOf[routing: \.name, \.name, \.name, \.name, \.name, \.name, \.name, \.name, \.name, \.[routing: \.name, \.name]]
//        }
//    }

    var sceneItems: [Scenegraph.SceneItem]? {
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

    /// The mark if this is a `markGroupCase`, otherwise `nil`
    var markGroup: Scenegraph.MarkGroup? {
        if case .markGroupCase(let x) = self { return x } else { return nil }
    }

    /// The mark if this is a `markArcCase`, otherwise `nil`
    var markArc: Scenegraph.MarkArc? {
        if case .markArcCase(let x) = self { return x } else { return nil }
    }

    /// The mark if this is a `markAreaCase`, otherwise `nil`
    var markArea: Scenegraph.MarkArea? {
        if case .markAreaCase(let x) = self { return x } else { return nil }
    }

    /// The mark if this is a `markImageCase`, otherwise `nil`
    var markImage: Scenegraph.MarkImage? {
        if case .markImageCase(let x) = self { return x } else { return nil }
    }

    /// The mark if this is a `markLineCase`, otherwise `nil`
    var markLine: Scenegraph.MarkLine? {
        if case .markLineCase(let x) = self { return x } else { return nil }
    }

    /// The mark if this is a `markPathCase`, otherwise `nil`
    var markPath: Scenegraph.MarkPath? {
        if case .markPathCase(let x) = self { return x } else { return nil }
    }

    /// The mark if this is a `markRectCase`, otherwise `nil`
    var markRect: Scenegraph.MarkRect? {
        if case .markRectCase(let x) = self { return x } else { return nil }
    }

    /// The mark if this is a `markRuleCase`, otherwise `nil`
    var markRule: Scenegraph.MarkRule? {
        if case .markRuleCase(let x) = self { return x } else { return nil }
    }

    /// The mark if this is a `markSymbolCase`, otherwise `nil`
    var markSymbol: Scenegraph.MarkSymbol? {
        if case .markSymbolCase(let x) = self { return x } else { return nil }
    }

    /// The mark if this is a `markTextCase`, otherwise `nil`
    var markText: Scenegraph.MarkText? {
        if case .markTextCase(let x) = self { return x } else { return nil }
    }

    /// The mark if this is a `markTrailCase`, otherwise `nil`
    var markTrail: Scenegraph.MarkTrail? {
        if case .markTrailCase(let x) = self { return x } else { return nil }
    }
}


public extension Scenegraph.SceneItem {
    /// The X coordinate of the item
    var x: Double? {
        get { self[routing: \.x, \.x, \.x, \.x, \.x, \.x, \.x, \.x, \.x, \.[routing: \.x, \.x]] }
        set { self[routing: \.x, \.x, \.x, \.x, \.x, \.x, \.x, \.x, \.x, \.[routing: \.x, \.x]] = newValue }
    }

    /// The Y coordinate of the item
    var y: Double? {
        get { self[routing: \.y, \.y, \.y, \.y, \.y, \.y, \.y, \.y, \.y, \.[routing: \.y, \.y]] }
        set { self[routing: \.y, \.y, \.y, \.y, \.y, \.y, \.y, \.y, \.y, \.[routing: \.y, \.y]] = newValue }
    }

    /// The width of the item
    var width: Double? {
        get { self[routing: \.width, \.width, \.width, \.width, \.width, \.width, \.width, \.width, \.width, \.[routing: \.width, \.width]] }
        set { self[routing: \.width, \.width, \.width, \.width, \.width, \.width, \.width, \.width, \.width, \.[routing: \.width, \.width]] = newValue }
    }

    /// The height of the item
    var height: Double? {
        get { self[routing: \.height, \.height, \.height, \.height, \.height, \.height, \.height, \.height, \.height, \.[routing: \.height, \.height]] }

        set { self[routing: \.height, \.height, \.height, \.height, \.height, \.height, \.height, \.height, \.height, \.[routing: \.height, \.height]] = newValue }
    }

}
