import GGSpec

/// The old alias for `Field` goes to `SourceColumnRef`
@available(*, deprecated, renamed: "SourceColumnRef")
public typealias Field = SourceColumnRef

/// The old alias for `Transform`
@available(*, deprecated, renamed: "DataTransformation")
public typealias Transform = DataTransformation

/// The old alias for the `Config`
@available(*, deprecated, renamed: "Config")
public typealias Config = ConfigTheme

/// The old alias for the PrimitiveMarkType
@available(*, deprecated, renamed: "PrimitiveMarkType")
public typealias Mark = PrimitiveMarkType

@available(*, deprecated, renamed: "BoxPlotLiteral")
public typealias BoxPlot = BoxPlotLiteral

@available(*, deprecated, renamed: "ErrorBarLiteral")
public typealias ErrorBar = ErrorBarLiteral

@available(*, deprecated, renamed: "ErrorBandLiteral")
public typealias ErrorBand = ErrorBandLiteral

/// The direction of a repeating field
public typealias RepeatFacet = RepeatRef.LiteralRowOrColumnOrRepeatOrLayer

/// The type of ancoding channel; x, y, shape, color, etc…
public typealias EncodingChannel = FacetedEncoding.CodingKeys

/// A VizSpec that stores its metadata as an unstructured JSON object.
public typealias SimpleVizSpec = VizSpec<Bric.ObjType>

/// The metadata associated with a `VizSpec`, which can be any `Pure` (`Hashable` + `Codable` + `Sendable`)  type.
public typealias VizSpecMeta = Pure

/// A source of data for a layer
public typealias VizDataSource = Nullable<DataProvider> // e.g., TopLevelUnitSpec.DataChoice

/// A type that either be a static value (typically a number or string) or the result of a dynamic [expression](https://vega.github.io/vega/docs/expressions/)
public typealias Exprable<T> = OneOf2<T, ExprRef>


// MARK: Layer Arrangement

/// The arrangement of sublayers in this `VizSpec`.
public enum LayerArrangement : CaseIterable, Hashable {
    case overlay
    case hconcat
    case vconcat
    case concat
    case `repeat`
}

public extension LayerArrangement {
    static var horizontal = Self.hconcat
    static var vertical = Self.vconcat
    static var wrap = Self.concat
}

public extension LayerArrangement {
    /// The repeat form of this arrangement
    var repeatRef: RepeatRef {
        switch self {
        case .overlay:
            return RepeatRef(repeat: .layer)
        case .hconcat:
            return RepeatRef(repeat: .column)
        case .vconcat:
            return RepeatRef(repeat: .row)
        case .concat:
            return RepeatRef(repeat: .repeat)
        case .repeat:
            return RepeatRef(repeat: .repeat)
        }
    }
}

public extension VizSpec {
    /// The arrangement of sub-layers of this spec, based on which sublayer property is set; this should only ever have at most one element
    @inlinable var arrangements: [LayerArrangement] {
        [
            self.layer != nil ? LayerArrangement.overlay : nil,
            self.concat != nil ? LayerArrangement.concat : nil,
            self.hconcat != nil ? LayerArrangement.hconcat : nil,
            self.vconcat != nil ? LayerArrangement.vconcat : nil,
            self.spec != nil ? LayerArrangement.repeat : nil,
        ]
        .compactMap({ $0 })
    }

