import GGSchema
import BricBrac

// A DSL for constructing a data visualization in Swift.

/// Work-in-progress, simply to highlight a line with a deprecation warning
@available(*, deprecated, message: "work-in-progress")
fileprivate func wip<T>(_ value: T) -> T { value }

/// Work-in-progress death, simply to highlight a line with a deprecation warning
@available(*, deprecated, message: "work-in-progress")
fileprivate func hole<T>(_ params: Any...) -> T { fatalError(wip("derp")) }


/// Issues a warning to the console that the existing encoding is being replaced
fileprivate func warnReplaceEncoding<C: VizEncodingChannelType>(_ instance: C) {
    print("warnReplaceEncoding: encoding for \(C.encodingChannel.rawValue) overrides existing definition")
}


/// Experimental typealiases for nicer DSL
public typealias Layer = VizLayer
/// Experimental typealiases for nicer DSL
public typealias Mark = VizMark
/// Experimental typealiases for nicer DSL
public typealias Transform = VizTransform
/// Experimental typealiases for nicer DSL
public typealias Encode = VizEncode
/// Experimental typealiases for nicer DSL
public typealias Scale = VizScale
/// Experimental typealiases for nicer DSL
public typealias Guide = VizGuide
/// Experimental typealiases for nicer DSL
public typealias Repeat = VizRepeat
/// Experimental typealiases for nicer DSL
public typealias Viewport = VizViewport
/// Experimental typealiases for nicer DSL
public typealias GeoProjection = VizGeoProjection


/// A type that can be used to create a field value
public protocol FieldNameRepresentable {
    /// The `GGSchema.Field` form of this specification
    var fieldName: GG.FieldName { get }
}

extension String : FieldNameRepresentable {
    public var fieldName: GG.FieldName { .init(self) }
}

extension GG.FieldName : FieldNameRepresentable {
    public var fieldName: GG.FieldName { self }
}


public protocol VizDSLType {
}

public protocol VizSpecBuilderType {
    /// Adds the builder information to the given layer
    func add<M: Pure>(to spec: inout VizSpec<M>)
}

public protocol VizSpecLayerType : VizSpecBuilderType {
}

//extension VizSpec : VizSpecLayerType {
//    public func add<M: Pure>(to spec: inout VizSpec<M>) {
//        spec = self
//    }
//}

/// A layered element that can hold marks
public protocol VizLayerElementType : VizSpecBuilderType {
}

/// A spec element that can hold marks and layers and encodings
public protocol VizSpecElementType : VizLayerElementType {
}

public protocol VizMarkType : VizSpecElementType {
    var encodings: GG.EncodingChannelMap { get }
}

public protocol VizMarkDefType : Pure {
    var anyMark: GG.AnyMark { get }
}

extension GG.MarkDef : VizMarkDefType {
    public var anyMark: GG.AnyMark { .init(self) }
}

extension GG.BoxPlotDef : VizMarkDefType {
    public var anyMark: GG.AnyMark { .init(.init(self)) }
}

extension GG.ErrorBarDef : VizMarkDefType {
    public var anyMark: GG.AnyMark { .init(.init(self)) }
}

extension GG.ErrorBandDef : VizMarkDefType {
    public var anyMark: GG.AnyMark { .init(.init(self)) }
}

public protocol VizTransformDefType : Pure {
    var anyTransform: GG.DataTransformation { get }
}

@dynamicMemberLookup
public struct VizTheme : VizSpecElementType, FluentContainer {
    public var rawValue: GG.ConfigTheme

    public init(rawValue: RawValue = .init()) { self.rawValue = rawValue }

    public func add<M>(to spec: inout VizSpec<M>) where M : Pure {
        spec.config = rawValue
    }
}



@dynamicMemberLookup
public struct VizGeoProjection : VizSpecElementType, FluentContainer, VizDSLType {
    public var rawValue: GG.Projection

    public init(rawValue projection: GG.Projection) {
        self.rawValue = projection
    }

    public init(_ type: GG.ProjectionType? = nil, projection: GG.Projection = GG.Projection()) {
        self.rawValue = projection
        if let type = type {
            self.rawValue.type = .init(.init(type))
        }
    }

    public func add<M>(to spec: inout VizSpec<M>) where M : Pure {
        spec.projection = rawValue
    }
}


@dynamicMemberLookup
public struct VizViewport : VizSpecElementType, FluentContainer, VizDSLType {
    public var rawValue: GG.ViewBackground

    public init(rawValue viewport: GG.ViewBackground) {
        self.rawValue = viewport
    }

    public init(viewport: GG.ViewBackground = GG.ViewBackground()) {
        self.rawValue = viewport
    }

    public func add<M>(to spec: inout VizSpec<M>) where M : Pure {
        spec.view = rawValue
    }
}


/// Literal data values to be included in a visualization
@dynamicMemberLookup
public struct DataValues : VizSpecElementType, FluentContainer, VizDSLType {
    public var rawValue: GG.InlineDataset

    public init(rawValue dataSet: GG.InlineDataset) {
        self.rawValue = dataSet
    }

    public init(values: () -> [Bric.ObjType]) {
        self.rawValue = .init(.init(values().map(Bric.init)))
    }

    public init(values: () -> [Double]) {
        self.rawValue = .init(.init(values()))
    }

    public init(values: () -> [String]) {
        self.rawValue = .init(.init(values()))
    }

    public init(values: () -> [Bool]) {
        self.rawValue = .init(.init(values()))
    }

    public func add<M>(to spec: inout VizSpec<M>) where M : Pure {
        spec.data = .init(GG.DataProvider(GG.DataSource(GG.InlineData(values: rawValue))))
    }
}

/// A reference to a give UR:L
@dynamicMemberLookup
public struct DataReference : VizSpecElementType, FluentContainer, VizDSLType {
    public var rawValue: GG.UrlData

    public init(rawValue urlReference: GG.UrlData) {
        self.rawValue = urlReference
    }

    public init(path url: String) {
        self.rawValue = .init(url: url)
    }

//    public init(url: URL) {
//        self.rawValue = .init(url: url.abslouteURL)
//    }

    public func add<M>(to spec: inout VizSpec<M>) where M : Pure {
        spec.data = .init(GG.DataProvider(GG.DataSource(rawValue)))
    }
}


// MARK: DataTransform


@dynamicMemberLookup
public struct VizTransform<Def : VizTransformDefType> : VizSpecElementType, VizTransformType, FluentContainer {
    public var rawValue: Def
    private let makeElements: () -> [VizLayerElementType]

    public func add<M>(to spec: inout VizSpec<M>) where M : Pure {
        spec.transform[defaulting: []].append(rawValue.anyTransform)
        for element in makeElements() {
            element.add(to: &spec)
        }
    }

    private func canaryTransformType(transformType: TransformType) {
        func check<T: VizTransformDefType>(_ transform: T.Type) {
        }

        switch transformType {
        case .filter:
            check(GG.FilterTransform.self)
        case .sample:
            check(GG.SampleTransform.self)
        case .calculate:
            check(GG.CalculateTransform.self)
        case .lookup:
            check(GG.LookupTransform.self)
        case .aggregate:
            check(GG.AggregateTransform.self)
        case .joinaggregate:
            check(GG.JoinAggregateTransform.self)
        case .window:
            check(GG.WindowTransform.self)
        case .impute:
            check(GG.ImputeTransform.self)
        case .flatten:
            check(GG.FlattenTransform.self)
        case .fold:
            check(GG.FoldTransform.self)
        case .pivot:
            check(GG.PivotTransform.self)
        case .regression:
            check(GG.RegressionTransform.self)
        case .loess:
            check(GG.LoessTransform.self)
        case .density:
            check(GG.DensityTransform.self)
        case .quantile:
            check(GG.QuantileTransform.self)
        case .bin:
            check(GG.BinTransform.self)
        case .timeUnit:
            check(GG.TimeUnitTransform.self)
        case .stack:
            check(GG.StackTransform.self)
        }
    }
}

// MARK: DataTransform: Sample

extension GG.SampleTransform : VizTransformDefType {
    public var anyTransform: GG.DataTransformation { .init(self) }
}

public extension VizTransform where Def == GG.SampleTransform {
    enum SampleLiteral {
        /// The sample transform filters random rows from the data source to reduce its size. As input data objects are added and removed, the sampled values may change in first-in, first-out manner. This transform uses reservoir sampling to maintain a representative sample of the stream.
        case sample
    }
    init(_ sampleTransform: SampleLiteral, sample: Double = 999, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.rawValue = GG.SampleTransform(sample: sample)
        self.makeElements = makeElements
    }
}

extension GG.AggregateTransform : VizTransformDefType {
    public var anyTransform: GG.DataTransformation { .init(self) }
}

public extension VizTransform where Def == GG.AggregateTransform {
    enum AggregateLiteral {
        /// Aggregate summarizes a table as one record for each group. To preserve the original table structure and instead add a new column with the aggregate values, use the join aggregate transform.
        case aggregate
    }
    init(_ aggregateTransform: AggregateLiteral, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.rawValue = GG.AggregateTransform() // GG.AggregateTransform(id: <#T##GG.TransformId?#>, aggregate: <#T##[GG.AggregatedFieldDef]#>, groupby: <#T##[GG.FieldName]?#>)
        self.makeElements = makeElements
    }
}

extension GG.BinTransform : VizTransformDefType {
    public var anyTransform: GG.DataTransformation { .init(self) }
}

public extension VizTransform where Def == GG.BinTransform {
    enum BinLiteral {
        /// Binning discretizes numeric values into a set of bins. A common use case is to create a histogram.
        case bin
    }
    init(_ binTransform: BinLiteral, params: GG.BinParams? = nil, field: FieldNameRepresentable, outputStart startField: FieldNameRepresentable, outputEnd endField: FieldNameRepresentable? = nil, @VizLayerElementArrayBuilder _ makeElements: @escaping (_ binStartField: FieldNameRepresentable, _ binEndField: FieldNameRepresentable) -> [VizLayerElementType]) {
        self.rawValue = GG.BinTransform(as: endField == nil ? .init(startField.fieldName) : .init([startField.fieldName, endField!.fieldName]), bin: params.map({ .init($0) }) ?? .init(true), field: field.fieldName)
        self.makeElements = { makeElements(startField, endField ?? GG.FieldName(startField.fieldName.rawValue + "_end")) }
    }
}

extension GG.CalculateTransform : VizTransformDefType {
    public var anyTransform: GG.DataTransformation { .init(self) }
}

public extension VizTransform where Def == GG.CalculateTransform {
    enum CalculateLiteral {
        /// The formula transform extends data objects with new fields (columns) according to an expression.
        case calculate
    }
    init(_ calculateTransform: CalculateLiteral, expression calculate: String, output calculateField: FieldNameRepresentable, @VizLayerElementArrayBuilder _ makeElements: @escaping (_ calculateField: FieldNameRepresentable) -> [VizLayerElementType]) {
        self.rawValue = GG.CalculateTransform(as: calculateField.fieldName, calculate: .init(calculate))
        self.makeElements = { makeElements(calculateField) }
    }
}

extension GG.DensityTransform : VizTransformDefType {
    public var anyTransform: GG.DataTransformation { .init(self) }
}

public extension VizTransform where Def == GG.DensityTransform {
    enum DensityLiteral {
        /// The density transform performs one-dimensional kernel density estimation over an input data stream and generates a new data stream of samples of the estimated densities.
        case density
    }
    init(_ densityTransform: DensityLiteral, field density: FieldNameRepresentable, group groupby: [FieldNameRepresentable]? = nil, bandwidth: Double? = nil, counts: Bool? = nil, cumulative: Bool? = nil, extent: [GG.DensityTransform.ExtentItem]? = nil, maxsteps: Double? = nil, minsteps: Double? = nil, steps: Double? = nil, sampleOutput: FieldNameRepresentable? = nil, densityOutput: FieldNameRepresentable? = nil, @VizLayerElementArrayBuilder _ makeElements: @escaping (_ sampleValueOutput: FieldNameRepresentable, _ densityEstimateOutput: FieldNameRepresentable) -> [VizLayerElementType]) {
        self.rawValue = GG.DensityTransform(as: sampleOutput == nil && densityOutput == nil ? nil : [(sampleOutput ?? "value").fieldName, (densityOutput ?? "density").fieldName], bandwidth: bandwidth, counts: counts, cumulative: cumulative, density: density.fieldName, extent: extent, groupby: groupby?.map(\.fieldName), maxsteps: maxsteps, minsteps: minsteps, steps: steps)
        // self.makeElements = { makeElements(self.transformDef.as?.first?.fieldName ?? "value", self.transformDef.as?.last?.fieldName ?? "density") }
        self.makeElements = { makeElements(sampleOutput ?? "value", densityOutput ?? "density") }
    }
}

extension GG.FilterTransform : VizTransformDefType {
    public var anyTransform: GG.DataTransformation { .init(self) }
}

public extension VizTransform where Def == GG.FilterTransform {
    enum FilterLiteral {
        /// The filter transform removes objects from a data stream based on a provided filter expression or filter object.
        case filter
    }

    init(_ filterTransform: FilterLiteral, filter: GG.PredicateComposition, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.rawValue = GG.FilterTransform(filter: filter)
        self.makeElements = makeElements
    }

    init(_ filterTransform: FilterLiteral, expression: String, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.init(filterTransform, filter: .init(.init(expression)), makeElements)
    }

}

extension GG.FlattenTransform : VizTransformDefType {
    public var anyTransform: GG.DataTransformation { .init(self) }
}

public extension VizTransform where Def == GG.FlattenTransform {
    enum FlattenLiteral {
        /// The flatten transform maps array-valued fields to a set of individual data objects, one per array entry. This transform generates a new data stream in which each data object consists of an extracted array value as well as all the original fields of the corresponding input data object.
        case flatten
    }
    init(_ flattenTransform: FlattenLiteral, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.rawValue = GG.FlattenTransform() // GG.FlattenTransform(id: <#T##GG.TransformId?#>, as: <#T##[GG.FieldName]?#>, flatten: <#T##[GG.FieldName]#>)
        self.makeElements = makeElements
    }
}

