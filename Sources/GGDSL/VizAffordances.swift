import GGSchema

/// The direction of a repeating field
public typealias RepeatFacet = GG.RepeatRef.LiteralRowOrColumnOrRepeatOrLayer

/// The type of ancoding channel; x, y, shape, color, etc…
public typealias EncodingChannel = GG.EncodingChannelMap.CodingKeys

/// A VizSpec that stores its metadata as an unstructured JSON object.
public typealias SimpleVizSpec = VizSpec<Bric.ObjType>

/// The metadata associated with a `VizSpec`, which can be any `Pure` (`Hashable` + `Codable` + `Sendable`)  type.
public typealias VizSpecMeta = Pure

/// A source of data for a layer
public typealias VizDataSource = Nullable<GG.DataProvider> // e.g., TopLevelUnitSpec.DataChoice

/// A type that either be a static value (typically a number or string) or the result of a dynamic [expression](https://vega.github.io/vega/docs/expressions/).
public typealias Exprable<T> = OneOf<T>.Or<GG.ExprRef>


extension Pure {
    /// A simple no-op for synthesizing a keypath that goes nowhere
    subscript<T>(noop noop: Bool) -> T? {
        get { nil }
        set { } // no-po
    }
}

public extension GG.ExprRef {
    /// Construct this expression reference from a string
    init(_ expression: String) {
        self = .init(expr: GG.Expr(expression))
    }
}

// MARK: Layer Arrangement

/// The arrangement of sublayers in this `VizSpec`.
public enum LayerArrangement : CaseIterable, Hashable {
    case overlay
    case horizontal
    case vertical
    case wrap
}

public extension LayerArrangement {
    /// The repeat form of this arrangement
    var repeatRef: GG.RepeatRef {
        switch self {
        case .overlay:
            return GG.RepeatRef(repeat: .layer)
        case .horizontal:
            return GG.RepeatRef(repeat: .column)
        case .vertical:
            return GG.RepeatRef(repeat: .row)
        case .wrap:
            return GG.RepeatRef(repeat: .repeat)
        }
    }
}