    /// The arrangement of sub-layers of this spec; note that changing the arrangement
    /// type will result in the transfer of existing layers to the new sublayer
    /// holder, which may result in the loss of data (such as taking multiple `overlay`
    /// layers and playing them into a `repeat` layer, which can hold only a single item).
    ///
    /// This property is derived solely from whether the properties
    /// `layer`, `hconcat`, `vconcat`, `concat`, and `spec` are set or not.
    @inlinable var arrangement: LayerArrangement {
        get {
            self.arrangements.first ?? .overlay // fallback to the overlay default
        }

        set {
            let subs = self.sublayers
            // make sure all other layers are cleared before assigning; both because it is invalid to have
            // more than one sublayer field, but also because this is how we calculate the `arrangement` field.
            (self.layer, self.concat, self.hconcat, self.vconcat, self.spec) = (nil, nil, nil, nil, nil)

            switch newValue {
            case .overlay: self.layer = subs
            case .hconcat: self.hconcat = subs
            case .vconcat: self.vconcat = subs
            case .concat: self.concat = subs
            case .repeat: self.spec = subs.first.flatMap({ .init($0) }) // we drop all but the first element here
            }
        }
    }


    /// The number of sublayers
    @inlinable var sublayerCount: Int {
        if let sub = self.layer { return sub.count }
        if let sub = self.concat { return sub.count }
        if let sub = self.hconcat { return sub.count }
        if let sub = self.vconcat { return sub.count }
        return self.spec != nil ? 1 : 0
    }

    /// The indices of the sublayers
    @inlinable var sublayerIndices: ClosedRange<Int> {
        0...sublayerCount
    }

    /// The sublayers of this layer, or nil if there are none
    @inlinable var childLayers: [VizSpec]? {
        layer ?? concat ?? hconcat ?? vconcat ?? spec?.flatMap({ [$0] })
    }

    /// Returns the shallow sublayers for this spec from `.layer`, `.concat`, `.hconcat`, and `.vconcat`
    @inlinable var sublayers: [VizSpec] {
        get {
            childLayers.defaulted
        }

        _modify {
            var subs = self.sublayers
            yield &subs

            let arrangement = self.arrangement
            // make sure all other layers are cleared before assigning; both because it is invalid to have
            // more than one sublayer field, but also because this is how we calculate the `arrangement` field.
            (self.layer, self.concat, self.hconcat, self.vconcat, self.spec) = (nil, nil, nil, nil, nil)
            if subs.isEmpty { return } // clear out all sublayers
            switch arrangement {
            case .overlay: self.layer = subs
            case .concat: self.concat = subs
            case .hconcat: self.hconcat = subs
            case .vconcat: self.vconcat = subs
            case .repeat: self.spec = subs.first.flatMap({ .init($0) }) // repeat can only be a single element
            }
        }
    }

    /// A layer is a group mark when it has children
    @inlinable var isGroup: Bool { mark == nil && sublayers.isEmpty == false }

    /// Whether a layer is a concat spec or not
    @inlinable var isConcat: Bool {
        !hconcat.faulted.isEmpty
            || !vconcat.faulted.isEmpty
            || !concat.faulted.isEmpty
    }

    @inlinable var isRepeat: Bool {
        self.`repeat` != nil
    }

    /// The number of child layers this spec is permitted to contain, or nil if there is no upper limit
    @inlinable var childCapacity: Int? {
        if !isGroup {
            return 0
        } else {
            switch arrangement {
            case .overlay: return nil
            case .hconcat: return nil
            case .vconcat: return nil
            case .concat: return nil
            case .repeat: return 1
            }
        }
    }
}


// MARK: Mark types

/// An identifier for a mark type.
/// Isomorphic with `MarkChoice` (i.e., `OneOf2<PrimitiveMarkType, CompositeMark>`).
public enum MarkType: String, CaseIterable, Hashable, Codable {
    case point
    case circle
    case square
    case rect

    case text
    case tick
    case rule

    case bar
    case line
    case area
    case trail

    case arc

    case geoshape
    case image

    case boxplot
    case errorbar
    case errorband
}

/// A compactable instance can convert itself to a `compactRepresentation` that has the same semantic meaning as the original.
public protocol Compactable {
    /// Returns a compact version of this instance, which reduces it down to its most compact form without losing information.
    ///
    /// - Note: The compact form of an instance is not necessarily equal to the original instance.
    var compactRepresentation: Self { get }
}

