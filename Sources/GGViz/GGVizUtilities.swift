import Foundation
import MiscKit

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

    /// Retrurns the flattened tree of all the `SceneMark` items in this tree
    @inlinable public func flattened(depthFirst: Bool = true) -> [(index: IndexPath, element: SceneMark)] {
        treenumerate(root: self.root, depthFirst: depthFirst, children: \.children.faulted)
    }
}

extension GGSceneGraph.SceneMark {
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

/// An abstraction of a mark item
public protocol SceneMark {
    associatedtype ItemType : SceneItem
    var items: [ItemType]? { get set }
}

/// An absrtraction of a scene item
public protocol SceneItem {
    var x: Double? { get set }
    var y: Double? { get set }
    var width: Double? { get set }
    var height: Double? { get set }

    var opacity: Double? { get set }
    var fill: GGSceneGraph.Paint? { get set }
    var fillOpacity: Double? { get set }
    var stroke: GGSceneGraph.Paint? { get set }
    var strokeOpacity: Double? { get set }
    var strokeWidth: Double? { get set }
    var strokeCap: GGSceneGraph.LiteralButtOrCapOrRound? { get set }
    var strokeJoin: GGSceneGraph.LiteralMiterOrRoundOrBevel? { get set }
    var strokeMiterLimit: Double? { get set }
    var strokeDash: [Double]? { get set }
    var strokeDashOffset: Double? { get set }
    var zindex: Double? { get set }

    var cursor: String? { get set }
    var href: String? { get set }

    //var tooltip: Tooltip? { get set }
    var description: String? { get set }

    var aria: Bool? { get set }
    var ariaRole: String? { get set }
    var ariaRoleDescription: String? { get set }
}

extension GGSceneGraph.MarkGroup : SceneMark { }
extension GGSceneGraph.MarkArc : SceneMark { }
extension GGSceneGraph.MarkArea : SceneMark { }
extension GGSceneGraph.MarkImage : SceneMark { }
extension GGSceneGraph.MarkLine : SceneMark { }
extension GGSceneGraph.MarkPath : SceneMark { }
extension GGSceneGraph.MarkRect : SceneMark { }
extension GGSceneGraph.MarkRule : SceneMark { }
extension GGSceneGraph.MarkSymbol : SceneMark { }
extension GGSceneGraph.MarkText : SceneMark { }
extension GGSceneGraph.MarkTrail : SceneMark { }

extension GGSceneGraph.ItemGroup : SceneItem { }
extension GGSceneGraph.ItemArc : SceneItem { }
extension GGSceneGraph.ItemArea : SceneItem { }
extension GGSceneGraph.ItemImage : SceneItem { }
extension GGSceneGraph.ItemLine : SceneItem { }
extension GGSceneGraph.ItemPath : SceneItem { }
extension GGSceneGraph.ItemRect : SceneItem { }
extension GGSceneGraph.ItemRule : SceneItem { }
extension GGSceneGraph.ItemSymbol : SceneItem { }
extension GGSceneGraph.ItemText : SceneItem { }
extension GGSceneGraph.ItemTrail : SceneItem { }


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

    /// The mark if this is a `markGroupCase`, otherwise `nil`
    var markGroup: GGSceneGraph.MarkGroup? {
        if case .markGroupCase(let x) = self { return x } else { return nil }
    }

    /// The mark if this is a `markArcCase`, otherwise `nil`
    var markArc: GGSceneGraph.MarkArc? {
        if case .markArcCase(let x) = self { return x } else { return nil }
    }

    /// The mark if this is a `markAreaCase`, otherwise `nil`
    var markArea: GGSceneGraph.MarkArea? {
        if case .markAreaCase(let x) = self { return x } else { return nil }
    }

    /// The mark if this is a `markImageCase`, otherwise `nil`
    var markImage: GGSceneGraph.MarkImage? {
        if case .markImageCase(let x) = self { return x } else { return nil }
    }

    /// The mark if this is a `markLineCase`, otherwise `nil`
    var markLine: GGSceneGraph.MarkLine? {
        if case .markLineCase(let x) = self { return x } else { return nil }
    }

    /// The mark if this is a `markPathCase`, otherwise `nil`
    var markPath: GGSceneGraph.MarkPath? {
        if case .markPathCase(let x) = self { return x } else { return nil }
    }

    /// The mark if this is a `markRectCase`, otherwise `nil`
    var markRect: GGSceneGraph.MarkRect? {
        if case .markRectCase(let x) = self { return x } else { return nil }
    }

    /// The mark if this is a `markRuleCase`, otherwise `nil`
    var markRule: GGSceneGraph.MarkRule? {
        if case .markRuleCase(let x) = self { return x } else { return nil }
    }

    /// The mark if this is a `markSymbolCase`, otherwise `nil`
    var markSymbol: GGSceneGraph.MarkSymbol? {
        if case .markSymbolCase(let x) = self { return x } else { return nil }
    }

    /// The mark if this is a `markTextCase`, otherwise `nil`
    var markText: GGSceneGraph.MarkText? {
        if case .markTextCase(let x) = self { return x } else { return nil }
    }

    /// The mark if this is a `markTrailCase`, otherwise `nil`
    var markTrail: GGSceneGraph.MarkTrail? {
        if case .markTrailCase(let x) = self { return x } else { return nil }
    }
}


public extension GGSceneGraph.SceneItem {
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