extension GG.FoldTransform : VizTransformDefType {
    public var anyTransform: GG.DataTransformation { .init(self) }
}

public extension VizTransform where Def == GG.FoldTransform {
    enum FoldLiteral {
        /// The fold transform collapses (or ???folds???) one or more data fields into two properties: a key property (containing the original data field name) and a value property (containing the data value). The fold transform is useful for mapping matrix or cross-tabulation data into a standardized format.
        case fold
    }
    init(_ foldTransform: FoldLiteral, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.rawValue = GG.FoldTransform() // GG.FoldTransform(id: <#T##GG.TransformId?#>, as: <#T##[GG.FieldName]?#>, fold: <#T##[GG.FieldName]#>)
        self.makeElements = makeElements
    }
}

extension GG.ImputeTransform : VizTransformDefType {
    public var anyTransform: GG.DataTransformation { .init(self) }
}

public extension VizTransform where Def == GG.ImputeTransform {
    enum ImputeLiteral {
        /// The impute transform groups data and determines missing values of the key field within each group. For each missing value in each group, the impute transform will produce a new tuple with the imputed field generated based on a specified imputation method (by using a constant value or by calculating statistics such as mean within each group).
        case impute
    }
    init(_ imputeTransform: ImputeLiteral, impute: FieldNameRepresentable, key: FieldNameRepresentable, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.rawValue = GG.ImputeTransform(impute: impute.fieldName, key: key.fieldName) // GG.ImputeTransform(id: <#T##GG.TransformId?#>, frame: <#T##[GG.ImputeTransform.FrameItemChoice]?#>, groupby: <#T##[GG.FieldName]?#>, impute: <#T##GG.FieldName#>, key: <#T##GG.FieldName#>, keyvals: <#T##GG.ImputeTransform.KeyvalsChoice?#>, method: <#T##GG.ImputeMethod?#>, value: <#T##GG.ImputeTransform.Value?#>)
        self.makeElements = makeElements
    }
}

extension GG.JoinAggregateTransform : VizTransformDefType {
    public var anyTransform: GG.DataTransformation { .init(self) }
}

public extension VizTransform where Def == GG.JoinAggregateTransform {
    enum JoinAggregateLiteral {
        /// The joinaggregate transform extends the input data objects with aggregate values in a new field. Aggregation is performed and the results are then joined with the input data. This transform can be helpful for creating derived values that combine both raw data and aggregate calculations, such as percentages of group totals. This transform is a special case of the window transform where the frame is always [null, null]. Compared with the regular aggregate transform, joinaggregate preserves the original table structure and augments records with aggregate values rather than summarizing the data in one record for each group.
        case joinAggregate
    }
    init(_ joinAggregateTransform: JoinAggregateLiteral, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.rawValue = GG.JoinAggregateTransform() // GG.JoinAggregateTransform(id: <#T##GG.TransformId?#>, groupby: <#T##[GG.FieldName]?#>, joinaggregate: <#T##[GG.JoinAggregateFieldDef]#>)
        self.makeElements = makeElements
    }
}

extension GG.LoessTransform : VizTransformDefType {
    public var anyTransform: GG.DataTransformation { .init(self) }
}

public extension VizTransform where Def == GG.LoessTransform {
    enum LoessLiteral {
        /// The loess transform (for locally-estimated scatterplot smoothing) uses locally-estimated regression to produce a trend line. Loess performs a sequence of local weighted regressions over a sliding window of nearest-neighbor points. For standard parametric regression options, see the regression transform.
        case loess
    }
    init(_ loessTransform: LoessLiteral, field: FieldNameRepresentable, on: FieldNameRepresentable, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.rawValue = GG.LoessTransform(loess: field.fieldName, on: on.fieldName) // GG.LoessTransform(id: <#T##GG.TransformId?#>, as: <#T##[GG.FieldName]?#>, bandwidth: <#T##Double?#>, groupby: <#T##[GG.FieldName]?#>, loess: <#T##GG.FieldName#>, on: <#T##GG.FieldName#>)
        self.makeElements = makeElements
    }
}

extension GG.LookupTransform : VizTransformDefType {
    public var anyTransform: GG.DataTransformation { .init(self) }
}

public extension VizTransform where Def == GG.LookupTransform {
    enum LookupLiteral {
        /// The lookup transform extends a primary data source by looking up values from another data source. It is similar to a one sided join.
        case lookup
    }
    init(_ lookupTransform: LookupLiteral, field: FieldNameRepresentable, data: GG.LookupData, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.rawValue = GG.LookupTransform(from: .init(data), lookup: field.fieldName) // GG.LookupTransform(id: <#T##GG.TransformId?#>, as: <#T##GG.LookupTransform.AsChoice?#>, default: <#T##Bric?#>, from: <#T##GG.LookupTransform.FromChoice#>, lookup: <#T##GG.FieldName#>)
        self.makeElements = makeElements
    }

    init(_ lookupTransform: LookupLiteral, field: FieldNameRepresentable, selection: GG.LookupSelection, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.rawValue = GG.LookupTransform(from: .init(selection), lookup: field.fieldName) // GG.LookupTransform(id: <#T##GG.TransformId?#>, as: <#T##GG.LookupTransform.AsChoice?#>, default: <#T##Bric?#>, from: <#T##GG.LookupTransform.FromChoice#>, lookup: <#T##GG.FieldName#>)
        self.makeElements = makeElements
    }
}

extension GG.QuantileTransform : VizTransformDefType {
    public var anyTransform: GG.DataTransformation { .init(self) }
}

public extension VizTransform where Def == GG.QuantileTransform {
    enum QuantileLiteral {
        /// The quantile transform calculates empirical quantile values for an input data stream. If a groupby parameter is provided, quantiles are estimated separately per group. Among other uses, the quantile transform is useful for creating quantile-quantile (Q-Q) plots.
        case quantile
    }
    init(_ quantileTransform: QuantileLiteral, field: FieldNameRepresentable, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.rawValue = GG.QuantileTransform(quantile: field.fieldName) // GG.QuantileTransform(id: <#T##GG.TransformId?#>, as: <#T##[GG.FieldName]?#>, groupby: <#T##[GG.FieldName]?#>, probs: <#T##[GG.QuantileTransform.ProbsItem]?#>, quantile: <#T##GG.FieldName#>, step: <#T##Double?#>)
        self.makeElements = makeElements
    }
}

extension GG.RegressionTransform : VizTransformDefType {
    public var anyTransform: GG.DataTransformation { .init(self) }
}

public extension VizTransform where Def == GG.RegressionTransform {
    enum RegressionLiteral {
        /// The regression transform fits two-dimensional regression models to smooth and predict data. This transform can fit multiple models for input data (one per group) and generates new data objects that represent points for summary trend lines. Alternatively, this transform can be used to generate a set of objects containing regression model parameters, one per group.
        case regression
    }
    init(_ regressionTransform: RegressionLiteral, field: GG.FieldName, on: GG.FieldName, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.rawValue = GG.RegressionTransform(on: on.fieldName, regression: field.fieldName) // GG.RegressionTransform(id: <#T##GG.TransformId?#>, as: <#T##[GG.FieldName]?#>, extent: <#T##[GG.RegressionTransform.ExtentItem]?#>, groupby: <#T##[GG.FieldName]?#>, method: <#T##GG.RegressionTransform.LiteralLinearOrLogOrExpOrPowOrQuadOrPoly?#>, on: <#T##GG.FieldName#>, order: <#T##Double?#>, params: <#T##Bool?#>, regression: <#T##GG.FieldName#>)
        self.makeElements = makeElements
    }
}

extension GG.TimeUnitTransform : VizTransformDefType {
    public var anyTransform: GG.DataTransformation { .init(self) }
}

public extension VizTransform where Def == GG.TimeUnitTransform {
    enum TimeUnitLiteral {
        /// Time unit is used to discretize times.
        case timeUnit
    }
    init(_ timeUnitTransform: TimeUnitLiteral, field: FieldNameRepresentable, timeUnit: GG.TimeUnit, output as: FieldNameRepresentable, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.rawValue = GG.TimeUnitTransform(as: `as`.fieldName, field: field.fieldName, timeUnit: .init(timeUnit)) // GG.TimeUnitTransform(id: <#T##GG.TransformId?#>, as: <#T##GG.FieldName#>, field: <#T##GG.FieldName#>, timeUnit: <#T##GG.TimeUnitTransform.TimeUnitChoice#>)
        self.makeElements = makeElements
    }

    init(_ timeUnitTransform: TimeUnitLiteral, field: FieldNameRepresentable, params: GG.TimeUnitParams, output as: FieldNameRepresentable, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.rawValue = GG.TimeUnitTransform(as: `as`.fieldName, field: field.fieldName, timeUnit: .init(params)) // GG.TimeUnitTransform(id: <#T##GG.TransformId?#>, as: <#T##GG.FieldName#>, field: <#T##GG.FieldName#>, timeUnit: <#T##GG.TimeUnitTransform.TimeUnitChoice#>)
        self.makeElements = makeElements
    }

}

extension GG.StackTransform : VizTransformDefType {
    public var anyTransform: GG.DataTransformation { .init(self) }
}

public extension VizTransform where Def == GG.StackTransform {
    enum StackLiteral {
        /// The stack property of a position field definition determines type of stacking offset if the field should be stacked.
        case stack
    }
    init(_ stackTransform: StackLiteral, field stack: FieldNameRepresentable, startField: FieldNameRepresentable, endField: FieldNameRepresentable, @VizLayerElementArrayBuilder _ makeElements: @escaping (_ startField: FieldNameRepresentable, _ endField: FieldNameRepresentable) -> [VizLayerElementType]) {
        self.rawValue = GG.StackTransform(as: .init([startField.fieldName, endField.fieldName]), stack: stack.fieldName) // GG.StackTransform(id: <#T##GG.TransformId?#>, as: <#T##GG.StackTransform.AsChoice#>, groupby: <#T##[GG.FieldName]#>, offset: <#T##GG.StackTransform.LiteralZeroOrCenterOrNormalize?#>, sort: <#T##[GG.SortField]?#>, stack: <#T##GG.FieldName#>)
        self.makeElements = { makeElements(startField, endField) }
    }
}

extension GG.WindowTransform : VizTransformDefType {
    public var anyTransform: GG.DataTransformation { .init(self) }
}

public extension VizTransform where Def == GG.WindowTransform {
    enum WindowLiteral {
        /// The window transform performs calculations over sorted groups of data objects. These calculations including ranking, lead/lag analysis, and aggregates such as running sums and averages. Calculated values are written back to the input data stream. If you only want to set the same aggregated value in a new field, you can use the simpler join aggregate transform.
        case window
    }
    init(_ windowTransform: WindowLiteral, field: FieldNameRepresentable?, op: OneOf<GG.AggregateOp>.Or<GG.WindowOnlyOp>, frame: FrameRange? = nil, param: Double? = nil, groupby: [FieldNameRepresentable]? = nil, ignorePeers: Bool? = nil, sort: [(FieldNameRepresentable, Bool?)]? = nil, output: FieldNameRepresentable, @VizLayerElementArrayBuilder _ makeElements: @escaping (_ windowField: FieldNameRepresentable) -> [VizLayerElementType]) {
        self.rawValue = GG.WindowTransform(frame: frame?.windowFrame, groupby: groupby?.map(\.fieldName), ignorePeers: ignorePeers, sort: sort?.map({ GG.SortField(field: $0.0.fieldName, order: $0.1 == true ? .init(GG.SortOrder.ascending) : $0.1 == false ? .init(GG.SortOrder.descending) : nil) }), window: [.init(as: output.fieldName, field: field?.fieldName, op: op, param: param)])
        self.makeElements = { makeElements(output) }
    }

    /// TODO???
    //init(_ windowTransform: WindowLiteral, fields: [(FieldNameRepresentable?, WindowOp]) { }


    /// A frame with an (optionally-open) lower bound and an (optionally-open) upper bound
    struct FrameRange {
        var lowerBound: Int?
        var upperBound: Int?

        public init(_ range: PartialRangeFrom<Int>) {
            lowerBound = range.lowerBound
            upperBound = nil
        }

        public init(_ range: PartialRangeThrough<Int>) {
            lowerBound = nil
            upperBound = range.upperBound
        }

        public init(_ range: ClosedRange<Int>) {
            lowerBound = range.lowerBound
            upperBound = range.upperBound
        }

        var windowFrame: [GG.WindowTransform.FrameItemChoice] {
            [
                lowerBound.map({ .init(.init($0)) }) ?? .null,
                upperBound.map({ .init(.init($0)) }) ?? .null
            ]
        }
    }
}


extension GG.PivotTransform : VizTransformDefType {
    public var anyTransform: GG.DataTransformation { .init(self) }
}

public extension VizTransform where Def == GG.PivotTransform {
    enum PivotLiteral {
        /// The pivot transform maps unique values from a field to new aggregated fields (columns) in the output stream. The transform requires both a field to pivot on (providing new field names) and a field of values to aggregate to populate the new cells. In addition, any number of groupby fields can be provided to further subdivide the data into output data objects (rows).
        case pivot
    }
    init(_ pivotTransform: PivotLiteral, pivot: FieldNameRepresentable, value: FieldNameRepresentable, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.rawValue = GG.PivotTransform(pivot: pivot.fieldName, value: value.fieldName) // GG.PivotTransform(id: <#T##GG.TransformId?#>, groupby: <#T##[GG.FieldName]?#>, limit: <#T##Double?#>, op: <#T##GG.AggregateOp?#>, pivot: <#T##GG.FieldName#>, value: <#T##GG.FieldName#>)
        self.makeElements = makeElements
    }
}


// MARK: Layers