extension AnyMark : Compactable {
    /// Returns a simplified version of this mark, replacing an empty `MarkDef` with the symbolic constant for the mark. This can be useful when it is important to generate minimal versions of the spec.
    ///
    /// For example, this will convert `{ "mark": { "type": "line" } }` into `{ "mark": "line" }`.
    public var compactRepresentation: AnyMark {
        switch rawValue {
        case .v1, .v3: // already tidy
            return self
        case .v2(let def):
            switch def.type.rawValue {
            case .v1(let type):
                return def == CompositeMarkDef(.init(type: type)) ? .init(def.type) : self
            case .v2(let type):
                return def == CompositeMarkDef(.init(type: type)) ? .init(def.type) : self
            case .v3(let type):
                return def == CompositeMarkDef(.init(type: type)) ? .init(def.type) : self
            }
        case .v4(let def):
            return def == MarkDef(type: def.type) ? .init(def.type) : self
        }
    }
}

/// Internal choice for a differnet mark type; used internally by `MarkType`
public typealias MarkChoice = OneOf<PrimitiveMarkType>.Or<CompositeMark>

/// An `AnyMarkDef` is a compound enumeration of the different mark types
/// This is the complex enum part of:
/// `AnyMark = OneOf4<CompositeMark, CompositeMarkDef, Mark, MarkDef>`
public typealias AnyMarkDef = OneOf<MarkDef>.Or<CompositeMarkDef>

extension AnyMarkDef {
    public var markChoice: MarkChoice {
        switch self {
        case .v1(let x): return .init(x.type)
        case .v2(let x): return .init(x.type)
        }
    }
}

public extension CompositeMarkDef {
    /// Returns the `CompositeMark` type of this mark type
    var type: CompositeMark {
        switch rawValue {
        case .v1(let x): return .init(.init(x.type))
        case .v2(let x): return .init(.init(x.type))
        case .v3(let x): return .init(.init(x.type))
        }
    }
}

public extension MarkDef {
    var markChoice: MarkChoice {
        return .init(self.type)
    }
}

public extension MarkType {
    /// Returns `true` if this is a simple mark type (e.g, a `point`)
    var isPrimitiveMark: Bool {
        switch markChoice {
        case .v1: return true
        case .v2: return false
        }
    }

    /// Returns `true` if this is a composite mark type (e.g, a `boxplot`)
    var isCompositeMark: Bool {
        switch markChoice {
        case .v1: return false
        case .v2: return true
        }
    }
}

extension MarkType {
    /// Convert from this single enum to a `MarkChoice` (aka ` OneOf2<PrimitiveMarkType, CompositeMark>`)
    @inlinable public var markChoice: MarkChoice {
        switch self {
        case .arc: return .init(.arc)
        case .area: return .init(.area)
        case .bar: return .init(.bar)
        case .line: return .init(.line)
        case .trail: return .init(.trail)
        case .point: return .init(.point)
        case .text: return .init(.text)
        case .tick: return .init(.tick)
        case .rect: return .init(.rect)
        case .rule: return .init(.rule)
        case .circle: return .init(.circle)
        case .square: return .init(.square)
        case .image: return .init(.image)
        case .geoshape: return .init(.geoshape)
        case .boxplot: return .init(.boxplot)
        case .errorbar: return .init(.errorbar)
        case .errorband: return .init(.errorband)
        }
    }
}

public extension PrimitiveMarkType {
    var markType: MarkType {
        switch self {
        case .arc: return .arc
        case .area: return .area
        case .bar: return .bar
        case .line: return .line
        case .trail: return .trail
        case .point: return .point
        case .text: return .text
        case .tick: return .tick
        case .rect: return .rect
        case .rule: return .rule
        case .circle: return .circle
        case .square: return .square
        case .image: return .image
        case .geoshape: return .geoshape
        }
    }
}

public extension MarkChoice {
    /// The unified `MarkType` for this mark
    var markType: MarkType {
        self[routing: (\.markType, \.markType)]
    }
}

