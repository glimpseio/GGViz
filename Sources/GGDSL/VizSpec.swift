import GGSpec

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

public protocol SpecType : Codable {
    var name: String? { get set }
    var description: String? { get set }
//    var title: OneOf2<String, TitleParams>? { get set }
    /// The list of transforms applied to this layer's data
    var transform: [Transform]? { get set }
}


public protocol TopLevelSpecType : SpecType {
    var schema: String? { get set }
    var config: Config? { get set }
    //var usermeta: Dict? { get set }
}

/// A `ColorCode` or an `ExprRef`
public typealias ColorExprable = Exprable<ColorCode>


/// The different options for a `Param` definition
public typealias ParamChoice = OneOf<VariableParameter>.Or<TopLevelSelectionParameter> // Config.ParamsItemChoice

/// A visualization specification with generic metadata.
///
/// Subsumes the following built-in spec types:
/// * `Spec = OneOf7<FacetedUnitSpec, LayerSpec, RepeatSpec, FacetSpec, ConcatSpecGenericSpec, VConcatSpecGenericSpec, HConcatSpecGenericSpec>`
/// * `TopLevelSpec = OneOf7<TopLevelUnitSpec, TopLevelFacetSpec, TopLevelLayerSpec, TopLevelRepeatSpec, TopLevelNormalizedConcatSpecGenericSpec, TopLevelNormalizedVConcatSpecGenericSpec, TopLevelNormalizedHConcatSpecGenericSpec>`
public struct VizSpec<Meta: VizSpecMeta> : Pure, Hashable, Codable, TopLevelSpecType, SpecType, Identifiable {
    /// The type of child specs this type may contain (i.e., Self)
    public typealias SubSpec = VizSpec<Meta>

    /// The unique identifier of this spec
    public var id: LayerId?

    /// URL to [JSON schema](http://json-schema.org/) for a Vega-Lite specification. Unless you have a reason to change this, use `https://vega.github.io/schema/vega-lite/v4.json`. Setting the `$schema` property allows automatic validation and autocomplete in editors that support JSON schema.
    public var schema: String?

    // MARK: Common Properties
    // https://vega.github.io/vega-lite/docs/spec#common

    /// Name of the visualization for later reference. Note that this must be a unique name throughout the spec.
    public var name: String?

    /// Description of this mark for commenting purpose.
    public var description: String?

    /// Title for the plot.
    public var title: TitleChoice?

    /// An object describing the data source
    public var data: VizDataSource? // i.e., Nullable<DataProvider>

    /// An array of data transformations such as filter and new field calculation.
    public var transform: [Transform]?

    /// Scale, axis, and legend resolutions for view composition specifications.
    public var resolve: Resolve?

    // MARK: Top-Level Specifications
    // https://vega.github.io/vega-lite/docs/spec#top-level

    /// A global data store for named datasets. This is a mapping from names to inline datasets.
    /// This can be an array of objects or primitive values or a string. Arrays of primitive values are ingested as objects with a `data` property.
    public var datasets: Datasets?

    /// CSS color property to use as the background of the entire view.
    public var background: ColorExprable?

    /// The default visualization padding, in pixels, from the edge of the visualization canvas to the data rectangle.  If a number, specifies padding for all sides.
    /// If an object, the value should have the format `{"left": 5, "top": 5, "right": 5, "bottom": 5}` to specify padding for each side of the visualization.
    /// __Default value__: `5`
    public var padding: Padding?

    /// Sets how the visualization size should be determined. If a string, should be one of `"pad"`, `"fit"` or `"none"`.
    /// Object values can additionally specify parameters for content sizing and automatic resizing.
    /// `"fit"` is only supported for single and layered views that don't use `rangeStep`.
    /// __Default value__: `pad`
    public var autosize: AutosizeChoice?

    /// Dynamic variables that parameterize a visualization.
    public var params: [ParamChoice]? // [OneOf<VariableParameter>.Or<TopLevelSelectionParameter>]

    /// Vega-Lite configuration object.  This property can only be defined at the top-level of a specification.
    public var config: Config? {
        get { _config?.wrappedValue }
        _modify {
            var cfg = _config?.wrappedValue
            yield &cfg
            _config = cfg.indirect()
        }
    }

    /// Storing `Config` as an indirect reduces the potential memory layout size, but more importantly, it seems to work around a crash on encoding that we were seeing
    private var _config: Indirect<Config>?