/// A `Viz` encapsulates a top-level `VizSpec` layer and is used as the basis for the builder DSL.
@dynamicMemberLookup
public struct Viz<M: Pure> : VizLayerType, FluentContainer {
    public var rawValue: VizSpec<M>

    public init(rawValue: VizSpec<M> = VizSpec<M>()) {
        self.rawValue = rawValue
    }

    public init(spec fromSpec: VizSpec<M> = VizSpec<M>(), width: Double? = nil, height: Double? = nil, title: String? = nil, description: String? = nil, @VizSpecElementArrayBuilder _ makeElements: () -> [VizSpecElementType]) {
        var spec = fromSpec
        if let width = width { spec.width = .init(width) }
        if let height = height { spec.height = .init(height) }
        if let title = title { spec.title = .init(.init(title)) }
        if let description = description { spec.description = .init(description) }

        for element in makeElements() {
            element.add(to: &spec)
        }
        self.init(rawValue: spec)
    }
}

extension Viz : CustomDebugStringConvertible {
    /// The Viz's description is the JSON describing the spec
    public var debugDescription: String { rawValue.jsonDebugDescription }
}



// MARK: Marks


@dynamicMemberLookup
public struct VizMark<Def : VizMarkDefType> : VizMarkType, VizDSLType, FluentContainer {
    public var markDef: Def
    public var encodings: GG.EncodingChannelMap = GG.EncodingChannelMap()

    public var rawValue: Def {
        get { markDef }
        set { markDef = newValue }
    }
}

public extension VizMark {
    /// Adds this `VizMark` to an enclosing spec
    func add<M>(to spec: inout VizSpec<M>) where M : Pure {
        spec.mark = self.markDef.anyMark.compactRepresentation
        spec.encoding[defaulting: .init()] = self.encodings
    }
}

extension VizMark {
    fileprivate mutating func addEncodings(_ newEncodings: [VizMarkElementType]) {
        for enc in newEncodings {
            enc.addEncoding(to: &encodings)
        }
    }
}

public extension VizMark where Def == GG.MarkDef {
    init(_ primitiveMark: GG.PrimitiveMarkType) {
        self.init(primitiveMark) { }
    }

    init(_ primitiveMark: GG.PrimitiveMarkType, @VizMarkElementArrayBuilder makeEncodings: () -> [VizMarkElementType]) {
        markDef = GG.MarkDef(type: primitiveMark)
        addEncodings(makeEncodings())
    }
}

public extension VizMark where Def == GG.BoxPlotDef {
    init(_ boxPlot: GG.BoxPlotLiteral) {
        self.init(boxPlot) { }
    }

    init(_ boxPlot: GG.BoxPlotLiteral, @VizMarkElementArrayBuilder makeEncodings: () -> [VizMarkElementType]) {
        markDef = GG.BoxPlotDef(type: boxPlot)
        addEncodings(makeEncodings())
    }
}

public extension VizMark where Def == GG.ErrorBarDef {
    init(_ errorBar: GG.ErrorBarLiteral) {
        self.init(errorBar) { }
    }

    init(_ errorBar: GG.ErrorBarLiteral, @VizMarkElementArrayBuilder makeEncodings: () -> [VizMarkElementType]) {
        markDef = GG.ErrorBarDef(type: errorBar)
        addEncodings(makeEncodings())
    }
}

public extension VizMark where Def == GG.ErrorBandDef {
    init(_ errorBand: GG.ErrorBandLiteral) {
        self.init(errorBand) { }
    }

    init(_ errorBand: GG.ErrorBandLiteral, @VizMarkElementArrayBuilder makeEncodings: () -> [VizMarkElementType]) {
        markDef = GG.ErrorBandDef(type: errorBand)
        addEncodings(makeEncodings())
    }
}

public protocol VizMarkElementType : VizDSLType {
    /// Adds this encoding information to the given `EncodingChannelMap`
    func addEncoding(to encodings: inout GG.EncodingChannelMap)
}



// MARK: Guides

public typealias AnyGuide = OneOf<GG.AxisDef>.Or<GG.LegendDef>.Or<GG.HeaderDef>

public protocol VizGuideDefType : Pure {
    var anyGuide: AnyGuide { get }
}

extension GG.AxisDef : VizGuideDefType {
    public var anyGuide: AnyGuide { .init(self) }
}

extension GG.LegendDef : VizGuideDefType {
    public var anyGuide: AnyGuide { .init(self) }
}

extension GG.HeaderDef : VizGuideDefType {
    public var anyGuide: AnyGuide { .init(self) }
}

/// Any element that can be included beneath a `VizEncode` declaration
public protocol VizEncodeElementType : VizDSLType {
    /// Adds this guide to the given `EncodingChannelMap`
    // func add(toEncoding: inout AnyEncoding)
}


/// A `VizEncodeElementType` that has no associated axis/legend/header, such as `radius`, `detail`, `key`
public protocol VizUnguidedEncodeElementType : VizEncodeElementType {
}

/// A `VizEncodeElementType` that has an associated guide: axis, legend, or header.
public protocol VizGuidedEncodeElementType : VizEncodeElementType {
}

/// A `VizEncodeElementType` that can contain an axis
public protocol VizPositionalEncodeElementType : VizGuidedEncodeElementType {
}

/// A `VizEncodeElementType` that can contain an axis
public protocol VizPolarEncodeElementType : VizGuidedEncodeElementType {
}

/// A `VizEncodeElementType` that can contain a Legend
public protocol VizMarkPropertyEncodeElementType : VizGuidedEncodeElementType {
}

/// A `VizEncodeElementType` that can contain a Header
public protocol VizFacetEncodeElementType : VizGuidedEncodeElementType {
}

/// A `VizEncodeElementType` that can contain an axis
public protocol VizAxisEncodeElementType : VizPositionalEncodeElementType {
    var rawValue: GG.AxisDef { get }
}

/// A `VizEncodeElementType` that can contain a legend
public protocol VizLegendEncodeElementType : VizMarkPropertyEncodeElementType {
    var rawValue: GG.LegendDef { get }
}

/// A `VizEncodeElementType` that can contain a header
public protocol VizHeaderEncodeElementType : VizFacetEncodeElementType {
    var rawValue: GG.HeaderDef { get }
}

/// A `VizScaleEncodeElementType` that can be added to any encoding that supports scales: VizPositionalEncodeElementType, VizMarkPropertyEncodeElementType, VizFacetEncodeElementType, VizPolarEncodeElementType
public protocol VizScaleEncodeElementType : VizPositionalEncodeElementType, VizMarkPropertyEncodeElementType, VizFacetEncodeElementType, VizPolarEncodeElementType {
    var rawValue: GG.ScaleDef { get }
}


extension VizEncodeElementType {
    /// If this element has an axis, returns the axis def.
    var axis: GG.AxisDef? {
        if let axisElement = self as? VizAxisEncodeElementType {
            return axisElement.rawValue
        } else {
            return nil
        }
    }

    /// If this element has an legend, returns the legend def.
    var legend: GG.LegendDef? {
        if let legendElement = self as? VizLegendEncodeElementType {
            return legendElement.rawValue
        } else {
            return nil
        }
    }

    /// If this element has an header, returns the header def.
    var header: GG.HeaderDef? {
        if let headerElement = self as? VizHeaderEncodeElementType {
            return headerElement.rawValue
        } else {
            return nil
        }
    }

    /// If this element has an scale, returns the scale def.
    var scale: GG.ScaleDef? {
        if let scaleElement = self as? VizScaleEncodeElementType {
            return scaleElement.rawValue
        } else {
            return nil
        }
    }
}

/// Scales map data values (numbers, dates, categories, etc.) to visual values (pixels, colors, sizes).
@dynamicMemberLookup
public struct VizScale : VizScaleEncodeElementType, VizDSLType, FluentContainer {
    public var rawValue: GG.ScaleDef

    public init(rawValue scaleDef: GG.ScaleDef = GG.ScaleDef()) {
        self.rawValue = scaleDef
    }
}

public extension VizScale {
    func scale(domainValue: String, toRange rangeValue: String) -> Self {
        var this = self
        var domain = this.rawValue.domain?.v1 ?? []
        var range = this.rawValue.range?.v2 ?? []
        domain.append(.init(.init(domainValue)))
        range.append(.init(rangeValue))
        this.rawValue.domain = .init(domain)
        this.rawValue.range = .init(range)
        return this
    }

    /// Sets the numeric span as the scale's domain
    func domain<T: BinaryFloatingPoint>(_ numericRange: ClosedRange<T>) -> Self {
        let range = GG.ScaleDef.DomainChoice([.init(.init(Double(numericRange.lowerBound))), .init(.init(Double(numericRange.upperBound)))])
        return assigning(value: .init(range), to: \.domain, with: { $0 })
    }

    /// Sets the numeric span as the scale's range
    func range<T: BinaryFloatingPoint>(_ numericRange: ClosedRange<T>) -> Self {
        let range = GG.ScaleDef.RangeChoice([.init(.init(numericRange.lowerBound)), .init(.init(numericRange.upperBound))])
        return assigning(value: .init(range), to: \.range, with: { $0 })
    }
}

@dynamicMemberLookup
public struct VizGuide<Def : VizGuideDefType> : VizDSLType, FluentContainer {
    public var rawValue: Def

    public init(rawValue guideDef: Def) {
        self.rawValue = guideDef
    }
}

extension VizGuide : VizGuidedEncodeElementType {

}

extension VizGuide : VizLegendEncodeElementType & VizMarkPropertyEncodeElementType where Def == GG.LegendDef {
    public enum LegendGuide {
        /// A legend is a guide that shows the values for non-positional visual scales such as color, size, or line dash patterns.
        case legend
    }

    public init(_ legend: LegendGuide = .legend, guideDef: GG.LegendDef = GG.LegendDef()) {
        self.rawValue = guideDef
    }
}

extension VizGuide : VizAxisEncodeElementType & VizPositionalEncodeElementType where Def == GG.AxisDef {
    public enum AxisGuide {
        /// An axis is a guide that for positional scales
        case axis
    }

    public init(_ axis: AxisGuide = .axis, guideDef: GG.AxisDef = GG.AxisDef()) {
        self.rawValue = guideDef
    }
}

extension VizGuide : VizHeaderEncodeElementType & VizFacetEncodeElementType where Def == GG.HeaderDef {
    public enum HeaderGuide {
        /// An header is a guide that for headers
        case header
    }

    public init(_ header: HeaderGuide = .header, guideDef: GG.HeaderDef = GG.HeaderDef()) {
        self.rawValue = guideDef
    }
}



// MARK: Builders

//public typealias VizMarkArrayBuilder = ChildElementBuilder<VizMarkType>

public typealias VizSpecElementArrayBuilder = ChildElementBuilder<VizSpecElementType>
public typealias VizLayerElementArrayBuilder = ChildElementBuilder<VizLayerElementType>
public typealias VizMarkElementArrayBuilder = ChildElementBuilder<VizMarkElementType>


@resultBuilder
public enum ChildElementBuilder<Element> {
    public static func buildEither(first component: [Element]) -> [Element] {
        return component
    }

    public static func buildEither(second component: [Element]) -> [Element] {
        return component
    }

    public static func buildOptional(_ component: [Element]?) -> [Element] {
        return component ?? []
    }

    public static func buildBlock(_ components: [Element]...) -> [Element] {
        return components.flatMap { $0 }
    }

    public static func buildExpression(_ expression: Element) -> [Element] {
        return [expression]
    }

    public static func buildExpression(_ expression: Void) -> [Element] {
        return []
    }

}

extension VizSpecElementArrayBuilder {
    @available(*, unavailable, message: "VizEncode elements are children of VizLayer and VizMark")
    public static func buildBlock(_ components: VizMarkElementType...) -> [VizMarkElementType] {
        fatalError()
    }

}


/// A layer for a visualization, either top-level of nested
public protocol VizLayerType : VizDSLType {

}

/// A layer for a transform
public protocol VizTransformType : VizDSLType {

}


//@dynamicMemberLookup
public struct VizLayer : VizSpecElementType, VizLayerType {
    var arrangement: LayerArrangement
    let makeElements: () -> [VizLayerElementType]

    public init(_ arrangement: LayerArrangement = .overlay, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType] = { [] }) {
        self.arrangement = arrangement
        self.makeElements = makeElements
    }

    public func add<M>(to spec: inout VizSpec<M>) where M : Pure {
        spec.arrangement = self.arrangement
        for element in makeElements() {
            // marks and layers create their own child specs; all others (e.g., encodings) are set directly in the parent
            if element is VizMarkType || element is VizLayerType || element is VizTransformType {
                var child = VizSpec<M>()
                element.add(to: &child)
                spec.sublayers.append(child)
            } else {
                element.add(to: &spec)
            }
        }
    }

//    /// Creates a setter function for the given dynamic keypath, allowing a fluent API for all the public properties of the instance
//    public subscript<U>(dynamicMember keyPath: WritableKeyPath<GGSchema.Projection, U>) -> (U) -> (Self) {
//        setting(path: (\Self.projection).appending(path: keyPath))
//    }
}

public extension VizSpec {
    /// Set the given specification a repeat along a single dimension.
    ///
    /// - Parameters:
    ///   - repeatSpec: the specification to repeat
    ///   - fields: the fields to apply to the repeat fields
    ///   - repeatArrangement: the arrangement of the repeat (`.horizontal`, `.vertical`, `.wrap`, `.overlay`)
    mutating func setRepeating(spec repeatSpec: Self, fields: [GG.FieldName], arrangement repeatArrangement: LayerArrangement) {
        self.arrangement = nil // .repeat
        self.spec = .init(repeatSpec) // add it as the `repeat spec`
        switch repeatArrangement {
        case .overlay:
            self.repeat = .init(GG.LayerRepeatMapping(layer: fields))
        case .horizontal:
            self.repeat = .init(GG.RepeatMapping(column: fields))
        case .vertical:
            self.repeat = .init(GG.RepeatMapping(row: fields))
        case .wrap:
            self.repeat = .init(fields)
        }
    }
}