public extension CompositeMark { // i.e., OneOf3<BoxPlot, ErrorBar, ErrorBand>
    static let boxplot = Self(.init(.boxplot))
    static let errorbar = Self(.init(.errorbar))
    static let errorband = Self(.init(.errorband))


    var markType: MarkType {
        func check<T, U>(arg typeValue: T, is type: T.Type, value: U) -> U {
            value
        }
        switch self.rawValue {
        case .v1(let x): return check(arg: x, is: BoxPlotLiteral.self, value: .boxplot)
        case .v2(let x): return check(arg: x, is: ErrorBarLiteral.self, value: .errorbar)
        case .v3(let x): return check(arg: x, is: ErrorBandLiteral.self, value: .errorband)
        }
    }
}

public extension Aggregate.RawValue { // i.e., OneOf3<GGSpec.NonArgAggregateOp, GGSpec.ArgmaxDef, GGSpec.ArgminDef>

    /// Deprecated for clarity
    @available(*, deprecated, renamed: "simpleAggregate")
    var v1: T1? { simpleAggregate }

    /// The simple no-argument aggregate choice
    var simpleAggregate: NonArgAggregateOp? { infer() }
}

/// Standard shapes: https://vega.github.io/vega-lite/docs/point#properties
public extension SymbolShape {
    static let circle = Self("circle")
    static let square = Self("square")
    static let cross = Self("cross")
    static let diamond = Self("diamond")
    static let triangleUp = Self("triangle-up")
    static let triangleDown = Self("triangle-down")
    static let triangleRight = Self("triangle-right")
    static let triangleLeft = Self("triangle-left")
    
    static let stroke = Self("stroke")
    static let arrow = Self("arrow")
    static let wedge = Self("wedge")
    static let triangle = Self("triangle")

    /// Specifes a custom SVG path string
    ///
    /// - Note: For correct sizing, custom shape paths should be defined within a square bounding box with coordinates ranging from -1 to 1 along both the x and y dimensions.
    static func path(_ pathString: String) -> Self {
        Self(pathString)
    }
}

public extension NonArgAggregateOp {
    /// Additive-based aggregation operations. These can be applied to stack.
    static let summativeOps = Set<Self>(countingAggregateOps + [.sum])
    var isSummativeOp: Bool { Self.summativeOps.contains(self) }

    static let countingAggregateOps = Set<Self>([.count, .valid, .missing, .distinct])
    var isCountingAggregateOp: Bool { Self.countingAggregateOps.contains(self) }

    static let sharedDomainOps = Set<Self>([.mean, .average, .median, .q1, .q3, .min, .max])
    var isSharedDomainOp: Bool { Self.sharedDomainOps.contains(self) }

    static let minMaxOps = Set<Self>([.min, .max])
    var isMinMaxOp: Bool { Self.minMaxOps.contains(self) }
}

public extension Aggregate {
    var isSummativeOp: Bool { self.rawValue.simpleAggregate?.isSummativeOp == true }
    var isCountingAggregateOp: Bool { self.rawValue.simpleAggregate?.isCountingAggregateOp == true }
    var isSharedDomainOp: Bool { self.rawValue.simpleAggregate?.isSharedDomainOp == true }
    var isMinMaxOp: Bool { self.rawValue.simpleAggregate?.isMinMaxOp == true }

    init(_ op: NonArgAggregateOp) {
        self = Self(rawValue: oneOf(op))
    }

    /// Pass-through for `NonArgAggregateOp.distinct`
    static let distinct = Self(NonArgAggregateOp.distinct)

    /// Pass-through for `NonArgAggregateOp.distinct`
    static let count = Self(NonArgAggregateOp.count)
    /// Pass-through for `NonArgAggregateOp.distinct`
    static let valid = Self(NonArgAggregateOp.valid)
    /// Pass-through for `NonArgAggregateOp.distinct`
    static let missing = Self(NonArgAggregateOp.missing)