    /// Optional metadata that will be passed to Vega.
    /// This object is completely ignored by Vega and Vega-Lite and can be used for custom metadata.
    public var usermeta: Meta?



    // MARK: Composition Properties

    /// The alignment to apply to grid rows and columns.
    /// The supported string values are `"all"`, `"each"`, and `"none"`.
    /// - For `"none"`, a flow layout will be used, in which adjacent subviews are simply placed one after the other.
    /// - For `"each"`, subviews will be aligned into a clean grid structure, but each row or column may be of variable size.
    /// - For `"all"`, subviews will be aligned and each row or column will be sized identically based on the maximum observed size. String values for this property will be applied to both grid rows and columns.
    /// Alternatively, an object value of the form `{"row": string, "column": string}` can be used to supply different alignments for rows and columns.
    /// __Default value:__ `"all"`.
    public var align: AlignChoice?
    public typealias AlignChoice = FacetEncodingFieldDef.AlignChoice

    /// The bounds calculation method to use for determining the extent of a sub-plot. One of `full` (the default) or `flush`.
    /// - If set to `full`, the entire calculated bounds (including axes, title, and legend) will be used.
    /// - If set to `flush`, only the specified width and height values for the sub-view will be used. The `flush` setting can be useful when attempting to place sub-plots without axes or legends into a uniform grid structure.
    /// __Default value:__ `"full"`
    public var bounds: LiteralFullOrFlush?

    /// Boolean flag indicating if subviews should be centered relative to their respective rows or columns.
    /// An object value of the form `{"row": boolean, "column": boolean}` can be used to supply different centering values for rows and columns.
    /// __Default value:__ `false`
    public var center: CenterChoice?
    public typealias CenterChoice = FacetEncodingFieldDef.CenterChoice

    /// The spacing in pixels between sub-views of the composition operator.
    /// An object of the form `{"row": number, "column": number}` can be used to set
    /// different spacing values for rows and columns.
    /// __Default value__: Depends on `"spacing"` property of [the view composition configuration](https://vega.github.io/vega-lite/docs/config#view-config) (`20` by default)
    public var spacing: SpacingChoice?
    public typealias SpacingChoice = FacetEncodingFieldDef.SpacingChoice


    // MARK: Single View Properties
    // https://vega.github.io/vega-lite/docs/spec#single

    /// A string describing the mark type (one of `"bar"`, `"circle"`, `"square"`, `"tick"`, `"line"`,
    /// `"area"`, `"point"`, `"rule"`, `"geoshape"`, and `"text"`) or a [mark definition object](https://vega.github.io/vega-lite/docs/mark#mark-def).
    public var mark: AnyMark?

    /// A key-value mapping between encoding channels and definition of fields.
    /// This property can only be defined at the top-level of a specification.
    public var encoding: FacetedEncoding? {
        get { _encoding?.wrappedValue }
        _modify {
            var cfg = _encoding?.wrappedValue
            yield &cfg
            _encoding = cfg.indirect()
        }
    }

    /// Storing `encoding` as an indirect reduces the potential memory layout size so it can load on background queues (with a 512KB stack limit)
    private var _encoding: Indirect<FacetedEncoding>?

    public var width: TopLevelUnitSpec.WidthChoice?
    public var height: TopLevelUnitSpec.HeightChoice?

    /// An object defining the view background's fill and stroke.
    /// __Default value:__ none (transparent)
    public var view: ViewBackground?

    /// An object defining properties of geographic projection, which will be applied to `shape` path for `"geoshape"` marks
    /// and to `latitude` and `"longitude"` channels for other marks.
    public var projection: Projection?




    /// The number of columns to include in the view composition layout.
    /// __Default value__: `undefined` -- An infinite number of columns (a single row) will be assumed. This is equivalent to
    /// `hconcat` (for `concat`) and to using the `column` channel (for `facet` and `repeat`).
    /// __Note__:
    /// 1) This property is only for:
    /// - the general (wrappable) `concat` operator (not `hconcat`/`vconcat`)
    /// - the `facet` and `repeat` operator with one field/repetition definition (without row/column nesting)
    /// 2) Setting the `columns` to `1` is equivalent to `vconcat` (for `concat`) and to using the `row` channel (for `facet` and `repeat`).
    public var columns: Double?


    // Manually added fields follow:

    /// An object that describes mappings between `row` and `column` channels and their field definitions.
    public var facet: FacetChoice?

    /// An object that describes what fields should be repeated into views that are laid out as a `row` or `column`.
    public var `repeat`: RepeatChoice? // RepeatSpec