public struct VizRepeat : VizSpecElementType, VizLayerType {
    var repeatArrangement: LayerArrangement
    let repeatFields: [FieldNameRepresentable]
    let makeElements: () -> [VizLayerElementType]

    public init(_ repeatArrangement: LayerArrangement, fields repeatFields: [FieldNameRepresentable], @VizLayerElementArrayBuilder _ makeElements: @escaping (_ ref: GG.RepeatRef) -> [VizLayerElementType]) {
        self.repeatArrangement = repeatArrangement
        self.repeatFields = repeatFields
        self.makeElements = { makeElements(repeatArrangement.repeatRef) }
    }

    public func add<M>(to spec: inout VizSpec<M>) where M : Pure {
        for element in makeElements() {
            // marks and layers create their own child specs; all others (e.g., encodings) are set directly in the parent
            if element is VizMarkType || element is VizLayerType {
                var child = VizSpec<M>()
                element.add(to: &child)
                spec.setRepeating(spec: child, fields: repeatFields.map(\.fieldName), arrangement: repeatArrangement)
            } else {
                element.add(to: &spec)
            }
        }
    }

//    /// Creates a setter function for the given dynamic keypath, allowing a fluent API for all the public properties of the instance
//    public subscript<U>(dynamicMember keyPath: WritableKeyPath<GGSchema.Projection, U>) -> (U) -> (Self) {
//        setting(path: (\Self.projection).appending(path: keyPath))
//    }
}


extension VizEncode {
//    public func measure(_ measure: StandardMeasureType) -> Self {
//        var this = self
//
//        return this
//    }
}


extension VizDSLType {
    /// Fluent-style API for setting a value on a reference type and returning the type
    /// - Parameter keyPath: the path to assign
    /// - Parameter value: the value to set
    func setting<T>(path keyPath: WritableKeyPath<Self, T>) -> (_ value: T) -> Self {
        { value in
            var this = self
            this[keyPath: keyPath] = value
            return this
        }
    }
}




// MARK: Encodings


public protocol VizEncodingChannelType : Pure, RawCodable {
    static var encodingChannel: EncodingChannel { get }

    func addChannel(to encodings: inout GG.EncodingChannelMap, elements: [VizEncodeElementType])
}

@dynamicMemberLookup
public struct VizEncode<Channel : VizEncodingChannelType, Def : Pure> : FluentContainer {
    public var def: Def
    private let deriveChannel: (Def) -> (Channel)
    private let makeElements: () -> [VizEncodeElementType]

    public var rawValue: Def {
        get { def }
        set { def = newValue }
    }
}

extension VizEncode : VizLayerElementType {
    public func add<M: Pure>(to spec: inout VizSpec<M>) {
        deriveChannel(rawValue).addChannel(to: &spec.encoding[defaulting: .init()], elements: makeElements())
    }
}

extension VizEncode : VizMarkElementType {
    public func addEncoding(to encodings: inout GG.EncodingChannelMap) {
        deriveChannel(rawValue).addChannel(to: &encodings, elements: makeElements())
    }
}



// MARK: VizEncode: X