    /// Pass-through for `NonArgAggregateOp.distinct`
    static let min = Self(NonArgAggregateOp.min)
    /// Pass-through for `NonArgAggregateOp.distinct`
    static let max = Self(NonArgAggregateOp.max)
    /// Pass-through for `NonArgAggregateOp.distinct`
    static let mean = Self(NonArgAggregateOp.mean)
    /// Pass-through for `NonArgAggregateOp.distinct`
    static let sum = Self(NonArgAggregateOp.sum)
    /// Pass-through for `NonArgAggregateOp.distinct`
    static let average = Self(NonArgAggregateOp.average)
    /// Pass-through for `NonArgAggregateOp.distinct`
    static let median = Self(NonArgAggregateOp.median)

    /// Pass-through for `NonArgAggregateOp.distinct`
    static let stdev = Self(NonArgAggregateOp.stdev)
    /// Pass-through for `NonArgAggregateOp.distinct`
    static let stdevp = Self(NonArgAggregateOp.stdevp)
    /// Pass-through for `NonArgAggregateOp.distinct`
    static let variance = Self(NonArgAggregateOp.variance)
    /// Pass-through for `NonArgAggregateOp.distinct`
    static let variancep = Self(NonArgAggregateOp.variancep)
    /// Pass-through for `NonArgAggregateOp.distinct`
    static let stderr = Self(NonArgAggregateOp.stderr)

    /// Pass-through for `NonArgAggregateOp.distinct`
    static let q1 = Self(NonArgAggregateOp.q1)
    /// Pass-through for `NonArgAggregateOp.distinct`
    static let q3 = Self(NonArgAggregateOp.q3)
    /// Pass-through for `NonArgAggregateOp.distinct`
    static let ci0 = Self(NonArgAggregateOp.ci0)
    /// Pass-through for `NonArgAggregateOp.distinct`
    static let ci1 = Self(NonArgAggregateOp.ci1)

    /// Pass-through for `NonArgAggregateOp.distinct`
    static let values = Self(NonArgAggregateOp.values)
    /// Pass-through for `NonArgAggregateOp.distinct`
    static let product = Self(NonArgAggregateOp.product)
}

public extension UtcSingleTimeUnit {
    /// Returns the local version of this UTC time unit
    var localSingleTimeUnit: LocalSingleTimeUnit {
        switch self {
        case .utcyear: return .year
        case .utcquarter: return .quarter
        case .utcmonth: return .month
        case .utcday: return .day
        case .utcdate: return .date
        case .utchours: return .hours
        case .utcminutes: return .minutes
        case .utcseconds: return .seconds
        case .utcmilliseconds: return .milliseconds
        case .utcweek: return .week
        case .utcdayofyear: return .dayofyear
        }
    }
}

public extension LocalMultiTimeUnit {
    var singleTimeUnits: [LocalSingleTimeUnit] {
        switch self {
        case .yearquarter: return [.year, .quarter]
        case .yearquartermonth: return [.year, .quarter, .month]
        case .yearmonth: return [.year, .month]
        case .yearmonthdate: return [.year, .month, .date]
        case .yearmonthdatehours: return [.year, .month, .date, .hours]
        case .yearmonthdatehoursminutes: return [.year, .month, .date, .hours, .minutes]
        case .yearmonthdatehoursminutesseconds: return [.year, .month, .date, .hours, .minutes, .seconds]
        case .quartermonth: return [.quarter, .month]
        case .monthdate: return [.month, .date]
        case .monthdatehours: return [.month, .date, .hours]
        case .hoursminutes: return [.hours, .minutes]
        case .hoursminutesseconds: return [.hours, .minutes, .seconds]
        case .minutesseconds: return [.minutes, .seconds]
        case .secondsmilliseconds: return [.seconds, .milliseconds]
        case .yearweek: return [.year, .week]
        case .yearweekday: return [.year, .week, .day]
        case .yearweekdayhours: return [.year, .week, .day, .hours]
        case .yearweekdayhoursminutes: return [.year, .week, .day, .hours, .minutes]
        case .yearweekdayhoursminutesseconds: return [.year, .week, .day, .hours, .minutes, .seconds]
        case .yeardayofyear: return [.year, .dayofyear]
        case .monthdatehoursminutes: return [.month, .date, .hours, .minutes]
        case .monthdatehoursminutesseconds: return [.month, .date, .hours, .minutes, .seconds]
        case .weekday: return [.week, .day]
        case .weeksdayhours: return [.week, .day, .hours]
        case .weekdayhoursminutes: return [.week, .day, .hours, .minutes]
        case .weekdayhoursminutesseconds: return [.week, .day, .hours, .minutes, .seconds]
        case .dayhours: return [.day, .hours]
        case .dayhoursminutes: return [.day, .hours, .minutes]
        case .dayhoursminutesseconds: return [.day, .hours, .minutes, .seconds]
        }
    }
}