public extension VizSpec {
    /// The arrangement of sub-layers of this spec, based on which sublayer property is set; this should only ever have at most one element
    @inlinable var arrangements: [LayerArrangement] {
        [
            self.layer != nil ? LayerArrangement.overlay : nil,
            self.concat != nil ? LayerArrangement.wrap : nil,
            self.hconcat != nil ? LayerArrangement.horizontal : nil,
            self.vconcat != nil ? LayerArrangement.vertical : nil,
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
    @inlinable var arrangement: LayerArrangement? {
        get {
            self.arrangements.first ?? .overlay // fallback to the overlay default
        }

        set {
            let subs = self.sublayers
            // make sure all other layers are cleared before assigning; both because it is invalid to have
            // more than one sublayer field, but also because this is how we calculate the `arrangement` field.
            (self.layer, self.concat, self.hconcat, self.vconcat) = (nil, nil, nil, nil)

            switch newValue {
            case .overlay: self.layer = subs
            case .horizontal: self.hconcat = subs
            case .vertical: self.vconcat = subs
            case .wrap: self.concat = subs
            case .none: break; // no change

            //case .repeat: self.spec = subs.first.flatMap({ .init($0) }) // we drop all but the first element here
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
            (self.layer, self.concat, self.hconcat, self.vconcat) = (nil, nil, nil, nil)
            if subs.isEmpty { return } // clear out all sublayers
            switch arrangement {
            case .overlay: self.layer = subs
            case .wrap: self.concat = subs
            case .horizontal: self.hconcat = subs
            case .vertical: self.vconcat = subs
            case .none: break
            //case .repeat: self.spec = subs.first.flatMap({ .init($0) }) // repeat can only be a single element
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
            case .none: return 1
            case .overlay: return nil
            case .horizontal: return nil
            case .vertical: return nil
            case .wrap: return nil
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

extension GG.AnyMark : Compactable {
    /// Returns a simplified version of this mark, replacing an empty `MarkDef` with the symbolic constant for the mark. This can be useful when it is important to generate minimal versions of the spec.
    ///
    /// For example, this will convert `{ "mark": { "type": "line" } }` into `{ "mark": "line" }`.
    public var compactRepresentation: GG.AnyMark {
        switch rawValue {
        case .v1, .v3: // already tidy
            return self
        case .v2(let def):
            switch def.type.rawValue {
            case .v1(let type):
                return def == GG.CompositeMarkDef(.init(type: type)) ? .init(def.type) : self
            case .v2(let type):
                return def == GG.CompositeMarkDef(.init(type: type)) ? .init(def.type) : self
            case .v3(let type):
                return def == GG.CompositeMarkDef(.init(type: type)) ? .init(def.type) : self
            }
        case .v4(let def):
            return def == GG.MarkDef(type: def.type) ? .init(def.type) : self
        }
    }
}

/// Internal choice for a differnet mark type; used internally by `MarkType`
public typealias MarkChoice = OneOf<GG.PrimitiveMarkType>.Or<GG.CompositeMark>

/// An `AnyMarkDef` is a compound enumeration of the different mark types
/// This is the complex enum part of:
/// `AnyMark = OneOf4<CompositeMark, CompositeMarkDef, Mark, MarkDef>`
public typealias AnyMarkDef = OneOf<GG.MarkDef>.Or<GG.CompositeMarkDef>

extension AnyMarkDef {
    public var markChoice: MarkChoice {
        switch self {
        case .v1(let x): return .init(x.type)
        case .v2(let x): return .init(x.type)
        }
    }
}

public extension GG.CompositeMarkDef {
    /// Returns the `CompositeMark` type of this mark type
    var type: GG.CompositeMark {
        switch rawValue {
        case .v1(let x): return .init(.init(x.type))
        case .v2(let x): return .init(.init(x.type))
        case .v3(let x): return .init(.init(x.type))
        }
    }
}

public extension GG.MarkDef {
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

public extension GG.PrimitiveMarkType {
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

public extension GG.CompositeMark { // i.e., OneOf3<BoxPlot, ErrorBar, ErrorBand>
    static let boxplot = Self(.init(.boxplot))
    static let errorbar = Self(.init(.errorbar))
    static let errorband = Self(.init(.errorband))


    var markType: MarkType {
        func check<T, U>(arg typeValue: T, is type: T.Type, value: U) -> U {
            value
        }
        switch self.rawValue {
        case .v1(let x): return check(arg: x, is: GG.BoxPlotLiteral.self, value: .boxplot)
        case .v2(let x): return check(arg: x, is: GG.ErrorBarLiteral.self, value: .errorbar)
        case .v3(let x): return check(arg: x, is: GG.ErrorBandLiteral.self, value: .errorband)
        }
    }
}

public extension GG.Aggregate.RawValue { // i.e., OneOf3<GGSchema.NonArgAggregateOp, GGSchema.ArgmaxDef, GGSchema.ArgminDef>

    /// Deprecated for clarity
    @available(*, deprecated, renamed: "simpleAggregate")
    var v1: T1? { simpleAggregate }

    /// The simple no-argument aggregate choice
    var simpleAggregate: GG.NonArgAggregateOp? { infer() }
}

/// Standard shapes: https://vega.github.io/vega-lite/docs/point#properties
public extension GG.SymbolShape {
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


// MARK: Transforms

public enum TransformType: String, CaseIterable, Hashable {

    // MARK: Subsets

    /// The filter transform removes objects from a data stream based on a provided filter expression or filter object.
    case filter
    /// The sample transform filters random rows from the data source to reduce its size. As input data objects are added and removed, the sampled values may change in first-in, first-out manner. This transform uses reservoir sampling to maintain a representative sample of the stream.
    case sample

    // MARK: Expanded Values

    /// The formula transform extends data objects with new fields (columns) according to an expression.
    case calculate
    /// The lookup transform extends a primary data source by looking up values from another data source. It is similar to a one sided join.
    case lookup


    // MARK: Transform

    /// Aggregate summarizes a table as one record for each group. To preserve the original table structure and instead add a new column with the aggregate values, use the join aggregate transform.
    case aggregate // groupby
    /// The joinaggregate transform extends the input data objects with aggregate values in a new field. Aggregation is performed and the results are then joined with the input data. This transform can be helpful for creating derived values that combine both raw data and aggregate calculations, such as percentages of group totals. This transform is a special case of the window transform where the frame is always [null, null]. Compared with the regular aggregate transform, joinaggregate preserves the original table structure and augments records with aggregate values rather than summarizing the data in one record for each group.
    case joinaggregate // groupby
    /// The window transform performs calculations over sorted groups of data objects. These calculations including ranking, lead/lag analysis, and aggregates such as running sums and averages. Calculated values are written back to the input data stream. If you only want to set the same aggregated value in a new field, you can use the simpler join aggregate transform.
    case window // groupby
    /// The impute transform groups data and determines missing values of the key field within each group. For each missing value in each group, the impute transform will produce a new tuple with the imputed field generated based on a specified imputation method (by using a constant value or by calculating statistics such as mean within each group).
    case impute // groupby

    // MARK: Derive New Stream

    /// The flatten transform maps array-valued fields to a set of individual data objects, one per array entry. This transform generates a new data stream in which each data object consists of an extracted array value as well as all the original fields of the corresponding input data object.
    case flatten
    /// The fold transform collapses (or “folds”) one or more data fields into two properties: a key property (containing the original data field name) and a value property (containing the data value). The fold transform is useful for mapping matrix or cross-tabulation data into a standardized format.
    case fold
    /// The pivot transform maps unique values from a field to new aggregated fields (columns) in the output stream. The transform requires both a field to pivot on (providing new field names) and a field of values to aggregate to populate the new cells. In addition, any number of groupby fields can be provided to further subdivide the data into output data objects (rows).
    case pivot // groupby

    /// The regression transform fits two-dimensional regression models to smooth and predict data. This transform can fit multiple models for input data (one per group) and generates new data objects that represent points for summary trend lines. Alternatively, this transform can be used to generate a set of objects containing regression model parameters, one per group.
    case regression // groupby
    /// The loess transform (for locally-estimated scatterplot smoothing) uses locally-estimated regression to produce a trend line. Loess performs a sequence of local weighted regressions over a sliding window of nearest-neighbor points. For standard parametric regression options, see the regression transform.
    case loess // groupby

    /// The density transform performs one-dimensional kernel density estimation over an input data stream and generates a new data stream of samples of the estimated densities.
    case density // groupby
    /// The quantile transform calculates empirical quantile values for an input data stream. If a groupby parameter is provided, quantiles are estimated separately per group. Among other uses, the quantile transform is useful for creating quantile-quantile (Q-Q) plots.
    case quantile // groupby

    // these transforms are also handled more simply by built-in features of the encoding channels

    /// Binning discretizes numeric values into a set of bins. A common use case is to create a histogram.
    case bin
    /// Time unit is used to discretize times.
    case timeUnit
    /// The stack property of a position field definition determines type of stacking offset if the field should be stacked.
    case stack // groupby
}


public extension GG.DataTransformation {
    var transformType: TransformType {
        /// merely validates that the given transform param has a name that matches our TransformType constant
        func disc<T>(_ ignore: T, _ value: TransformType) -> TransformType { value }

        switch self {
        case .aggregateTransformCase(let t): return disc(t.aggregate, .aggregate)
        case .binTransformCase(let t): return disc(t.bin, .bin)
        case .calculateTransformCase(let t): return disc(t.calculate, .calculate)
        case .densityTransformCase(let t): return disc(t.density, .density)
        case .filterTransformCase(let t): return disc(t.filter, .filter)
        case .flattenTransformCase(let t): return disc(t.flatten, .flatten)
        case .foldTransformCase(let t): return disc(t.fold, .fold)
        case .imputeTransformCase(let t): return disc(t.impute, .impute)
        case .joinAggregateTransformCase(let t): return disc(t.joinaggregate, .joinaggregate)
        case .loessTransformCase(let t): return disc(t.loess, .loess)
        case .lookupTransformCase(let t): return disc(t.lookup, .lookup)
        case .regressionTransformCase(let t): return disc(t.regression, .regression)
        case .timeUnitTransformCase(let t): return disc(t.timeUnit, .timeUnit)
        case .sampleTransformCase(let t): return disc(t.sample, .sample)
        case .stackTransformCase(let t): return disc(t.stack, .stack)
        case .windowTransformCase(let t): return disc(t.window, .window)
        case .pivotTransformCase(let t): return disc(t.pivot, .pivot)
        case .quantileTransformCase(let t): return disc(t.quantile, .quantile)
        }
    }
}

public extension GG.NonArgAggregateOp {
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

public extension GG.Aggregate {
    var isSummativeOp: Bool { self.rawValue.simpleAggregate?.isSummativeOp == true }
    var isCountingAggregateOp: Bool { self.rawValue.simpleAggregate?.isCountingAggregateOp == true }
    var isSharedDomainOp: Bool { self.rawValue.simpleAggregate?.isSharedDomainOp == true }
    var isMinMaxOp: Bool { self.rawValue.simpleAggregate?.isMinMaxOp == true }

    init(_ op: GG.NonArgAggregateOp) {
        self = Self(rawValue: oneOf(op))
    }

    /// Pass-through for `NonArgAggregateOp.distinct`
    static let distinct = Self(GG.NonArgAggregateOp.distinct)

    /// Pass-through for `NonArgAggregateOp.distinct`
    static let count = Self(GG.NonArgAggregateOp.count)
    /// Pass-through for `NonArgAggregateOp.distinct`
    static let valid = Self(GG.NonArgAggregateOp.valid)
    /// Pass-through for `NonArgAggregateOp.distinct`
    static let missing = Self(GG.NonArgAggregateOp.missing)

    /// Pass-through for `NonArgAggregateOp.distinct`
    static let min = Self(GG.NonArgAggregateOp.min)
    /// Pass-through for `NonArgAggregateOp.distinct`
    static let max = Self(GG.NonArgAggregateOp.max)
    /// Pass-through for `NonArgAggregateOp.distinct`
    static let mean = Self(GG.NonArgAggregateOp.mean)
    /// Pass-through for `NonArgAggregateOp.distinct`
    static let sum = Self(GG.NonArgAggregateOp.sum)
    /// Pass-through for `NonArgAggregateOp.distinct`
    static let average = Self(GG.NonArgAggregateOp.average)
    /// Pass-through for `NonArgAggregateOp.distinct`
    static let median = Self(GG.NonArgAggregateOp.median)

    /// Pass-through for `NonArgAggregateOp.distinct`
    static let stdev = Self(GG.NonArgAggregateOp.stdev)
    /// Pass-through for `NonArgAggregateOp.distinct`
    static let stdevp = Self(GG.NonArgAggregateOp.stdevp)
    /// Pass-through for `NonArgAggregateOp.distinct`
    static let variance = Self(GG.NonArgAggregateOp.variance)
    /// Pass-through for `NonArgAggregateOp.distinct`
    static let variancep = Self(GG.NonArgAggregateOp.variancep)
    /// Pass-through for `NonArgAggregateOp.distinct`
    static let stderr = Self(GG.NonArgAggregateOp.stderr)

    /// Pass-through for `NonArgAggregateOp.distinct`
    static let q1 = Self(GG.NonArgAggregateOp.q1)
    /// Pass-through for `NonArgAggregateOp.distinct`
    static let q3 = Self(GG.NonArgAggregateOp.q3)
    /// Pass-through for `NonArgAggregateOp.distinct`
    static let ci0 = Self(GG.NonArgAggregateOp.ci0)
    /// Pass-through for `NonArgAggregateOp.distinct`
    static let ci1 = Self(GG.NonArgAggregateOp.ci1)

    /// Pass-through for `NonArgAggregateOp.distinct`
    static let values = Self(GG.NonArgAggregateOp.values)
    /// Pass-through for `NonArgAggregateOp.distinct`
    static let product = Self(GG.NonArgAggregateOp.product)

    static func argmax(_ field: FieldNameRepresentable) -> Self {
        Self(GG.ArgmaxDef(argmax: field.fieldName))
    }

    static func argmin(_ field: FieldNameRepresentable) -> Self {
        Self(GG.ArgminDef(argmin: field.fieldName))
    }
}

public extension GG.UtcSingleTimeUnit {
    /// Returns the local version of this UTC time unit
    var localSingleTimeUnit: GG.LocalSingleTimeUnit {
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

public extension GG.LocalMultiTimeUnit {
    var singleTimeUnits: [GG.LocalSingleTimeUnit] {
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

public extension GG.UtcMultiTimeUnit {
    var singleTimeUnits: [GG.UtcSingleTimeUnit] {
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






#if canImport(TabularData)
import TabularData

@available(macOS 12.0, iOS 15.0, *)
extension AnyColumnProtocol {
    /// Returns a `Field` form of this column
    public var fieldName: FieldName { .init(FieldName(name)) }
}

@available(macOS 12.0, iOS 15.0, *)
extension ColumnProtocol {
    /// Returns a `Field` form of this column
    public var fieldName: FieldName { .init(FieldName(name)) }
}

@available(macOS 12.0, iOS 15.0, *)
extension TabularData.AnyColumn : FieldNameRepresentable { }
@available(macOS 12.0, iOS 15.0, *)
extension TabularData.AnyColumnSlice : FieldNameRepresentable { }
@available(macOS 12.0, iOS 15.0, *)
extension TabularData.Column : FieldNameRepresentable { }
@available(macOS 12.0, iOS 15.0, *)
extension TabularData.ColumnSlice : FieldNameRepresentable { }
@available(macOS 12.0, iOS 15.0, *)
extension TabularData.DiscontiguousColumnSlice : FieldNameRepresentable { }
@available(macOS 12.0, iOS 15.0, *)
extension TabularData.FilledColumn : FieldNameRepresentable { }

#endif