public extension VizEncode where Channel == GG.EncodingChannelMap.XEncoding {
    enum XChannel {
        /// x and y position channels determine the position of the marks, or width/height of horizontal/vertical "area" and "bar". In addition, x2 and y2 can specify the span of ranged area, bar, rect, and rule.
        case x
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Empty Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.XEncoding, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.PositionFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ x: XChannel, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ x: XChannel, field: FieldNameRepresentable, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ x: XChannel, repeat: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.XEncoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.PositionDatumDef { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ x: XChannel, datum: ExplicitNull, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ x: XChannel, datum: Double, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ x: XChannel, datum: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ x: XChannel, datum: Bool, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ x: XChannel, datum: GG.DateTime, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ x: XChannel, expression: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ x: XChannel, datum: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.XEncoding, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.ValueDefNumberWidthHeightExprRef { def }

    /// Creates this encoding with the given constant value.
    init(_ x: XChannel, value constant: Double, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ x: XChannel, value constant: GG.LiteralWidth, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ x: XChannel, value constant: GG.LiteralHeight, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T3 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with a dynamic expression.
    init(_ x: XChannel, expression: GG.ExprRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T4 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }
}








// MARK: VizEncode: Y

public extension VizEncode where Channel == GG.EncodingChannelMap.YEncoding {

    enum YChannel {
        /// x and y position channels determine the position of the marks, or width/height of horizontal/vertical "area" and "bar". In addition, x2 and y2 can specify the span of ranged area, bar, rect, and rule.
        case y
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Empty Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.YEncoding, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.PositionFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ y: YChannel, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ y: YChannel, field: FieldNameRepresentable, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ y: YChannel, repeat: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.YEncoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.PositionDatumDef { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ y: YChannel, datum: ExplicitNull, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ y: YChannel, datum: Double, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ y: YChannel, datum: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ y: YChannel, datum: Bool, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ y: YChannel, datum: GG.DateTime, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ y: YChannel, expression: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ y: YChannel, datum: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.YEncoding, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.ValueDefNumberWidthHeightExprRef { def }

    /// Creates this encoding with the given constant value.
    init(_ y: YChannel, value constant: Double, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ y: YChannel, value constant: GG.LiteralWidth, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ y: YChannel, value constant: GG.LiteralHeight, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T3 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with a dynamic expression.
    init(_ y: YChannel, expression: GG.ExprRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T4 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }
}




// MARK: VizEncode: x2

public extension VizEncode where Channel == GG.EncodingChannelMap.X2Encoding {
    enum X2Channel {
        /// x and y position channels determine the position of the marks, or width/height of horizontal/vertical "area" and "bar". In addition, x2 and y2 can specify the span of ranged area, bar, rect, and rule.
        case x2
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Empty Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.X2Encoding, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.SecondaryFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ x2: X2Channel, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ x2: X2Channel, field: FieldNameRepresentable, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ x2: X2Channel, repeat: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.X2Encoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.DatumDef { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ x2: X2Channel, datum: ExplicitNull, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ x2: X2Channel, datum: Double, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ x2: X2Channel, datum: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ x2: X2Channel, datum: Bool, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ x2: X2Channel, datum: GG.DateTime, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ x2: X2Channel, expression: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ x2: X2Channel, datum: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.X2Encoding, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.ValueDefNumberWidthHeightExprRef { def }

    /// Creates this encoding with the given constant value.
    init(_ x2: X2Channel, value constant: Double, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ x2: X2Channel, value constant: GG.LiteralWidth, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ x2: X2Channel, value constant: GG.LiteralHeight, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T3 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with a dynamic expression.
    init(_ x2: X2Channel, expression: GG.ExprRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T4 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }
}






// MARK: VizEncode: y2


public extension VizEncode where Channel == GG.EncodingChannelMap.Y2Encoding {
    enum Y2Channel {
        /// x and y position channels determine the position of the marks, or width/height of horizontal/vertical "area" and "bar". In addition, x2 and y2 can specify the span of ranged area, bar, rect, and rule.
        case y2
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Empty Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.Y2Encoding, Def == GG.SecondaryFieldDef {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.SecondaryFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ y2: Y2Channel, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ y2: Y2Channel, field: FieldNameRepresentable, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ y2: Y2Channel, repeat: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.Y2Encoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.DatumDef { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ y2: Y2Channel, datum: ExplicitNull, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ y2: Y2Channel, datum: Double, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ y2: Y2Channel, datum: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ y2: Y2Channel, datum: Bool, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ y2: Y2Channel, datum: GG.DateTime, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ y2: Y2Channel, expression: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ y2: Y2Channel, datum: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.Y2Encoding, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.ValueDefNumberWidthHeightExprRef { def }

    /// Creates this encoding with the given constant value.
    init(_ y2: Y2Channel, value constant: Double, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ y2: Y2Channel, value constant: GG.LiteralWidth, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ y2: Y2Channel, value constant: GG.LiteralHeight, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T3 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with a dynamic expression.
    init(_ y2: Y2Channel, expression: GG.ExprRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T4 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }
}




// MARK: VizEncode: Color

public extension VizEncode where Channel == GG.EncodingChannelMap.ColorEncoding {
    enum ColorChannel {
        /// Color of the marks ??? either fill or stroke color based on the filled property of mark definition. By default, color represents fill color for "area", "bar", "tick", "text", "trail", "circle", and "square" / stroke color for "line" and "point".
        case color
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Field Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.ColorEncoding, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.FieldOrDatumDefWithConditionMarkPropFieldDefGradientStringNull { def }

    /// Creates an empty instance of this encoding.
    init(_ color: ColorChannel, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ color: ColorChannel, field: FieldNameRepresentable, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ color: ColorChannel, repeat: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.ColorEncoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.FieldOrDatumDefWithConditionDatumDefGradientStringNull { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ color: ColorChannel, datum: ExplicitNull, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ color: ColorChannel, datum: Double, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ color: ColorChannel, datum: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ color: ColorChannel, datum: Bool, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ color: ColorChannel, datum: GG.DateTime, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ color: ColorChannel, expression: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ color: ColorChannel, datum: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.ColorEncoding, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.ValueDefWithConditionMarkPropFieldOrDatumDefGradientStringNull { def }

    /// Creates this encoding with the given constant value.
    init(_ color: ColorChannel, value constant: ExplicitNull, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ color: ColorChannel, value constant: GG.ColorGradientLinear, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.init(color, value: .init(.init(constant)), makeElements: makeElements)
    }

    /// Creates this encoding with the given constant value.
    init(_ color: ColorChannel, value constant: GG.ColorGradientRadial, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.init(color, value: .init(.init(constant)), makeElements: makeElements)
    }

    /// Creates this encoding with the given constant color value.
    init(_ color: ColorChannel, value constant: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.init(color, value: .init(constant), makeElements: makeElements)
    }

    /// Creates this encoding with the given constant color expression.
    init(_ color: ColorChannel, expression: GG.ExprRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.init(color, value: .init(expression), makeElements: makeElements)
    }

    private init(_ color: ColorChannel, value constant: OneOf3<GG.ColorGradient, String, GG.ExprRef>, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }
}





// MARK: VizEncode: Fill

public extension VizEncode where Channel == GG.EncodingChannelMap.FillEncoding {
    enum FillChannel {
        /// Fill color of the marks. Default value: If undefined, the default color depends on mark config???s color property.
        case fill
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Field Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.FillEncoding, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.FieldOrDatumDefWithConditionMarkPropFieldDefGradientStringNull { def }

    /// Creates an empty instance of this encoding.
    init(_ fill: FillChannel, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ fill: FillChannel, field: FieldNameRepresentable, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ fill: FillChannel, repeat: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.FillEncoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.FieldOrDatumDefWithConditionDatumDefGradientStringNull { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ fill: FillChannel, datum: ExplicitNull, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ fill: FillChannel, datum: Double, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ fill: FillChannel, datum: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ fill: FillChannel, datum: Bool, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ fill: FillChannel, datum: GG.DateTime, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ fill: FillChannel, expression: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ fill: FillChannel, datum: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.FillEncoding, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.ValueDefWithConditionMarkPropFieldOrDatumDefGradientStringNull { def }

    /// Creates this encoding with the given constant value.
    init(_ fill: FillChannel, value constant: ExplicitNull, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ fill: FillChannel, value constant: GG.ColorGradientLinear, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.init(fill, value: .init(.init(constant)), makeElements: makeElements)
    }

    /// Creates this encoding with the given constant value.
    init(_ fill: FillChannel, value constant: GG.ColorGradientRadial, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.init(fill, value: .init(.init(constant)), makeElements: makeElements)
    }

    /// Creates this encoding with the given constant color value.
    init(_ fill: FillChannel, value constant: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.init(fill, value: .init(constant), makeElements: makeElements)
    }

    // TODO: need to be able to create with constants
//    /// Creates this encoding with the given constant color value.
//    init(_ fill: FillChannel, value constant: ColorCode, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
//    self.makeElements = makeElements
//        self.init(fill, value: .init(constant))
//    }

    /// Creates this encoding with the given constant color expression.
    init(_ fill: FillChannel, expression: GG.ExprRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.init(fill, value: .init(expression), makeElements: makeElements)
    }

    private init(_ fill: FillChannel, value constant: OneOf3<GG.ColorGradient, String, GG.ExprRef>, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }
}



// MARK: VizEncode: Stroke

public extension VizEncode where Channel == GG.EncodingChannelMap.StrokeEncoding {
    enum StrokeChannel {
        /// Stroke color of the marks. Default value: If undefined, the default color depends on mark config???s color property.
        case stroke
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Field Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.StrokeEncoding, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.FieldOrDatumDefWithConditionMarkPropFieldDefGradientStringNull { def }

    /// Creates an empty instance of this encoding.
    init(_ stroke: StrokeChannel, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ stroke: StrokeChannel, field: FieldNameRepresentable, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ stroke: StrokeChannel, repeat: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.StrokeEncoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.FieldOrDatumDefWithConditionDatumDefGradientStringNull { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ stroke: StrokeChannel, datum: ExplicitNull, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ stroke: StrokeChannel, datum: Double, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ stroke: StrokeChannel, datum: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ stroke: StrokeChannel, datum: Bool, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ stroke: StrokeChannel, datum: GG.DateTime, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ stroke: StrokeChannel, expression: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ stroke: StrokeChannel, datum: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.StrokeEncoding, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.ValueDefWithConditionMarkPropFieldOrDatumDefGradientStringNull { def }

    /// Creates this encoding with the given constant value.
    init(_ stroke: StrokeChannel, value constant: ExplicitNull, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ stroke: StrokeChannel, value constant: GG.ColorGradientLinear, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.init(stroke, value: .init(.init(constant)), makeElements: makeElements)
    }

    /// Creates this encoding with the given constant value.
    init(_ stroke: StrokeChannel, value constant: GG.ColorGradientRadial, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.init(stroke, value: .init(.init(constant)), makeElements: makeElements)
    }

    /// Creates this encoding with the given constant color value.
    init(_ stroke: StrokeChannel, value constant: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.init(stroke, value: .init(constant), makeElements: makeElements)
    }

    /// Creates this encoding with the given constant color expression.
    init(_ stroke: StrokeChannel, expression: GG.ExprRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.init(stroke, value: .init(expression), makeElements: makeElements)
    }

    private init(_ stroke: StrokeChannel, value constant: OneOf3<GG.ColorGradient, String, GG.ExprRef>, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }
}


// MARK: VizEncode: size

public extension VizEncode where Channel == GG.EncodingChannelMap.SizeEncoding {
    enum SizeChannel {
        /// Size of the mark.
        ///
        /// - For "point", "square" and "circle", ??? the symbol size, or pixel area of the mark.
        /// - For "bar" and "tick" ??? the bar and tick???s size.
        /// - For "text" ??? the text???s font size.
        ///
        /// - Size is unsupported for "line", "area", and "rect". (Use "trail" instead of line with varying size)
        case size
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Field Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.SizeEncoding, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.FieldOrDatumDefWithConditionMarkPropFieldDefNumber { def }

    /// Creates an empty instance of this encoding.
    init(_ size: SizeChannel, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ size: SizeChannel, field: FieldNameRepresentable, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ size: SizeChannel, repeat: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.SizeEncoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.FieldOrDatumDefWithConditionDatumDefNumber { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ size: SizeChannel, datum: ExplicitNull, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ size: SizeChannel, datum: Double, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ size: SizeChannel, datum: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ size: SizeChannel, datum: Bool, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ size: SizeChannel, datum: GG.DateTime, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ size: SizeChannel, expression: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ size: SizeChannel, datum: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.SizeEncoding, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.ValueDefWithConditionMarkPropFieldOrDatumDefNumber { def }

    /// Creates this encoding with the given constant value.
    init(_ size: SizeChannel, value constant: Double, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with a dynamic expression.
    init(_ size: SizeChannel, expr expression: GG.ExprRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }
}



// MARK: VizEncode: strokeWidth

public extension VizEncode where Channel == GG.EncodingChannelMap.StrokeWidthEncoding {
    enum StrokeWidthChannel {
        /// Stroke width of the marks.
        ///
        /// - Default value: If undefined, the default stroke width depends on mark config???s strokeWidth property.
        case strokeWidth
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Field Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.StrokeWidthEncoding, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.FieldOrDatumDefWithConditionMarkPropFieldDefNumber { def }

    /// Creates an empty instance of this encoding.
    init(_ strokeWidth: StrokeWidthChannel, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ strokeWidth: StrokeWidthChannel, field: FieldNameRepresentable, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ strokeWidth: StrokeWidthChannel, repeat: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.StrokeWidthEncoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.FieldOrDatumDefWithConditionDatumDefNumber { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeWidth: StrokeWidthChannel, datum: ExplicitNull, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeWidth: StrokeWidthChannel, datum: Double, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeWidth: StrokeWidthChannel, datum: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeWidth: StrokeWidthChannel, datum: Bool, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeWidth: StrokeWidthChannel, datum: GG.DateTime, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeWidth: StrokeWidthChannel, expression: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ strokeWidth: StrokeWidthChannel, datum: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.StrokeWidthEncoding, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.ValueDefWithConditionMarkPropFieldOrDatumDefNumber { def }

    /// Creates this encoding with the given constant value.
    init(_ strokeWidth: StrokeWidthChannel, value constant: Double, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with a dynamic expression.
    init(_ strokeWidth: StrokeWidthChannel, expr expression: GG.ExprRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }
}



// MARK: VizEncode: strokeOpacity

public extension VizEncode where Channel == GG.EncodingChannelMap.StrokeOpacityEncoding {
    enum StrokeOpacityChannel {
        /// Stroke opacity of the marks.
        case strokeOpacity
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Field Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.StrokeOpacityEncoding, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.FieldOrDatumDefWithConditionMarkPropFieldDefNumber { def }

    /// Creates an empty instance of this encoding.
    init(_ strokeOpacity: StrokeOpacityChannel, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ strokeOpacity: StrokeOpacityChannel, field: FieldNameRepresentable, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ strokeOpacity: StrokeOpacityChannel, repeat: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.StrokeOpacityEncoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.FieldOrDatumDefWithConditionDatumDefNumber { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeOpacity: StrokeOpacityChannel, datum: ExplicitNull, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeOpacity: StrokeOpacityChannel, datum: Double, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeOpacity: StrokeOpacityChannel, datum: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeOpacity: StrokeOpacityChannel, datum: Bool, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeOpacity: StrokeOpacityChannel, datum: GG.DateTime, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeOpacity: StrokeOpacityChannel, expression: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ strokeOpacity: StrokeOpacityChannel, datum: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.StrokeOpacityEncoding, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.ValueDefWithConditionMarkPropFieldOrDatumDefNumber { def }

    /// Creates this encoding with the given constant value.
    init(_ strokeOpacity: StrokeOpacityChannel, value constant: Double, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with a dynamic expression.
    init(_ strokeOpacity: StrokeOpacityChannel, expr expression: GG.ExprRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }
}



// MARK: VizEncode: fillOpacity

public extension VizEncode where Channel == GG.EncodingChannelMap.FillOpacityEncoding {
    enum FillOpacityChannel {
        /// Fill opacity of the marks.
        case fillOpacity
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Field Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.FillOpacityEncoding, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.FieldOrDatumDefWithConditionMarkPropFieldDefNumber { def }

    /// Creates an empty instance of this encoding.
    init(_ fillOpacity: FillOpacityChannel, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ fillOpacity: FillOpacityChannel, field: FieldNameRepresentable, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ fillOpacity: FillOpacityChannel, repeat: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.FillOpacityEncoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.FieldOrDatumDefWithConditionDatumDefNumber { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ fillOpacity: FillOpacityChannel, datum: ExplicitNull, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ fillOpacity: FillOpacityChannel, datum: Double, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ fillOpacity: FillOpacityChannel, datum: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ fillOpacity: FillOpacityChannel, datum: Bool, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ fillOpacity: FillOpacityChannel, datum: GG.DateTime, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ fillOpacity: FillOpacityChannel, expression: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ fillOpacity: FillOpacityChannel, datum: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.FillOpacityEncoding, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.ValueDefWithConditionMarkPropFieldOrDatumDefNumber { def }

    /// Creates this encoding with the given constant value.
    init(_ fillOpacity: FillOpacityChannel, value constant: Double, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with a dynamic expression.
    init(_ fillOpacity: FillOpacityChannel, expr expression: GG.ExprRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }
}



// MARK: VizEncode: opacity

public extension VizEncode where Channel == GG.EncodingChannelMap.OpacityEncoding {
    enum OpacityChannel {
        /// Opacity of the marks.
        case opacity
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Field Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.OpacityEncoding, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.FieldOrDatumDefWithConditionMarkPropFieldDefNumber { def }

    /// Creates an empty instance of this encoding.
    init(_ opacity: OpacityChannel, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ opacity: OpacityChannel, field: FieldNameRepresentable, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ opacity: OpacityChannel, repeat: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.OpacityEncoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.FieldOrDatumDefWithConditionDatumDefNumber { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ opacity: OpacityChannel, datum: ExplicitNull, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ opacity: OpacityChannel, datum: Double, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ opacity: OpacityChannel, datum: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ opacity: OpacityChannel, datum: Bool, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ opacity: OpacityChannel, datum: GG.DateTime, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ opacity: OpacityChannel, expression: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ opacity: OpacityChannel, datum: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.OpacityEncoding, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.ValueDefWithConditionMarkPropFieldOrDatumDefNumber { def }

    /// Creates this encoding with the given constant value.
    init(_ opacity: OpacityChannel, value constant: Double, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with a dynamic expression.
    init(_ opacity: OpacityChannel, expr expression: GG.ExprRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }
}



// MARK: VizEncode: angle

public extension VizEncode where Channel == GG.EncodingChannelMap.AngleEncoding {
    enum AngleChannel {
        /// Rotation angle of point and text marks.
        case angle
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Field Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.AngleEncoding, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.FieldOrDatumDefWithConditionMarkPropFieldDefNumber { def }

    /// Creates an empty instance of this encoding.
    init(_ angle: AngleChannel, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ angle: AngleChannel, field: FieldNameRepresentable, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ angle: AngleChannel, repeat: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.AngleEncoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.FieldOrDatumDefWithConditionDatumDefNumber { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ angle: AngleChannel, datum: ExplicitNull, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ angle: AngleChannel, datum: Double, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ angle: AngleChannel, datum: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ angle: AngleChannel, datum: Bool, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ angle: AngleChannel, datum: GG.DateTime, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ angle: AngleChannel, expression: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ angle: AngleChannel, datum: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.AngleEncoding, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.ValueDefWithConditionMarkPropFieldOrDatumDefNumber { def }

    /// Creates this encoding with the given constant value.
    init(_ angle: AngleChannel, value constant: Double, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with a dynamic expression.
    init(_ angle: AngleChannel, expr expression: GG.ExprRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }
}



// MARK: VizEncode: theta


public extension VizEncode where Channel == GG.EncodingChannelMap.ThetaEncoding {
    enum ThetaChannel {
        /// For arc marks, the arc length in radians if theta2 is not specified, otherwise the start arc angle. (A value of 0 indicates up or ???north???, increasing values proceed clockwise.)
        /// For text marks, polar coordinate angle in radians.
        case theta
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Field Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.ThetaEncoding, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.PositionFieldDefBase { def }

    /// Creates an empty instance of this encoding.
    init(_ theta: ThetaChannel, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ theta: ThetaChannel, field: FieldNameRepresentable, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ theta: ThetaChannel, repeat: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.ThetaEncoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.PositionDatumDefBase { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ theta: ThetaChannel, datum: ExplicitNull, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ theta: ThetaChannel, datum: Double, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ theta: ThetaChannel, datum: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ theta: ThetaChannel, datum: Bool, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ theta: ThetaChannel, datum: GG.DateTime, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ theta: ThetaChannel, expression: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ theta: ThetaChannel, datum: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.ThetaEncoding, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.ValueDefNumberWidthHeightExprRef { def }

    /// Creates this encoding with the given constant value.
    init(_ theta: ThetaChannel, value constant: Double, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ theta: ThetaChannel, value constant: GG.LiteralWidth, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }

    /// Creates this encoding with a dynamic expression.
    init(_ theta: ThetaChannel, expr expression: GG.LiteralHeight, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T3 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }

    /// Creates this encoding with a dynamic expression.
    init(_ theta: ThetaChannel, expr expression: GG.ExprRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T4 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }

}


// MARK: VizEncode: theta2

public extension VizEncode where Channel == GG.EncodingChannelMap.Theta2Encoding {
    enum Theta2Channel {
        /// The end angle of arc marks in radians. A value of 0 indicates up or ???north???, increasing values proceed clockwise.
        case theta2
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Field Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.Theta2Encoding, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.SecondaryFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ theta2: Theta2Channel, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ theta2: Theta2Channel, field: FieldNameRepresentable, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ theta2: Theta2Channel, repeat: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.Theta2Encoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.DatumDef { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ theta2: Theta2Channel, datum: ExplicitNull, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ theta2: Theta2Channel, datum: Double, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ theta2: Theta2Channel, datum: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ theta2: Theta2Channel, datum: Bool, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ theta2: Theta2Channel, datum: GG.DateTime, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ theta2: Theta2Channel, expression: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ theta2: Theta2Channel, datum: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.Theta2Encoding, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.ValueDefNumberWidthHeightExprRef { def }

    /// Creates this encoding with the given constant value.
    init(_ theta2: Theta2Channel, value constant: Double, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ theta2: Theta2Channel, value constant: GG.LiteralWidth, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }

    /// Creates this encoding with a dynamic expression.
    init(_ theta2: Theta2Channel, expr expression: GG.LiteralHeight, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T3 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }

    /// Creates this encoding with a dynamic expression.
    init(_ theta2: Theta2Channel, expr expression: GG.ExprRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T4 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }
}



// MARK: VizEncode: radius

public extension VizEncode where Channel == GG.EncodingChannelMap.RadiusEncoding {
    enum RadiusChannel {
        /// The outer radius in pixels of arc marks.
        case radius
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Field Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.RadiusEncoding, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.PositionFieldDefBase { def }

    /// Creates an empty instance of this encoding.
    init(_ radius: RadiusChannel, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ radius: RadiusChannel, field: FieldNameRepresentable, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ radius: RadiusChannel, repeat: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.RadiusEncoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.PositionDatumDefBase { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ radius: RadiusChannel, datum: ExplicitNull, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ radius: RadiusChannel, datum: Double, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ radius: RadiusChannel, datum: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ radius: RadiusChannel, datum: Bool, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ radius: RadiusChannel, datum: GG.DateTime, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ radius: RadiusChannel, expression: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ radius: RadiusChannel, datum: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.RadiusEncoding, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.ValueDefNumberWidthHeightExprRef { def }

    /// Creates this encoding with the given constant value.
    init(_ radius: RadiusChannel, value constant: Double, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }


    /// Creates this encoding with the given constant value.
    init(_ radius: RadiusChannel, value constant: GG.LiteralWidth, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }

    /// Creates this encoding with a dynamic expression.
    init(_ radius: RadiusChannel, expr expression: GG.LiteralHeight, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T3 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }

    /// Creates this encoding with a dynamic expression.
    init(_ radius: RadiusChannel, expr expression: GG.ExprRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T4 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }
}



// MARK: VizEncode: radius2

public extension VizEncode where Channel == GG.EncodingChannelMap.Radius2Encoding {
    enum Radius2Channel {
        /// The inner radius in pixels of arc marks.
        case radius2
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Field Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.Radius2Encoding, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.SecondaryFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ radius2: Radius2Channel, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ radius2: Radius2Channel, field: FieldNameRepresentable, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ radius2: Radius2Channel, repeat: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.Radius2Encoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.DatumDef { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ radius2: Radius2Channel, datum: ExplicitNull, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ radius2: Radius2Channel, datum: Double, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ radius2: Radius2Channel, datum: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ radius2: Radius2Channel, datum: Bool, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ radius2: Radius2Channel, datum: GG.DateTime, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ radius2: Radius2Channel, expression: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ radius2: Radius2Channel, datum: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.Radius2Encoding, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.ValueDefNumberWidthHeightExprRef { def }

    /// Creates this encoding with the given constant value.
    init(_ radius2: Radius2Channel, value constant: Double, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }


    /// Creates this encoding with the given constant value.
    init(_ radius2: Radius2Channel, value constant: GG.LiteralWidth, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }

    /// Creates this encoding with a dynamic expression.
    init(_ radius2: Radius2Channel, expr expression: GG.LiteralHeight, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T3 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }

    /// Creates this encoding with a dynamic expression.
    init(_ radius2: Radius2Channel, expr expression: GG.ExprRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T4 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }
}



// MARK: VizEncode: xError

public extension VizEncode where Channel == GG.EncodingChannelMap.XErrorEncoding {
    enum XErrorChannel {
        case xError
    }

    typealias ChannelFieldType = Channel.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.T2
}

/// Empty Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.XErrorEncoding, Def == GG.SecondaryFieldDef {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.SecondaryFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ xError: XErrorChannel, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    init(_ xError: XErrorChannel, field: FieldNameRepresentable, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        /// Creates this encoding with the value mapped to the given field name in the data.
        self.deriveChannel = { .init($0) }
        self.def = .init(field: .init(field.fieldName))
    }
}

/// Field Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.XErrorEncoding, Def == GG.ValueDefNumber {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.ValueDefNumber { def }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ xError: XErrorChannel, value constant: Double, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: constant)
    }
}





// MARK: VizEncode: xError2


public extension VizEncode where Channel == GG.EncodingChannelMap.XError2Encoding {
    enum XError2Channel {
        case xError2
    }

    typealias ChannelFieldType = Channel.RawValue.T1
    typealias ChannelValueType = Channel.RawValue.T2
}

/// Empty Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.XError2Encoding, Def == GG.SecondaryFieldDef {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.SecondaryFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ xError2: XError2Channel, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    init(_ xError2: XError2Channel, field: FieldNameRepresentable, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        /// Creates this encoding with the value mapped to the given field name in the data.
        self.deriveChannel = { .init($0) }
        self.def = .init(field: .init(field.fieldName))
    }
}

/// Field Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.XError2Encoding, Def == GG.ValueDefNumber {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.ValueDefNumber { def }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ xError2: XError2Channel, value constant: Double, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: constant)
    }
}




// MARK: VizEncode: yError


public extension VizEncode where Channel == GG.EncodingChannelMap.YErrorEncoding {
    enum YErrorChannel {
        case yError
    }

    typealias ChannelFieldType = Channel.RawValue.T1
    typealias ChannelValueType = Channel.RawValue.T2
}

/// Empty Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.YErrorEncoding, Def == GG.SecondaryFieldDef {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.SecondaryFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ yError: YErrorChannel, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    init(_ yError: YErrorChannel, field: FieldNameRepresentable, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        /// Creates this encoding with the value mapped to the given field name in the data.
        self.deriveChannel = { .init($0) }
        self.def = .init(field: .init(field.fieldName))
    }
}

/// Field Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.YErrorEncoding, Def == GG.ValueDefNumber {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.ValueDefNumber { def }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ yError: YErrorChannel, value constant: Double, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: constant)
    }
}



// MARK: VizEncode: yError2


public extension VizEncode where Channel == GG.EncodingChannelMap.YError2Encoding {
    enum YError2Channel {
        case yError2
    }

    typealias ChannelFieldType = Channel.RawValue.T1
    typealias ChannelValueType = Channel.RawValue.T2
}

/// Empty Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.YError2Encoding, Def == GG.SecondaryFieldDef {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.SecondaryFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ yError2: YError2Channel, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    init(_ yError2: YError2Channel, field: FieldNameRepresentable, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        /// Creates this encoding with the value mapped to the given field name in the data.
        self.deriveChannel = { .init($0) }
        self.def = .init(field: .init(field.fieldName))
    }
}

/// Field Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.YError2Encoding, Def == GG.ValueDefNumber {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.ValueDefNumber { def }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ yError2: YError2Channel, value constant: Double, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: constant)
    }
}



// MARK: VizEncode: column


public extension VizEncode where Channel == GG.EncodingChannelMap.ColumnEncoding {
    enum ColumnChannel {
        /// Facet, row and column are special encoding channels that facets single plots into trellis plots (or small multiples).
        case column
    }

    typealias ChannelFieldType = Channel.RawValue
}

/// Empty Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.ColumnEncoding, Def == GG.RowColumnEncodingFieldDef {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.RowColumnEncodingFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ column: ColumnChannel, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init($0) }
        self.def = .init()
    }

    init(_ column: ColumnChannel, field: FieldNameRepresentable, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        /// Creates this encoding with the value mapped to the given field name in the data.
        self.deriveChannel = { .init($0) }
        self.def = .init(field: .init(field.fieldName))
    }
}

// MARK: VizEncode: row


public extension VizEncode where Channel == GG.EncodingChannelMap.RowEncoding {
    enum RowChannel {
        /// Facet, row and column are special encoding channels that facets single plots into trellis plots (or small multiples).
        case row
    }

    typealias ChannelFieldType = Channel.RawValue
}

/// Empty Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.RowEncoding, Def == GG.RowColumnEncodingFieldDef {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.RowColumnEncodingFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ row: RowChannel, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init($0) }
        self.def = .init()
    }

    init(_ row: RowChannel, field: FieldNameRepresentable, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        /// Creates this encoding with the value mapped to the given field name in the data.
        self.deriveChannel = { .init($0) }
        self.def = .init(field: .init(field.fieldName))
    }
}




// MARK: VizEncode: facet


public extension VizEncode where Channel == GG.EncodingChannelMap.FacetEncoding {
    enum FacetChannel {
        /// Facet, row and column are special encoding channels that facets single plots into trellis plots (or small multiples).
        case facet
    }

    typealias ChannelFieldType = Channel.RawValue
}

/// Empty Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.FacetEncoding, Def == GG.FacetEncodingFieldDef {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.FacetEncodingFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ facet: FacetChannel, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init($0) }
        self.def = .init()
    }

    init(_ facet: FacetChannel, field: FieldNameRepresentable, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        /// Creates this encoding with the value mapped to the given field name in the data.
        self.deriveChannel = { .init($0) }
        self.def = .init(field: .init(field.fieldName))
    }
}


// MARK: VizEncode: latitude

public extension VizEncode where Channel == GG.EncodingChannelMap.LatitudeEncoding {
    enum LatitudeChannel {
        /// Longitude and latitude channels can be used to encode geographic coordinate data via a projection. In addition, longitude2 and latitude2 can specify the span of geographically projected ranged area, bar, rect, and rule.
        case latitude
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelValueType = Channel.RawValue.RawValue.T2

//    func fieldType(for field: Self.ChannelFieldType) -> Self.ChannelFieldType { field }
}

/// Empty Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.LatitudeEncoding, Def == GG.LatLongFieldDef {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.LatLongFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ latitude: LatitudeChannel, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ latitude: LatitudeChannel, field: FieldNameRepresentable, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ latitude: LatitudeChannel, repeat: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.LatitudeEncoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.DatumDef { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ latitude: LatitudeChannel, datum: ExplicitNull, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ latitude: LatitudeChannel, datum: Double, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ latitude: LatitudeChannel, datum: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ latitude: LatitudeChannel, datum: Bool, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ latitude: LatitudeChannel, datum: GG.DateTime, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ latitude: LatitudeChannel, expression: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ latitude: LatitudeChannel, datum: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}


// MARK: VizEncode: longitude


public extension VizEncode where Channel == GG.EncodingChannelMap.LongitudeEncoding {
    enum LongitudeChannel {
        /// Longitude and latitude channels can be used to encode geographic coordinate data via a projection. In addition, longitude2 and latitude2 can specify the span of geographically projected ranged area, bar, rect, and rule.
        case longitude
    }
    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelValueType = Channel.RawValue.RawValue.T2
}

/// Empty Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.LongitudeEncoding, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.LatLongFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ longitude: LongitudeChannel, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ longitude: LongitudeChannel, field: FieldNameRepresentable, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ longitude: LongitudeChannel, repeat: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.LongitudeEncoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.DatumDef { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ longitude: LongitudeChannel, datum: ExplicitNull, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ longitude: LongitudeChannel, datum: Double, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ longitude: LongitudeChannel, datum: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ longitude: LongitudeChannel, datum: Bool, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ longitude: LongitudeChannel, datum: GG.DateTime, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ longitude: LongitudeChannel, expression: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ longitude: LongitudeChannel, datum: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}



// MARK: VizEncode: latitude2


public extension VizEncode where Channel == GG.EncodingChannelMap.Latitude2Encoding {
    enum Latitude2Channel {
        /// Longitude and latitude channels can be used to encode geographic coordinate data via a projection. In addition, longitude2 and latitude2 can specify the span of geographically projected ranged area, bar, rect, and rule.
        case latitude2
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Empty Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.Latitude2Encoding, Def == GG.SecondaryFieldDef {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.SecondaryFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ latitude2: Latitude2Channel, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ latitude2: Latitude2Channel, field: FieldNameRepresentable, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ latitude2: Latitude2Channel, repeat: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.Latitude2Encoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.DatumDef { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ latitude2: Latitude2Channel, datum: ExplicitNull, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ latitude2: Latitude2Channel, datum: Double, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ latitude2: Latitude2Channel, datum: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ latitude2: Latitude2Channel, datum: Bool, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ latitude2: Latitude2Channel, datum: GG.DateTime, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ latitude2: Latitude2Channel, expression: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ latitude2: Latitude2Channel, datum: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}


// MARK: VizEncode: longitude2


public extension VizEncode where Channel == GG.EncodingChannelMap.Longitude2Encoding {
    enum Longitude2Channel {
        /// Longitude and latitude channels can be used to encode geographic coordinate data via a projection. In addition, longitude2 and latitude2 can specify the span of geographically projected ranged area, bar, rect, and rule.
        case longitude2
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Empty Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.Longitude2Encoding, Def == GG.SecondaryFieldDef {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.SecondaryFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ longitude2: Longitude2Channel, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ longitude2: Longitude2Channel, field: FieldNameRepresentable, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ longitude2: Longitude2Channel, repeat: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.Longitude2Encoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.DatumDef { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ longitude2: Longitude2Channel, datum: ExplicitNull, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ longitude2: Longitude2Channel, datum: Double, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ longitude2: Longitude2Channel, datum: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ longitude2: Longitude2Channel, datum: Bool, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ longitude2: Longitude2Channel, datum: GG.DateTime, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ longitude2: Longitude2Channel, expression: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ longitude2: Longitude2Channel, datum: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}



// MARK: VizEncode: href

public extension VizEncode where Channel == GG.EncodingChannelMap.HrefEncoding {
    enum HrefChannel {
        /// A URL to load upon mouse click.
        case href
    }

    typealias ChannelFieldType = Channel.RawValue.T1
    typealias ChannelValueType = Channel.RawValue.T2
}

/// Field Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.HrefEncoding, Def == Channel.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.FieldOrDatumDefWithConditionStringFieldDefString { def }

    /// Creates an empty instance of this encoding.
    init(_ href: HrefChannel, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ href: HrefChannel, field: FieldNameRepresentable, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ href: HrefChannel, repeat: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }
}

/// Value Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.HrefEncoding, Def == GG.StringValueDefWithCondition {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.ValueDefWithConditionMarkPropFieldOrDatumDefStringNull { def }

    /// Creates this encoding with the given constant value.
    init(_ href: HrefChannel, value constant: ExplicitNull, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ href: HrefChannel, value constant: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(.init(value)))
    }

    /// Creates this encoding with a dynamic expression.
    init(_ href: HrefChannel, expr expression: GG.ExprRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2.T2 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(.init(value))) // ambiguous with the other expr init?
    }
}


// MARK: VizEncode: description

public extension VizEncode where Channel == GG.EncodingChannelMap.DescriptionEncoding {
    enum DescriptionChannel {
        /// A text description of this mark for ARIA accessibility. For SVG output the "aria-label" attribute will be set to this description.
        case description
    }

    typealias ChannelFieldType = Channel.RawValue.T1
    typealias ChannelValueType = Channel.RawValue.T2
}

/// Field Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.DescriptionEncoding, Def == Channel.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.FieldOrDatumDefWithConditionStringFieldDefString { def }

    /// Creates an empty instance of this encoding.
    init(_ description: DescriptionChannel, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ description: DescriptionChannel, field: FieldNameRepresentable, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ description: DescriptionChannel, repeat: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }
}

/// Value Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.DescriptionEncoding, Def == GG.StringValueDefWithCondition {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.ValueDefWithConditionMarkPropFieldOrDatumDefStringNull { def }

    /// Creates this encoding with the given constant value.
    init(_ description: DescriptionChannel, value constant: ExplicitNull, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ description: DescriptionChannel, value constant: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(.init(value)))
    }

    /// Creates this encoding with a dynamic expression.
    init(_ description: DescriptionChannel, expr expression: GG.ExprRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2.T2 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(.init(value))) // ambiguous with the other expr init?
    }
}

// MARK: VizEncode: url

public extension VizEncode where Channel == GG.EncodingChannelMap.UrlEncoding {
    enum UrlChannel {
        case url
    }

    typealias ChannelFieldType = Channel.RawValue.T1
    typealias ChannelValueType = Channel.RawValue.T2
}

/// Field Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.UrlEncoding, Def == Channel.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.FieldOrDatumDefWithConditionStringFieldDefString { def }

    /// Creates an empty instance of this encoding.
    init(_ url: UrlChannel, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ url: UrlChannel, field: FieldNameRepresentable, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ url: UrlChannel, repeat: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }
}

/// Value Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.UrlEncoding, Def == Channel.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.StringValueDefWithCondition { def }

    /// Creates this encoding with the given constant value.
    init(_ url: UrlChannel, value constant: ExplicitNull, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ url: UrlChannel, value constant: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(.init(value)))
    }

    /// Creates this encoding with a dynamic expression.
    init(_ url: UrlChannel, expr expression: GG.ExprRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2.T2 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(.init(value))) // ambiguous with the other expr init?
    }
}


// MARK: VizEncode: strokeDash

public extension VizEncode where Channel == GG.EncodingChannelMap.StrokeDashEncoding {
    enum StrokeDashChannel {
        /// Stroke dash of the marks.
        ///
        /// Default value: [1,0] (No dash).
        case strokeDash
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}


/// Field Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.StrokeDashEncoding, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.FieldOrDatumDefWithConditionMarkPropFieldDefNumberArray { def }

    /// Creates an empty instance of this encoding.
    init(_ strokeDash: StrokeDashChannel, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ strokeDash: StrokeDashChannel, field: FieldNameRepresentable, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ strokeDash: StrokeDashChannel, repeat: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }
}

public extension VizEncode where Channel == GG.EncodingChannelMap.StrokeDashEncoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.FieldOrDatumDefWithConditionDatumDefNumberArray { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeDash: StrokeDashChannel, datum: ExplicitNull, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeDash: StrokeDashChannel, datum: Double, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeDash: StrokeDashChannel, datum: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeDash: StrokeDashChannel, datum: Bool, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeDash: StrokeDashChannel, datum: GG.DateTime, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeDash: StrokeDashChannel, expression: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ strokeDash: StrokeDashChannel, datum: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

public extension VizEncode where Channel == GG.EncodingChannelMap.StrokeDashEncoding, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.ValueDefWithConditionMarkPropFieldOrDatumDefNumberArray { def }

    /// Creates this encoding with the given constant value.
    init(_ strokeDash: StrokeDashChannel, value constant: [Double], @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with a dynamic expression.
    init(_ strokeDash: StrokeDashChannel, expr expression: GG.ExprRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }
}


// MARK: VizEncode: key

public extension VizEncode where Channel == GG.EncodingChannelMap.KeyEncoding {
    enum KeyChannel {
        case key
    }

    typealias ChannelFieldType = Channel.RawValue
}

/// Field Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.KeyEncoding, Def == Channel.RawValue {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.TypedFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ key: KeyChannel, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init($0) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ key: KeyChannel, field: FieldNameRepresentable, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init($0) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ key: KeyChannel, repeat: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init($0) }
        self.def = .init(field: .init(`repeat`))
    }
}


// MARK: VizEncode: shape

public extension VizEncode where Channel == GG.EncodingChannelMap.ShapeEncoding {
    enum ShapeChannel {
        /// Shape of the mark.
        ///
        /// - For point marks the supported values include: - plotting shapes: "circle", "square", "cross", "diamond", "triangle-up", "triangle-down", "triangle-right", or "triangle-left". - the line symbol "stroke" - centered directional shapes "arrow", "wedge", or "triangle" - a custom SVG path string (For correct sizing, custom shape paths should be defined within a square bounding box with coordinates ranging from -1 to 1 along both the x and y dimensions.)
        /// - For geoshape marks it should be a field definition of the geojson data
        ///
        /// Default value: If undefined, the default shape depends on mark config???s shape property. ("circle" if unset.)
        case shape
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Field Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.ShapeEncoding, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.FieldOrDatumDefWithConditionMarkPropFieldDefTypeForShapeStringNull { def }

    /// Creates an empty instance of this encoding.
    init(_ shape: ShapeChannel, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ shape: ShapeChannel, field: FieldNameRepresentable, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ shape: ShapeChannel, repeat: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.ShapeEncoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.FieldOrDatumDefWithConditionDatumDefStringNull { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ shape: ShapeChannel, datum: ExplicitNull, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ shape: ShapeChannel, datum: Double, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ shape: ShapeChannel, datum: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ shape: ShapeChannel, datum: Bool, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ shape: ShapeChannel, datum: GG.DateTime, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ shape: ShapeChannel, expression: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ shape: ShapeChannel, datum: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.ShapeEncoding, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.ValueDefWithConditionMarkPropFieldOrDatumDefTypeForShapeStringNull { def }

    /// Creates this encoding with the given constant value.
    init(_ shape: ShapeChannel, value constant: GG.SymbolShape?, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Nullable<GG.SymbolShape> = constant.map({ Nullable($0) }) ?? .v1(ExplicitNull())
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: value)
    }
}



// MARK: VizEncode: detail

public extension VizEncode where Channel == GG.EncodingChannelMap.DetailEncoding {
    enum DetailChannel {
        case detail
    }

    typealias ChannelFieldType = Channel.RawValue.T1 // TypedFieldDef
    typealias ChannelMultiFieldType = Channel.RawValue.T2 // [TypedFieldDef]
}

public extension VizEncode where Channel == GG.EncodingChannelMap.DetailEncoding, Def == Channel.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.TypedFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ detail: DetailChannel, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ detail: DetailChannel, field: FieldNameRepresentable, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ detail: DetailChannel, repeat: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }
}


// MARK: VizEncode: order

public extension VizEncode where Channel == GG.EncodingChannelMap.OrderEncoding {
    enum OrderChannel {
        case order
    }

    typealias ChannelFieldType = Channel.RawValue.T1.T1 // OrderFieldDef
    typealias ChannelMultiFieldType = Channel.RawValue.T1.T2 // [OrderFieldDef]
    typealias ChannelValueType = Channel.RawValue.T2 // OrderValueDef

}

public extension VizEncode where Channel == GG.EncodingChannelMap.OrderEncoding, Def == Channel.RawValue.T1.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.OrderFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ order: OrderChannel, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ order: OrderChannel, field: FieldNameRepresentable, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ order: OrderChannel, repeat: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }
}

public extension VizEncode where Channel == GG.EncodingChannelMap.OrderEncoding, Def == Channel.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.OrderValueDef { def }

    /// Creates this encoding with the given constant value.
    init(_ order: OrderChannel, value constant: Double, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with a dynamic expression.
    init(_ order: OrderChannel, expr expression: GG.ExprRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }
}

// MARK: VizEncode: text

public extension VizEncode where Channel == GG.EncodingChannelMap.TextEncoding {
    enum TextChannel {
        case text
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Field Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.TextEncoding, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.FieldOrDatumDefWithConditionStringFieldDefText { def }

    /// Creates an empty instance of this encoding.
    init(_ text: TextChannel, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ text: TextChannel, field: FieldNameRepresentable, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ text: TextChannel, repeat: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.TextEncoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.FieldOrDatumDefWithConditionStringDatumDefText { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ text: TextChannel, datum: ExplicitNull, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ text: TextChannel, datum: Double, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ text: TextChannel, datum: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ text: TextChannel, datum: Bool, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ text: TextChannel, datum: GG.DateTime, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ text: TextChannel, expression: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ text: TextChannel, datum: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == GG.EncodingChannelMap.TextEncoding, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.ValueDefWithConditionStringFieldDefText { def }

    /// Creates this encoding with the given constant value.
    init(_ text: TextChannel, value string: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(.init(string)))
    }

    /// Creates this encoding with the given constant value.
    init(_ text: TextChannel, values stringArray: [String], @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(.init(stringArray)))
    }

    /// Creates this encoding with a dynamic expression.
    init(_ text: TextChannel, expression: GG.ExprRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(expression))
    }

}



// MARK: VizEncode: tooltip

public extension VizEncode where Channel == GG.EncodingChannelMap.TooltipEncoding {
    enum TooltipChannel {
        case tooltip
    }

    typealias ChannelNullType = Channel.RawValue.T1
    typealias ChannelFieldType = Channel.RawValue.T2.T1
    typealias ChannelValueType = Channel.RawValue.T2.T2
    typealias ChannelMultiFieldType = Channel.RawValue.T2.T3
}

public extension VizEncode where Channel == GG.EncodingChannelMap.TooltipEncoding, Def == Channel.RawValue.T2.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.StringFieldDefWithCondition { def }

    /// Creates an empty instance of this encoding.
    init(_ tooltip: TooltipChannel, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ tooltip: TooltipChannel, field: FieldNameRepresentable, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ tooltip: TooltipChannel, repeat: GG.RepeatRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }
}

public extension VizEncode where Channel == GG.EncodingChannelMap.TooltipEncoding, Def == Channel.RawValue.T2.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> GG.StringValueDefWithCondition { def }

    /// Creates this encoding with the given constant value.
    init(_ tooltip: TooltipChannel, value null: ExplicitNull, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T1 = null
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(.init(value)))
    }

    /// Creates this encoding with the given constant value.
    init(_ tooltip: TooltipChannel, value constant: String, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(.init(value)))
    }

    /// Creates this encoding with a dynamic expression.
    init(_ tooltip: TooltipChannel, expr expression: GG.ExprRef, @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2.T2 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(.init(value)))
    }
}

public extension VizEncode where Channel == GG.EncodingChannelMap.TooltipEncoding, Def == Channel.RawValue.T2.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> [GG.StringFieldDef] { def }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ tooltip: TooltipChannel, fields: [FieldNameRepresentable], @ChildElementBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = fields.map {
            GG.StringFieldDef(field: .init($0.fieldName))
        }
    }
}


private func emptyConstructor(channel: EncodingChannel) -> VizMarkElementType {
    switch channel {
    case .x: return VizEncode(.x)
    case .y: return VizEncode(.y)
    case .x2: return VizEncode(.x2)
    case .y2: return VizEncode(.y2)

    case .color: return VizEncode(.color)
    case .opacity: return VizEncode(.opacity)

    case .fill: return VizEncode(.fill)
    case .fillOpacity: return VizEncode(.fillOpacity)

    case .size: return VizEncode(.size)

    case .angle: return VizEncode(.angle)
    case .theta: return VizEncode(.theta)
    case .theta2: return VizEncode(.theta2)
    case .radius: return VizEncode(.radius)
    case .radius2: return VizEncode(.radius2)

    case .stroke: return VizEncode(.stroke)
    case .strokeOpacity: return VizEncode(.strokeOpacity)
    case .strokeWidth: return VizEncode(.strokeWidth)

    case .xError: return VizEncode(.xError)
    case .xError2: return VizEncode(.xError2)
    case .yError: return VizEncode(.yError)
    case .yError2: return VizEncode(.yError2)

    case .column: return VizEncode(.column)
    case .row: return VizEncode(.row)
    case .facet: return VizEncode(.facet)

    case .latitude: return VizEncode(.latitude)
    case .latitude2: return VizEncode(.latitude2)
    case .longitude: return VizEncode(.longitude)
    case .longitude2: return VizEncode(.longitude2)

    case .href: return VizEncode(.href)
    case .url: return VizEncode(.url)
    case .description: return VizEncode(.description)
    case .key: return VizEncode(.key)

    case .strokeDash: return VizEncode(.strokeDash)

    case .shape: return VizEncode(.shape)

    case .detail: return VizEncode(.detail)
    case .order: return VizEncode(.order)

    case .text: return VizEncode(.text)

    case .tooltip: return VizEncode(.tooltip)
    }
}



// MARK: VizEncodingChannelType Multi-Field


extension GG.EncodingChannelMap.DetailEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .detail
    public typealias ChildElement = VizUnguidedEncodeElementType

    public func addChannel(to encodings: inout GG.EncodingChannelMap, elements: [VizEncodeElementType]) {
        // when adding to an encodings that already has a detail field, we append the new encoding to the existing one
        let defs = (encodings.detail?.rawValue.array ?? []) + self.rawValue.array

        // reduce to a single field encoding
        if let field = defs.first, defs.count == 1 {
            encodings.detail = .init(field)
        } else {
            encodings.detail = .init(defs)
        }
    }
}

extension GG.EncodingChannelMap.OrderEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .order
    public typealias ChildElement = VizUnguidedEncodeElementType

    public func addChannel(to encodings: inout GG.EncodingChannelMap, elements: [VizEncodeElementType]) {
        switch self.rawValue {
        case .v1(let oneOrManyFields):
            // merge multiple order fields into a single encoding
            let defs = (encodings.order?.rawValue.v1?.array ?? []) + oneOrManyFields.array
            // reduce to a single field encoding
            if let field = defs.first, defs.count == 1 {
                encodings.order = .init(.init(field))
            } else {
                encodings.order = .init(.init(defs))
            }
        case .v2(let value):
            if encodings.order != nil {
                // value clobbers any previous
                warnReplaceEncoding(self)
            }
            encodings.order = .init(value)
        }
    }
}


extension GG.EncodingChannelMap.TooltipEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .tooltip
    public typealias ChildElement = VizUnguidedEncodeElementType

    public func addChannel(to encodings: inout GG.EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.tooltip != nil {
            // TODO: in theory, we could handle the special case of one tooltip with an array of fields being added to another tooltip with an array of fields???
            warnReplaceEncoding(self)
        }
        encodings.tooltip = assignElementItems(elements)
    }
}



// MARK: VizEncodingChannelType Single-Field

extension GG.EncodingChannelMap.TextEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .text
    public typealias ChildElement = VizUnguidedEncodeElementType

    public func addChannel(to encodings: inout GG.EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.text != nil {
            warnReplaceEncoding(self)
        }
        encodings.text = assignElementItems(elements)
    }
}

extension GG.EncodingChannelMap.AngleEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .angle
    public typealias ChildElement = VizPolarEncodeElementType

    public func addChannel(to encodings: inout GG.EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.angle != nil {
            warnReplaceEncoding(self)
        }
        encodings.angle = assignElementItems(elements, legendKey: \.rawValue.rawValue[routing: \.legend, \.[noop: false], \.[noop: false]])
    }
}

extension GG.EncodingChannelMap.ColorEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .color
    public typealias ChildElement = VizMarkPropertyEncodeElementType

    public func addChannel(to encodings: inout GG.EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.color != nil {
            warnReplaceEncoding(self)
        }
        encodings.color = assignElementItems(elements, scaleKey: \.rawValue.rawValue[routing: \.scale, \.[noop: false], \.[noop: false]], legendKey: \.rawValue.rawValue[routing: \.legend, \.[noop: false], \.[noop: false]])
    }
}

extension GG.EncodingChannelMap.DescriptionEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .description
    public typealias ChildElement = VizUnguidedEncodeElementType

    public func addChannel(to encodings: inout GG.EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.description != nil {
            warnReplaceEncoding(self)
        }
        encodings.description = assignElementItems(elements)
    }
}

extension GG.EncodingChannelMap.FillEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .fill
    public typealias ChildElement = VizMarkPropertyEncodeElementType

    public func addChannel(to encodings: inout GG.EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.fill != nil {
            warnReplaceEncoding(self)
        }
        encodings.fill = assignElementItems(elements, scaleKey: \.rawValue.rawValue[routing: \.scale, \.[noop: false], \.[noop: false]], legendKey: \.rawValue.rawValue[routing: \.legend, \.[noop: false], \.[noop: false]])
    }
}

extension GG.EncodingChannelMap.FillOpacityEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .fillOpacity
    public typealias ChildElement = VizMarkPropertyEncodeElementType

    public func addChannel(to encodings: inout GG.EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.fillOpacity != nil {
            warnReplaceEncoding(self)
        }
        encodings.fillOpacity = assignElementItems(elements, scaleKey: \.rawValue.rawValue[routing: \.scale, \.[noop: false], \.[noop: false]], legendKey: \.rawValue.rawValue[routing: \.legend, \.[noop: false], \.[noop: false]])
    }
}

extension GG.EncodingChannelMap.HrefEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .href
    public typealias ChildElement = VizUnguidedEncodeElementType

    public func addChannel(to encodings: inout GG.EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.href != nil {
            warnReplaceEncoding(self)
        }
        encodings.href = assignElementItems(elements)
    }
}

extension GG.EncodingChannelMap.LatitudeEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .latitude
    public typealias ChildElement = VizUnguidedEncodeElementType

    public func addChannel(to encodings: inout GG.EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.latitude != nil {
            warnReplaceEncoding(self)
        }
        encodings.latitude = assignElementItems(elements)
    }
}

extension GG.EncodingChannelMap.Latitude2Encoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .latitude2
    public typealias ChildElement = VizUnguidedEncodeElementType

    public func addChannel(to encodings: inout GG.EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.latitude2 != nil {
            warnReplaceEncoding(self)
        }
        encodings.latitude2 = assignElementItems(elements)
    }
}

extension GG.EncodingChannelMap.LongitudeEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .longitude
    public typealias ChildElement = VizUnguidedEncodeElementType

    public func addChannel(to encodings: inout GG.EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.longitude != nil {
            warnReplaceEncoding(self)
        }
        encodings.longitude = assignElementItems(elements)
    }
}

extension GG.EncodingChannelMap.Longitude2Encoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .longitude2
    public typealias ChildElement = VizUnguidedEncodeElementType

    public func addChannel(to encodings: inout GG.EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.longitude2 != nil {
            warnReplaceEncoding(self)
        }
        encodings.longitude2 = assignElementItems(elements)
    }
}

extension GG.EncodingChannelMap.OpacityEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .opacity
    public typealias ChildElement = VizMarkPropertyEncodeElementType

    public func addChannel(to encodings: inout GG.EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.opacity != nil {
            warnReplaceEncoding(self)
        }
        encodings.opacity = assignElementItems(elements, scaleKey: \.rawValue.rawValue[routing: \.scale, \.[noop: false], \.[noop: false]], legendKey: \.rawValue.rawValue[routing: \.legend, \.[noop: false], \.[noop: false]])
    }
}


extension GG.EncodingChannelMap.RadiusEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .radius
    public typealias ChildElement = VizPolarEncodeElementType

    public func addChannel(to encodings: inout GG.EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.radius != nil {
            warnReplaceEncoding(self)
        }
        encodings.radius = assignElementItems(elements, scaleKey: \.rawValue.rawValue[routing: \.scale, \.scale, \.[noop: false]])
    }
}

extension GG.EncodingChannelMap.Radius2Encoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .radius2
    public typealias ChildElement = VizPolarEncodeElementType

    public func addChannel(to encodings: inout GG.EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.radius2 != nil {
            warnReplaceEncoding(self)
        }
        encodings.radius2 = assignElementItems(elements)
    }
}

extension GG.EncodingChannelMap.ShapeEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .shape
    public typealias ChildElement = VizMarkPropertyEncodeElementType