public extension UtcMultiTimeUnit {
    var singleTimeUnits: [UtcSingleTimeUnit] {
        switch self {
        case .utcyearquarter: return [.utcyear, .utcquarter]
        case .utcyearquartermonth: return [.utcyear, .utcquarter, .utcmonth]
        case .utcyearmonth: return [.utcyear, .utcmonth]
        case .utcyearmonthdate: return [.utcyear, .utcmonth, .utcdate]
        case .utcyearmonthdatehours: return [.utcyear, .utcmonth, .utcdate, .utchours]
        case .utcyearmonthdatehoursminutes: return [.utcyear, .utcmonth, .utcdate, .utchours, .utcminutes]
        case .utcyearmonthdatehoursminutesseconds: return [.utcyear, .utcmonth, .utcdate, .utchours, .utcminutes, .utcseconds]
        case .utcquartermonth: return [.utcquarter, .utcmonth]
        case .utcmonthdate: return [.utcmonth, .utcdate]
        case .utcmonthdatehours: return [.utcmonth, .utcdate, .utchours]
        case .utchoursminutes: return [.utchours, .utcminutes]
        case .utchoursminutesseconds: return [.utchours, .utcminutes, .utcseconds]
        case .utcminutesseconds: return [.utcminutes, .utcseconds]
        case .utcsecondsmilliseconds: return [.utcseconds, .utcmilliseconds]
        case .utcyearweek: return [.utcyear, .utcweek]
        case .utcyearweekday: return [.utcyear, .utcweek, .utcday]
        case .utcyearweekdayhours: return [.utcyear, .utcweek, .utcday, .utchours]
        case .utcyearweekdayhoursminutes: return [.utcyear, .utcweek, .utcday, .utchours, .utcminutes]
        case .utcyearweekdayhoursminutesseconds: return [.utcyear, .utcweek, .utcday, .utchours, .utcminutes, .utcseconds]
        case .utcyeardayofyear: return [.utcyear, .utcdayofyear]
        case .utcmonthdatehoursminutes: return [.utcmonth, .utcdate, .utchours, .utcminutes]
        case .utcmonthdatehoursminutesseconds: return [.utcmonth, .utcdate, .utchours, .utcminutes, .utcseconds]
        case .utcweekday: return [.utcweek, .utcday]
        case .utcweeksdayhours: return [.utcweek, .utcday, .utchours]
        case .utcweekdayhoursminutes: return [.utcweek, .utcday, .utchours, .utcminutes]
        case .utcweekdayhoursminutesseconds: return [.utcweek, .utcday, .utchours, .utcminutes, .utcseconds]
        case .utcdayhours: return [.utcday, .utchours]
        case .utcdayhoursminutes: return [.utcday, .utchours, .utcminutes]
        case .utcdayhoursminutesseconds: return [.utcday, .utchours, .utcminutes, .utcseconds]
        }
    }
}