    /// A specification of the view that gets faceted.
    public var spec: Indirect<SubSpec>? // RepeatSpec

    public var concat: [SubSpec]? // ConcatSpec

    /// Layer or single view specifications to be layered.
    /// __Note__: Specifications inside `layer` cannot use `row` and `column` channels as layering facet specifications is not allowed.
    public var layer: [SubSpec]? // LayerSpec

    /// A list of views that should be concatenated and put into a column.
    public var vconcat: [SubSpec]? // VConcatSpec

    /// A list of views that should be concatenated and put into a row.
    public var hconcat: [SubSpec]? // HConcatSpec


    public init(id: LayerId? = .none, schema: String? = .none, align: AlignChoice? = .none, autosize: AutosizeChoice? = .none, background: ColorExprable? = .none, bounds: LiteralFullOrFlush? = .none, center: CenterChoice? = .none, columns: Double? = .none, config: Config? = .none, data: VizDataSource? = .none, datasets: Datasets? = .none, description: String? = .none, encoding: FacetedEncoding? = .none, height: TopLevelUnitSpec.HeightChoice? = .none, mark: AnyMark? = .none, name: String? = .none, padding: Padding? = .none, projection: Projection? = .none, resolve: Resolve? = .none, spacing: SpacingChoice? = .none, title: TitleChoice? = .none, transform: [Transform]? = .none, params: [ParamChoice]? = .none, usermeta: Meta? = .none, view: ViewBackground? = .none, width: TopLevelUnitSpec.WidthChoice? = .none,
                concat: [SubSpec]? = .none, facet: FacetChoice? = .none, layer: [SubSpec]? = .none, `repeat`: RepeatChoice? = .none, spec: SubSpec? = .none, vconcat: [SubSpec]? = .none, hconcat: [SubSpec]? = .none) {
        self.id = id
        self.schema = schema
        self.align = align
        self.autosize = autosize
        self.background = background
        self.bounds = bounds
        self.center = center
        self.columns = columns
        self.config = config
        self.data = data
        self.datasets = datasets
        self.description = description
        self.encoding = encoding
        self.height = height
        self.mark = mark
        self.name = name
        self.padding = padding
        self.projection = projection
        self.resolve = resolve
        self.spacing = spacing
        self.title = title
        self.transform = transform
        self.params = params
        self.usermeta = usermeta
        self.view = view
        self.width = width

        self.concat = concat
        self.facet = facet
        self.layer = layer
        self.`repeat` = `repeat`
        self.spec = spec.indirect()
        self.vconcat = vconcat
        self.hconcat = hconcat
    }


    /// Sets how the visualization size should be determined. If a string, should be one of `"pad"`, `"fit"` or `"none"`.
    /// Object values can additionally specify parameters for content sizing and automatic resizing.
    /// `"fit"` is only supported for single and layered views that don't use `rangeStep`.
    /// __Default value__: `pad`
    public typealias AutosizeChoice = TopLevelUnitSpec.AutosizeChoice

    /// Title for the plot.
    public typealias TitleChoice = TopLevelUnitSpec.TitleChoice

    public typealias FacetChoice = OneOf2<FacetFieldDef, FacetMapping>

    public typealias RepeatChoice = OneOf3<[FieldName], LayerRepeatMapping, RepeatMapping>


    /// The `CodingKeys` for the spec. These are in the order we will see in the JSON result of `JSONEncoder.encodeOrdered` due to conformance to `OrderedCodingKey`.
    public enum CodingKeys : String, CodingKey, Pure, Hashable, Codable, CaseIterable, OrderedCodingKey {
        case id

        case schema = "$schema"
        case name
        case title
        case description
        case mark

        case width
        case height

        case autosize

        case padding
        case bounds
        case align
        case center
        case spacing
        case columns

        case view
        case background
        case projection

        case data
        case transform

        case resolve

        case _encoding = "encoding"

        // keep the various sublayer options nearby

        case concat
        case facet
        case layer
        case `repeat`
        case spec
        case hconcat
        case vconcat

        case _config = "config"

        case params
        case usermeta

        case datasets // this should be last because it may contain a lot of data
    }
}


// MARK: Layer Arrangement


/// Child layers of this layer are arranged.
public enum LayerArrangement : String, CaseIterable, Codable, Hashable {
    case overlay
    case hconcat
    case vconcat
    case concat
    case `repeat`
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