    public func addChannel(to encodings: inout GG.EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.shape != nil {
            warnReplaceEncoding(self)
        }
        encodings.shape = assignElementItems(elements, scaleKey: \.rawValue.rawValue[routing: \.scale, \.[noop: false], \.[noop: false]], legendKey: \.rawValue.rawValue[routing: \.legend, \.[noop: false], \.[noop: false]])
    }
}

extension GG.EncodingChannelMap.SizeEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .size
    public typealias ChildElement = VizMarkPropertyEncodeElementType

    public func addChannel(to encodings: inout GG.EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.size != nil {
            warnReplaceEncoding(self)
        }
        encodings.size = assignElementItems(elements, scaleKey: \.rawValue.rawValue[routing: \.scale, \.[noop: false], \.[noop: false]], legendKey: \.rawValue.rawValue[routing: \.legend, \.[noop: false], \.[noop: false]])
    }
}

extension GG.EncodingChannelMap.StrokeEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .stroke
    public typealias ChildElement = VizMarkPropertyEncodeElementType

    public func addChannel(to encodings: inout GG.EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.stroke != nil {
            warnReplaceEncoding(self)
        }
        encodings.stroke = assignElementItems(elements, scaleKey: \.rawValue.rawValue[routing: \.scale, \.[noop: false], \.[noop: false]], legendKey: \.rawValue.rawValue[routing: \.legend, \.[noop: false], \.[noop: false]])
    }
}

extension GG.EncodingChannelMap.StrokeDashEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .strokeDash
    public typealias ChildElement = VizMarkPropertyEncodeElementType

    public func addChannel(to encodings: inout GG.EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.strokeDash != nil {
            warnReplaceEncoding(self)
        }
        encodings.strokeDash = assignElementItems(elements, scaleKey: \.rawValue.rawValue[routing: \.scale, \.[noop: false], \.[noop: false]], legendKey: \.rawValue.rawValue[routing: \.legend, \.[noop: false], \.[noop: false]])
    }
}

extension GG.EncodingChannelMap.StrokeOpacityEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .strokeOpacity
    public typealias ChildElement = VizMarkPropertyEncodeElementType

    public func addChannel(to encodings: inout GG.EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.strokeOpacity != nil {
            warnReplaceEncoding(self)
        }
        encodings.strokeOpacity = assignElementItems(elements, scaleKey: \.rawValue.rawValue[routing: \.scale, \.[noop: false], \.[noop: false]], legendKey: \.rawValue.rawValue[routing: \.legend, \.[noop: false], \.[noop: false]])
    }
}

extension GG.EncodingChannelMap.StrokeWidthEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .strokeWidth
    public typealias ChildElement = VizMarkPropertyEncodeElementType

    public func addChannel(to encodings: inout GG.EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.strokeWidth != nil {
            warnReplaceEncoding(self)
        }
        encodings.strokeWidth = assignElementItems(elements, scaleKey: \.rawValue.rawValue[routing: \.scale, \.[noop: false], \.[noop: false]], legendKey: \.rawValue.rawValue[routing: \.legend, \.[noop: false], \.[noop: false]])
    }
}

extension GG.EncodingChannelMap.ThetaEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .theta
    public typealias ChildElement = VizPolarEncodeElementType

    public func addChannel(to encodings: inout GG.EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.theta != nil {
            warnReplaceEncoding(self)
        }
        encodings.theta = assignElementItems(elements, scaleKey: \.rawValue.rawValue[routing: \.scale, \.scale, \.[noop: false]])
    }
}

extension GG.EncodingChannelMap.Theta2Encoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .theta2
    public typealias ChildElement = VizPolarEncodeElementType

    public func addChannel(to encodings: inout GG.EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.theta2 != nil {
            warnReplaceEncoding(self)
        }
        encodings.theta2 = assignElementItems(elements)
    }
}


extension GG.EncodingChannelMap.UrlEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .url
    public typealias ChildElement = VizUnguidedEncodeElementType

    public func addChannel(to encodings: inout GG.EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.url != nil {
            warnReplaceEncoding(self)
        }
        encodings.url = assignElementItems(elements)
    }
}


extension VizEncodingChannelType {
    fileprivate func assignElementItems(_ elements: [VizEncodeElementType], scaleKey: WritableKeyPath<Self, Nullable<GG.ScaleDef>?>? = nil, axisKey: WritableKeyPath<Self, Nullable<GG.AxisDef>?>? = nil, legendKey: WritableKeyPath<Self, Nullable<GG.LegendDef>?>? = nil, headerKey: WritableKeyPath<Self, Nullable<GG.HeaderDef>?>? = nil) -> Self {
        var this = self

        for element in elements {
            if let axis = element.axis, let axisKey = axisKey {
                this[keyPath: axisKey] = .init(axis)
            }

            if let legend = element.legend, let legendKey = legendKey {
                this[keyPath: legendKey] = .init(legend)
            }

            if let header = element.header, let headerKey = headerKey {
                this[keyPath: headerKey] = .init(header)
            }

            if let scale = element.scale, let scaleKey = scaleKey {
                this[keyPath: scaleKey] = .init(scale)
            }

        }
        return this
    }
}

extension GG.EncodingChannelMap.XEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .x
    public typealias ChildElement = VizPositionalEncodeElementType

    public func addChannel(to encodings: inout GG.EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.x != nil {
            warnReplaceEncoding(self)
        }

        encodings.x = assignElementItems(elements, scaleKey: \.rawValue.rawValue[routing: \.scale, \.scale, \.[noop: false]], axisKey: \.rawValue.rawValue[routing: \.axis, \.axis, \.[noop: false]])
    }
}

extension GG.EncodingChannelMap.X2Encoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .x2
    public typealias ChildElement = VizUnguidedEncodeElementType

    public func addChannel(to encodings: inout GG.EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.x2 != nil {
            warnReplaceEncoding(self)
        }
        encodings.x2 = assignElementItems(elements)
    }
}

extension GG.EncodingChannelMap.XErrorEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .xError
    public typealias ChildElement = VizUnguidedEncodeElementType

    public func addChannel(to encodings: inout GG.EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.xError != nil {
            warnReplaceEncoding(self)
        }
        encodings.xError = assignElementItems(elements)
    }
}

extension GG.EncodingChannelMap.XError2Encoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .xError2
    public typealias ChildElement = VizUnguidedEncodeElementType

    public func addChannel(to encodings: inout GG.EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.xError2 != nil {
            warnReplaceEncoding(self)
        }
        encodings.xError2 = assignElementItems(elements)
    }
}

extension GG.EncodingChannelMap.YEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .y
    public typealias ChildElement = VizPositionalEncodeElementType

    public func addChannel(to encodings: inout GG.EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.y != nil {
            warnReplaceEncoding(self)
        }
        encodings.y = assignElementItems(elements, scaleKey: \.rawValue.rawValue[routing: \.scale, \.scale, \.[noop: false]], axisKey: \.rawValue.rawValue[routing: \.axis, \.axis, \.[noop: false]])

    }
}

extension GG.EncodingChannelMap.Y2Encoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .y2
    public typealias ChildElement = VizUnguidedEncodeElementType

    public func addChannel(to encodings: inout GG.EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.y2 != nil {
            warnReplaceEncoding(self)
        }
        encodings.y2 = assignElementItems(elements)
    }
}

extension GG.EncodingChannelMap.YErrorEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .yError
    public typealias ChildElement = VizUnguidedEncodeElementType

    public func addChannel(to encodings: inout GG.EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.yError != nil {
            warnReplaceEncoding(self)
        }
        encodings.yError = assignElementItems(elements)
    }
}

extension GG.EncodingChannelMap.YError2Encoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .yError2
    public typealias ChildElement = VizUnguidedEncodeElementType

    public func addChannel(to encodings: inout GG.EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.yError2 != nil {
            warnReplaceEncoding(self)
        }
        encodings.yError2 = assignElementItems(elements)
    }
}

extension GG.EncodingChannelMap.RowEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .row
    public typealias ChildElement = VizFacetEncodeElementType

    public func addChannel(to encodings: inout GG.EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.row != nil {
            warnReplaceEncoding(self)
        }
        encodings.row = assignElementItems(elements, headerKey: \.rawValue.header)
    }
}

extension GG.EncodingChannelMap.ColumnEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .column
    public typealias ChildElement = VizFacetEncodeElementType

    public func addChannel(to encodings: inout GG.EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.column != nil {
            warnReplaceEncoding(self)
        }
        encodings.column = assignElementItems(elements, headerKey: \.rawValue.header)
    }
}

extension GG.EncodingChannelMap.FacetEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .facet
    public typealias ChildElement = VizFacetEncodeElementType

    public func addChannel(to encodings: inout GG.EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.facet != nil {
            warnReplaceEncoding(self)
        }
        encodings.facet = assignElementItems(elements, headerKey: \.rawValue.header)
    }
}

extension GG.EncodingChannelMap.KeyEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .key
    public typealias ChildElement = VizUnguidedEncodeElementType

    public func addChannel(to encodings: inout GG.EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.key != nil {
            warnReplaceEncoding(self)
        }
        encodings.key = assignElementItems(elements)
    }
}
