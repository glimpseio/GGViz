

/// A type that can be used to create a field value
public protocol FieldNameRepresentable {
    /// The `GGSpec.Field` form of this specification
    var fieldName: FieldName { get }
}

extension String : FieldNameRepresentable {
    public var fieldName: FieldName { .init(self) }
}

extension FieldName : FieldNameRepresentable {
    public var fieldName: FieldName { self }
}



#if canImport(TabularData)
import TabularData

extension AnyColumnProtocol {
    /// Returns a `Field` form of this column
    public var fieldName: FieldName { .init(FieldName(name)) }
}

extension ColumnProtocol {
    /// Returns a `Field` form of this column
    public var fieldName: FieldName { .init(FieldName(name)) }
}

extension TabularData.AnyColumn : FieldNameRepresentable { }
extension TabularData.AnyColumnSlice : FieldNameRepresentable { }
extension TabularData.Column : FieldNameRepresentable { }
extension TabularData.ColumnSlice : FieldNameRepresentable { }
extension TabularData.DiscontiguousColumnSlice : FieldNameRepresentable { }
extension TabularData.FilledColumn : FieldNameRepresentable { }

#endif

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
    var encodings: FacetedEncoding { get }
}

public protocol VizMarkDefType : Pure {
    var anyMark: AnyMark { get }
}

extension MarkDef : VizMarkDefType {
    public var anyMark: AnyMark { .init(self) }
}

extension BoxPlotDef : VizMarkDefType {
    public var anyMark: AnyMark { .init(.init(self)) }
}

extension ErrorBarDef : VizMarkDefType {
    public var anyMark: AnyMark { .init(.init(self)) }
}

extension ErrorBandDef : VizMarkDefType {
    public var anyMark: AnyMark { .init(.init(self)) }
}


public protocol VizTransformDefType : Pure {
    var anyTransform: DataTransformation { get }
}


@dynamicMemberLookup
public struct VizTheme : VizSpecElementType, VizDSLType {
    var config: GGSpec.ConfigTheme

    public init(config: GGSpec.ConfigTheme = GGSpec.ConfigTheme()) {
        self.config = config
    }
    
    public func add<M>(to spec: inout VizSpec<M>) where M : Pure {
        spec.config = config
    }

    /// Creates a setter function for the given dynamic keypath, allowing a fluent API for all the public properties of the instance
    public subscript<U>(dynamicMember keyPath: WritableKeyPath<GGSpec.ConfigTheme, U>) -> (U) -> (Self) {
        setting(path: (\Self.config).appending(path: keyPath))
    }
}

@dynamicMemberLookup
public struct VizProjection : VizSpecElementType, VizDSLType {
    var projection: GGSpec.Projection

    public init(_ type: ProjectionType? = nil, projection: GGSpec.Projection = GGSpec.Projection()) {
        self.projection = projection
        if let type = type {
            self.projection.type = .init(.init(type))
        }
    }

    public func add<M>(to spec: inout VizSpec<M>) where M : Pure {
        spec.projection = projection
    }

    /// Creates a setter function for the given dynamic keypath, allowing a fluent API for all the public properties of the instance
    public subscript<U>(dynamicMember keyPath: WritableKeyPath<GGSpec.Projection, U>) -> (U) -> (Self) {
        setting(path: (\Self.projection).appending(path: keyPath))
    }
}


// MARK: DataTransform


@dynamicMemberLookup
public struct VizTransform<Def : VizTransformDefType> : VizSpecElementType, VizDSLType {
    public var transformDef: Def
    private let makeElements: () -> [VizLayerElementType]

    public func add<M>(to spec: inout VizSpec<M>) where M : Pure {
        spec.transform[defaulting: []].append(transformDef.anyTransform)
        for element in makeElements() {
            element.add(to: &spec)
        }
    }

    /// Creates a setter function for the given dynamic keypath, allowing a fluent API for all the public properties of the instance
    public subscript<U>(dynamicMember keyPath: WritableKeyPath<Def, U>) -> (U) -> (Self) {
        setting(path: (\Self.transformDef).appending(path: keyPath))
    }
}

// MARK: DataTransform: Sample

extension SampleTransform : VizTransformDefType {
    public var anyTransform: DataTransformation { .init(self) }
}

public extension VizTransform where Def == SampleTransform {
    enum SampleLiteral { case sample }
    init(_ sampleTransform: SampleLiteral, sample: Double = 999, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.transformDef = .init(sample: sample)
        self.makeElements = makeElements
    }
}

extension AggregateTransform : VizTransformDefType {
    public var anyTransform: DataTransformation { .init(self) }
}

public extension VizTransform where Def == AggregateTransform {
    enum AggregateLiteral { case aggregate }
    init(_ aggregateTransform: AggregateLiteral, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.transformDef = .init()
        self.makeElements = makeElements
    }
}

extension BinTransform : VizTransformDefType {
    public var anyTransform: DataTransformation { .init(self) }
}

public extension VizTransform where Def == BinTransform {
    enum BinLiteral { case bin }
    init(_ binTransform: BinLiteral, field: FieldNameRepresentable, params: BinParams?, output as: [FieldNameRepresentable], @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.transformDef = .init(as: .init(`as`.map(\.fieldName)), bin: params.map({ .init($0) }) ?? .init(true), field: field.fieldName)
        self.makeElements = makeElements
    }
}

extension CalculateTransform : VizTransformDefType {
    public var anyTransform: DataTransformation { .init(self) }
}

public extension VizTransform where Def == CalculateTransform {
    enum CalculateLiteral { case calculate }
    init(_ calculateTransform: CalculateLiteral, output as: FieldNameRepresentable, expression calculate: Expr, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.transformDef = .init(as: `as`.fieldName, calculate: calculate)
        self.makeElements = makeElements
    }
}

extension DensityTransform : VizTransformDefType {
    public var anyTransform: DataTransformation { .init(self) }
}

public extension VizTransform where Def == DensityTransform {
    enum DensityLiteral { case density }
    init(_ densityTransform: DensityLiteral, field density: FieldNameRepresentable, group groupby: [FieldNameRepresentable]? = nil, bandwidth: Double? = nil, counts: Bool? = nil, cumulative: Bool? = nil, extent: [DensityTransform.ExtentItem]? = nil, maxsteps: Double? = nil, minsteps: Double? = nil, steps: Double? = nil, sampleOutput: FieldNameRepresentable? = nil, densityOutput: FieldNameRepresentable? = nil, @VizLayerElementArrayBuilder _ makeElements: @escaping (_ sampleValueOutput: FieldNameRepresentable, _ densityEstimateOutput: FieldNameRepresentable) -> [VizLayerElementType]) {
        self.transformDef = .init(as: sampleOutput == nil && densityOutput == nil ? nil : [(sampleOutput ?? "value").fieldName, (densityOutput ?? "density").fieldName], bandwidth: bandwidth, counts: counts, cumulative: cumulative, density: density.fieldName, extent: extent, groupby: groupby?.map(\.fieldName), maxsteps: maxsteps, minsteps: minsteps, steps: steps)
        // self.makeElements = { makeElements(self.transformDef.as?.first?.fieldName ?? "value", self.transformDef.as?.last?.fieldName ?? "density") }
        self.makeElements = { makeElements(sampleOutput ?? "value", densityOutput ?? "density") }
    }
}

extension FilterTransform : VizTransformDefType {
    public var anyTransform: DataTransformation { .init(self) }
}

public extension VizTransform where Def == FilterTransform {
    enum FilterLiteral { case filter }
    init(_ filterTransform: FilterLiteral, filter: PredicateComposition, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.transformDef = .init(filter: filter)
        self.makeElements = makeElements
    }
}

extension FlattenTransform : VizTransformDefType {
    public var anyTransform: DataTransformation { .init(self) }
}

public extension VizTransform where Def == FlattenTransform {
    enum FlattenLiteral { case flatten }
    init(_ flattenTransform: FlattenLiteral, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.transformDef = .init()
        self.makeElements = makeElements
    }
}

extension FoldTransform : VizTransformDefType {
    public var anyTransform: DataTransformation { .init(self) }
}

public extension VizTransform where Def == FoldTransform {
    enum FoldLiteral { case fold }
    init(_ foldTransform: FoldLiteral, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.transformDef = .init()
        self.makeElements = makeElements
    }
}

extension ImputeTransform : VizTransformDefType {
    public var anyTransform: DataTransformation { .init(self) }
}

public extension VizTransform where Def == ImputeTransform {
    enum ImputeLiteral { case impute }
    init(_ imputeTransform: ImputeLiteral, impute: FieldNameRepresentable, key: FieldNameRepresentable, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.transformDef = .init(impute: impute.fieldName, key: key.fieldName)
        self.makeElements = makeElements
    }
}

extension JoinAggregateTransform : VizTransformDefType {
    public var anyTransform: DataTransformation { .init(self) }
}

public extension VizTransform where Def == JoinAggregateTransform {
    enum JoinAggregateLiteral { case joinAggregate }
    init(_ joinAggregateTransform: JoinAggregateLiteral, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.transformDef = .init()
        self.makeElements = makeElements
    }
}

extension LoessTransform : VizTransformDefType {
    public var anyTransform: DataTransformation { .init(self) }
}

public extension VizTransform where Def == LoessTransform {
    enum LoessLiteral { case loess }
    init(_ loessTransform: LoessLiteral, field: FieldNameRepresentable, on: FieldNameRepresentable, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.transformDef = .init(loess: field.fieldName, on: on.fieldName)
        self.makeElements = makeElements
    }
}

extension LookupTransform : VizTransformDefType {
    public var anyTransform: DataTransformation { .init(self) }
}

public extension VizTransform where Def == LookupTransform {
    enum LookupLiteral { case lookup }
    init(_ lookupTransform: LookupLiteral, field: FieldNameRepresentable, data: LookupData, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.transformDef = .init(from: .init(data), lookup: field.fieldName)
        self.makeElements = makeElements
    }

    init(_ lookupTransform: LookupLiteral, field: FieldNameRepresentable, selection: LookupSelection, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.transformDef = .init(from: .init(selection), lookup: field.fieldName)
        self.makeElements = makeElements
    }
}

extension QuantileTransform : VizTransformDefType {
    public var anyTransform: DataTransformation { .init(self) }
}

public extension VizTransform where Def == QuantileTransform {
    enum QuantileLiteral { case quantile }
    init(_ quantileTransform: QuantileLiteral, field: FieldNameRepresentable, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.transformDef = .init(quantile: field.fieldName)
        self.makeElements = makeElements
    }
}

extension RegressionTransform : VizTransformDefType {
    public var anyTransform: DataTransformation { .init(self) }
}

public extension VizTransform where Def == RegressionTransform {
    enum RegressionLiteral { case regression }
    init(_ regressionTransform: RegressionLiteral, field: FieldName, on: FieldName, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.transformDef = .init(on: on.fieldName, regression: field.fieldName)
        self.makeElements = makeElements
    }
}

extension TimeUnitTransform : VizTransformDefType {
    public var anyTransform: DataTransformation { .init(self) }
}

public extension VizTransform where Def == TimeUnitTransform {
    enum TimeUnitLiteral { case timeUnit }
    init(_ timeUnitTransform: TimeUnitLiteral, field: FieldNameRepresentable, timeUnit: TimeUnit, output as: FieldNameRepresentable, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.transformDef = .init(as: `as`.fieldName, field: field.fieldName, timeUnit: .init(timeUnit))
        self.makeElements = makeElements
    }

    init(_ timeUnitTransform: TimeUnitLiteral, field: FieldNameRepresentable, params: TimeUnitParams, output as: FieldNameRepresentable, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.transformDef = .init(as: `as`.fieldName, field: field.fieldName, timeUnit: .init(params))
        self.makeElements = makeElements
    }

}

extension StackTransform : VizTransformDefType {
    public var anyTransform: DataTransformation { .init(self) }
}

public extension VizTransform where Def == StackTransform {
    enum StackLiteral { case stack }
    init(_ stackTransform: StackLiteral, field stack: FieldNameRepresentable, startField: FieldNameRepresentable, endField: FieldNameRepresentable, @VizLayerElementArrayBuilder _ makeElements: @escaping (_ startField: FieldNameRepresentable, _ endField: FieldNameRepresentable) -> [VizLayerElementType]) {
        self.transformDef = .init(as: .init([startField.fieldName, endField.fieldName]), stack: stack.fieldName)
        self.makeElements = { makeElements(startField, endField) }
    }
}

extension WindowTransform : VizTransformDefType {
    public var anyTransform: DataTransformation { .init(self) }
}

public extension VizTransform where Def == WindowTransform {
    enum WindowLiteral { case window }
    init(_ windowTransform: WindowLiteral, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.transformDef = .init()
        self.makeElements = makeElements
    }
}

extension PivotTransform : VizTransformDefType {
    public var anyTransform: DataTransformation { .init(self) }
}

public extension VizTransform where Def == PivotTransform {
    enum PivotLiteral { case pivot }
    init(_ pivotTransform: PivotLiteral, pivot: FieldNameRepresentable, value: FieldNameRepresentable, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.transformDef = .init(pivot: pivot.fieldName, value: value.fieldName)
        self.makeElements = makeElements
    }
}


// MARK: Layers

/// A `Viz` encapsulates a top-level `VizSpec` layer and is used as the basis for the builder DSL.
@dynamicMemberLookup
public struct Viz<M: Pure> : VizLayerType {
    public private(set) var spec: VizSpec<M>

    public init(@VizSpecElementArrayBuilder _ makeElements: () -> [VizSpecElementType]) {
        var spec = VizSpec<M>()
        for element in makeElements() {
            element.add(to: &spec)
        }
        self.spec = spec
    }

    /// Creates a setter function for the given dynamic keypath, allowing a fluent API for all the public properties of the instance
    public subscript<U>(dynamicMember keyPath: WritableKeyPath<VizSpec<M>, U>) -> (U) -> (Self) {
        setting(path: (\Self.spec).appending(path: keyPath))
    }
}

extension Viz : CustomDebugStringConvertible {
    /// The Viz's description is the JSON describing the spec
    public var debugDescription: String { spec.jsonDebugDescription }
}



// MARK: Marks


@dynamicMemberLookup
public struct VizMark<Def : VizMarkDefType> : VizMarkType, VizDSLType {
    public var markDef: Def
    public var encodings: FacetedEncoding = FacetedEncoding()

    /// Creates a setter function for the given dynamic keypath, allowing a fluent API for all the public properties of the instance
    public subscript<U>(dynamicMember keyPath: WritableKeyPath<Def, U>) -> (U) -> (Self) {
        setting(path: (\Self.markDef).appending(path: keyPath))
    }

//    /// Creates a setter function for the given dynamic keypath, allowing a fluent API for all the public properties of the instance
//    public subscript<Choice: OneOf2Type>(dynamicMember keyPath: WritableKeyPath<Def, Choice?>) -> (Choice.T1) -> (Self) {
//        setting(path: (\Self.markDef).appending(path: keyPath).appending(path: \.!.v1))
//    }
}

public extension VizMark {
    /// Adds this `VizMark` to an enclosing spec
    func add<M>(to spec: inout VizSpec<M>) where M : Pure {
        spec.mark = self.markDef.anyMark.compactRepresentation
        spec.encoding[defaulting: .init()] = self.encodings
    }
}

extension VizMark {
    fileprivate mutating func addEncodings(_ newEncodings: [VizEncodeType]) {
        for enc in newEncodings {
            enc.addEncoding(to: &encodings)
        }
    }
}

public extension VizMark where Def == MarkDef {
    init(_ primitiveMark: PrimitiveMarkType) {
        self.init(primitiveMark) { }
    }

    init(_ primitiveMark: PrimitiveMarkType, @VizEncodeArrayBuilder makeEncodings: () -> [VizEncodeType]) {
        markDef = MarkDef(type: primitiveMark)
        addEncodings(makeEncodings())
    }
}

public extension VizMark where Def == BoxPlotDef {
    init(_ boxPlot: BoxPlotLiteral) {
        self.init(boxPlot) { }
    }

    init(_ boxPlot: BoxPlotLiteral, @VizEncodeArrayBuilder makeEncodings: () -> [VizEncodeType]) {
        markDef = BoxPlotDef(type: boxPlot)
        addEncodings(makeEncodings())
    }
}

public extension VizMark where Def == ErrorBarDef {
    init(_ errorBar: ErrorBarLiteral) {
        self.init(errorBar) { }
    }

    init(_ errorBar: ErrorBarLiteral, @VizEncodeArrayBuilder makeEncodings: () -> [VizEncodeType]) {
        markDef = ErrorBarDef(type: errorBar)
        addEncodings(makeEncodings())
    }
}

public extension VizMark where Def == ErrorBandDef {
    init(_ errorBand: ErrorBandLiteral) {
        self.init(errorBand) { }
    }

    init(_ errorBand: ErrorBandLiteral, @VizEncodeArrayBuilder makeEncodings: () -> [VizEncodeType]) {
        markDef = ErrorBandDef(type: errorBand)
        addEncodings(makeEncodings())
    }
}

public protocol VizEncodeType : VizDSLType {
    /// Adds this encoding information to the given `FacetedEncoding`
    func addEncoding(to encodings: inout FacetedEncoding)
}

//protocol VizEncodingFieldInitializable {
//    /// Constructs this instance with a `FieldName`
//    init(fieldName: FieldName)
//}
//
//protocol VizEncodingNumberInitializable {
//    /// Constructs this instance with a `Double`
//    init(number: Double)
//}
//
//protocol VizEncodingStringInitializable {
//    /// Constructs this instance with a `Double`
//    init(string: String)
//}

public protocol VizEncodingChannelType : Pure, RawCodable {
    static var encodingChannel: EncodingChannel { get }
    func addChannel(to encodings: inout FacetedEncoding)
}

@dynamicMemberLookup
public struct VizEncode<Channel : VizEncodingChannelType, Def : Pure> {
    private var def: Def
    private let deriveChannel: (Def) -> (Channel)

    /// Creates a setter function for the given dynamic keypath, allowing a fluent API for all the public properties of the instance
    public subscript<U>(dynamicMember keyPath: WritableKeyPath<Def, U>) -> (U) -> (Self) {
        setting(path: (\Self.def).appending(path: keyPath))
    }
}

extension VizEncode : VizLayerElementType {
    public func add<M: Pure>(to spec: inout VizSpec<M>) {
        deriveChannel(def).addChannel(to: &spec.encoding[defaulting: .init()])
    }
}

extension VizEncode : VizEncodeType {
    public func addEncoding(to encodings: inout FacetedEncoding) {
        deriveChannel(def).addChannel(to: &encodings)
    }
}


// MARK: Builders

//public typealias VizMarkArrayBuilder = VizArrayBuilder<VizMarkType>

public typealias VizSpecElementArrayBuilder = VizArrayBuilder<VizSpecElementType>
public typealias VizLayerElementArrayBuilder = VizArrayBuilder<VizLayerElementType>
public typealias VizEncodeArrayBuilder = VizArrayBuilder<VizEncodeType>



@resultBuilder
public enum VizArrayBuilder<T> {
    public static func buildEither(first component: [T]) -> [T] {
        return component
    }

    public static func buildEither(second component: [T]) -> [T] {
        return component
    }

    public static func buildOptional(_ component: [T]?) -> [T] {
        return component ?? []
    }

    public static func buildBlock(_ components: [T]...) -> [T] {
        return components.flatMap { $0 }
    }

    public static func buildExpression(_ expression: T) -> [T] {
        return [expression]
    }

    public static func buildExpression(_ expression: Void) -> [T] {
        return []
    }

}

extension VizSpecElementArrayBuilder {
    @available(*, unavailable, message: "VizEncode elements are children of VizLayer and VizMark")
    public static func buildBlock(_ components: VizEncodeType...) -> [VizEncodeType] {
        fatalError()
    }

}


/// A layer for a visualization, either top-level of nested
public protocol VizLayerType : VizDSLType {

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
            if element is VizMarkType || element is VizLayerType {
                var child = VizSpec<M>()
                element.add(to: &child)
                spec.sublayers.append(child)
            } else {
                element.add(to: &spec)
            }
        }
    }

//    /// Creates a setter function for the given dynamic keypath, allowing a fluent API for all the public properties of the instance
//    public subscript<U>(dynamicMember keyPath: WritableKeyPath<GGSpec.Projection, U>) -> (U) -> (Self) {
//        setting(path: (\Self.projection).appending(path: keyPath))
//    }
}

public struct VizRepeat : VizSpecElementType, VizLayerType {
    var repeatArrangement: LayerArrangement
    let repeatFields: [FieldNameRepresentable]
    let makeElements: () -> [VizLayerElementType]

    public init(_ repeatArrangement: LayerArrangement = .overlay, fields repeatFields: [FieldNameRepresentable], @VizLayerElementArrayBuilder _ makeElements: @escaping (_ ref: RepeatRef) -> [VizLayerElementType]) {
        self.repeatArrangement = repeatArrangement
        self.repeatFields = repeatFields
        self.makeElements = { makeElements(repeatArrangement.repeatRef) }
    }

    public func add<M>(to spec: inout VizSpec<M>) where M : Pure {
        spec.arrangement = .repeat
        switch repeatArrangement {
        case .overlay:
            spec.repeat = .init(LayerRepeatMapping(layer: repeatFields.map(\.fieldName)))
        case .hconcat:
            spec.repeat = .init(RepeatMapping(column: repeatFields.map(\.fieldName)))
        case .vconcat:
            spec.repeat = .init(RepeatMapping(row: repeatFields.map(\.fieldName)))
        case .concat:
            spec.repeat = .init(repeatFields.map(\.fieldName))
        case .repeat: // ???
            spec.repeat = .init(repeatFields.map(\.fieldName))
        }

        for element in makeElements() {
            // marks and layers create their own child specs; all others (e.g., encodings) are set directly in the parent
            if element is VizMarkType || element is VizLayerType {
                var child = VizSpec<M>()
                element.add(to: &child)
                spec.sublayers.append(child)
            } else {
                element.add(to: &spec)
            }
        }
    }

//    /// Creates a setter function for the given dynamic keypath, allowing a fluent API for all the public properties of the instance
//    public subscript<U>(dynamicMember keyPath: WritableKeyPath<GGSpec.Projection, U>) -> (U) -> (Self) {
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






// MARK: VizEncode: X

public extension VizEncode where Channel == FacetedEncoding.EncodingX {
    enum XChannel {
        /// x and y position channels determine the position of the marks, or width/height of horizontal/vertical "area" and "bar". In addition, x2 and y2 can specify the span of ranged area, bar, rect, and rule.
        case x
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Empty Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingX, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> PositionFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ x: XChannel) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ x: XChannel, field: FieldNameRepresentable) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ x: XChannel, repeat: RepeatRef) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingX, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> PositionDatumDef { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ x: XChannel, datum: ExplicitNull) {
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ x: XChannel, datum: Double) {
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ x: XChannel, datum: String) {
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ x: XChannel, datum: Bool) {
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ x: XChannel, datum: DateTime) {
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ x: XChannel, expression: String) {
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ x: XChannel, datum: RepeatRef) {
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingX, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefNumberWidthHeightExprRef { def }

    /// Creates this encoding with the given constant value.
    init(_ x: XChannel, value constant: Double) {
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ x: XChannel, value constant: LiteralWidth) {
        let value: Def.ValueChoice.T2 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ x: XChannel, value constant: LiteralHeight) {
        let value: Def.ValueChoice.T3 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ x: XChannel, expression: ExprRef) {
        let value: Def.ValueChoice.T4 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }
}








// MARK: VizEncode: Y

public extension VizEncode where Channel == FacetedEncoding.EncodingY {
    enum YChannel {
        /// x and y position channels determine the position of the marks, or width/height of horizontal/vertical "area" and "bar". In addition, x2 and y2 can specify the span of ranged area, bar, rect, and rule.
        case y
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Empty Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingY, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> PositionFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ y: YChannel) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ y: YChannel, field: FieldNameRepresentable) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ y: YChannel, repeat: RepeatRef) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingY, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> PositionDatumDef { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ y: YChannel, datum: ExplicitNull) {
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ y: YChannel, datum: Double) {
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ y: YChannel, datum: String) {
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ y: YChannel, datum: Bool) {
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ y: YChannel, datum: DateTime) {
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ y: YChannel, expression: String) {
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ y: YChannel, datum: RepeatRef) {
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingY, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefNumberWidthHeightExprRef { def }

    /// Creates this encoding with the given constant value.
    init(_ y: YChannel, value constant: Double) {
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ y: YChannel, value constant: LiteralWidth) {
        let value: Def.ValueChoice.T2 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ y: YChannel, value constant: LiteralHeight) {
        let value: Def.ValueChoice.T3 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ y: YChannel, expression: ExprRef) {
        let value: Def.ValueChoice.T4 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }
}




// MARK: VizEncode: x2

public extension VizEncode where Channel == FacetedEncoding.EncodingX2 {
    enum X2Channel {
        /// x and y position channels determine the position of the marks, or width/height of horizontal/vertical "area" and "bar". In addition, x2 and y2 can specify the span of ranged area, bar, rect, and rule.
        case x2
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Empty Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingX2, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> SecondaryFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ x2: X2Channel) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ x2: X2Channel, field: FieldNameRepresentable) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ x2: X2Channel, repeat: RepeatRef) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingX2, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> DatumDef { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ x2: X2Channel, datum: ExplicitNull) {
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ x2: X2Channel, datum: Double) {
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ x2: X2Channel, datum: String) {
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ x2: X2Channel, datum: Bool) {
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ x2: X2Channel, datum: DateTime) {
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ x2: X2Channel, expression: String) {
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ x2: X2Channel, datum: RepeatRef) {
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingX2, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefNumberWidthHeightExprRef { def }

    /// Creates this encoding with the given constant value.
    init(_ x2: X2Channel, value constant: Double) {
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ x2: X2Channel, value constant: LiteralWidth) {
        let value: Def.ValueChoice.T2 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ x2: X2Channel, value constant: LiteralHeight) {
        let value: Def.ValueChoice.T3 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ x2: X2Channel, expression: ExprRef) {
        let value: Def.ValueChoice.T4 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }
}






// MARK: VizEncode: y2


public extension VizEncode where Channel == FacetedEncoding.EncodingY2 {
    enum Y2Channel {
        /// x and y position channels determine the position of the marks, or width/height of horizontal/vertical "area" and "bar". In addition, x2 and y2 can specify the span of ranged area, bar, rect, and rule.
        case y2
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Empty Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingY2, Def == SecondaryFieldDef {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> SecondaryFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ y2: Y2Channel) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ y2: Y2Channel, field: FieldNameRepresentable) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ y2: Y2Channel, repeat: RepeatRef) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingY2, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> DatumDef { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ y2: Y2Channel, datum: ExplicitNull) {
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ y2: Y2Channel, datum: Double) {
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ y2: Y2Channel, datum: String) {
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ y2: Y2Channel, datum: Bool) {
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ y2: Y2Channel, datum: DateTime) {
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ y2: Y2Channel, expression: String) {
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ y2: Y2Channel, datum: RepeatRef) {
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingY2, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefNumberWidthHeightExprRef { def }

    /// Creates this encoding with the given constant value.
    init(_ y2: Y2Channel, value constant: Double) {
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ y2: Y2Channel, value constant: LiteralWidth) {
        let value: Def.ValueChoice.T2 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ y2: Y2Channel, value constant: LiteralHeight) {
        let value: Def.ValueChoice.T3 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ y2: Y2Channel, expression: ExprRef) {
        let value: Def.ValueChoice.T4 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }
}




// MARK: VizEncode: Color

public extension VizEncode where Channel == FacetedEncoding.EncodingColor {
    enum ColorChannel {
        /// Color of the marks – either fill or stroke color based on the filled property of mark definition. By default, color represents fill color for "area", "bar", "tick", "text", "trail", "circle", and "square" / stroke color for "line" and "point".
        case color
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Field Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingColor, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionMarkPropFieldDefGradientStringNull { def }

    /// Creates an empty instance of this encoding.
    init(_ color: ColorChannel) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ color: ColorChannel, field: FieldNameRepresentable) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ color: ColorChannel, repeat: RepeatRef) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingColor, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionDatumDefGradientStringNull { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ color: ColorChannel, datum: ExplicitNull) {
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ color: ColorChannel, datum: Double) {
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ color: ColorChannel, datum: String) {
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ color: ColorChannel, datum: Bool) {
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ color: ColorChannel, datum: DateTime) {
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ color: ColorChannel, expression: String) {
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ color: ColorChannel, datum: RepeatRef) {
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingColor, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefWithConditionMarkPropFieldOrDatumDefGradientStringNull { def }

    /// Creates this encoding with the given constant value.
    init(_ color: ColorChannel, value constant: ExplicitNull) {
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ color: ColorChannel, value constant: ColorGradientLinear) {
        self.init(color, value: .init(.init(constant)))
    }

    /// Creates this encoding with the given constant value.
    init(_ color: ColorChannel, value constant: ColorGradientRadial) {
        self.init(color, value: .init(.init(constant)))
    }

    /// Creates this encoding with the given constant color value.
    init(_ color: ColorChannel, value constant: String) {
        self.init(color, value: .init(constant))
    }

    /// Creates this encoding with the given constant color expression.
    init(_ color: ColorChannel, expression: ExprRef) {
        self.init(color, value: .init(expression))
    }

    private init(_ color: ColorChannel, value constant: OneOf3<ColorGradient, String, ExprRef>) {
        let value: Def.ValueChoice.T2 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }
}





// MARK: VizEncode: Fill

public extension VizEncode where Channel == FacetedEncoding.EncodingFill {
    enum FillChannel {
        /// Fill color of the marks. Default value: If undefined, the default color depends on mark config’s color property.
        case fill
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Field Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingFill, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionMarkPropFieldDefGradientStringNull { def }

    /// Creates an empty instance of this encoding.
    init(_ fill: FillChannel) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ fill: FillChannel, field: FieldNameRepresentable) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ fill: FillChannel, repeat: RepeatRef) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingFill, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionDatumDefGradientStringNull { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ fill: FillChannel, datum: ExplicitNull) {
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ fill: FillChannel, datum: Double) {
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ fill: FillChannel, datum: String) {
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ fill: FillChannel, datum: Bool) {
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ fill: FillChannel, datum: DateTime) {
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ fill: FillChannel, expression: String) {
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ fill: FillChannel, datum: RepeatRef) {
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingFill, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefWithConditionMarkPropFieldOrDatumDefGradientStringNull { def }

    /// Creates this encoding with the given constant value.
    init(_ fill: FillChannel, value constant: ExplicitNull) {
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ fill: FillChannel, value constant: ColorGradientLinear) {
        self.init(fill, value: .init(.init(constant)))
    }

    /// Creates this encoding with the given constant value.
    init(_ fill: FillChannel, value constant: ColorGradientRadial) {
        self.init(fill, value: .init(.init(constant)))
    }

    /// Creates this encoding with the given constant color value.
    init(_ fill: FillChannel, value constant: String) {
        self.init(fill, value: .init(constant))
    }

    // TODO: need to be able to create with constants
//    /// Creates this encoding with the given constant color value.
//    init(_ fill: FillChannel, value constant: ColorCode) {
//        self.init(fill, value: .init(constant))
//    }

    /// Creates this encoding with the given constant color expression.
    init(_ fill: FillChannel, expression: ExprRef) {
        self.init(fill, value: .init(expression))
    }

    private init(_ fill: FillChannel, value constant: OneOf3<ColorGradient, String, ExprRef>) {
        let value: Def.ValueChoice.T2 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }
}



// MARK: VizEncode: Stroke

public extension VizEncode where Channel == FacetedEncoding.EncodingStroke {
    enum StrokeChannel {
        /// Stroke color of the marks. Default value: If undefined, the default color depends on mark config’s color property.
        case stroke
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Field Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingStroke, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionMarkPropFieldDefGradientStringNull { def }

    /// Creates an empty instance of this encoding.
    init(_ stroke: StrokeChannel) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ stroke: StrokeChannel, field: FieldNameRepresentable) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ stroke: StrokeChannel, repeat: RepeatRef) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingStroke, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionDatumDefGradientStringNull { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ stroke: StrokeChannel, datum: ExplicitNull) {
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ stroke: StrokeChannel, datum: Double) {
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ stroke: StrokeChannel, datum: String) {
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ stroke: StrokeChannel, datum: Bool) {
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ stroke: StrokeChannel, datum: DateTime) {
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ stroke: StrokeChannel, expression: String) {
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ stroke: StrokeChannel, datum: RepeatRef) {
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingStroke, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefWithConditionMarkPropFieldOrDatumDefGradientStringNull { def }

    /// Creates this encoding with the given constant value.
    init(_ stroke: StrokeChannel, value constant: ExplicitNull) {
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ stroke: StrokeChannel, value constant: ColorGradientLinear) {
        self.init(stroke, value: .init(.init(constant)))
    }

    /// Creates this encoding with the given constant value.
    init(_ stroke: StrokeChannel, value constant: ColorGradientRadial) {
        self.init(stroke, value: .init(.init(constant)))
    }

    /// Creates this encoding with the given constant color value.
    init(_ stroke: StrokeChannel, value constant: String) {
        self.init(stroke, value: .init(constant))
    }

    /// Creates this encoding with the given constant color expression.
    init(_ stroke: StrokeChannel, expression: ExprRef) {
        self.init(stroke, value: .init(expression))
    }

    private init(_ stroke: StrokeChannel, value constant: OneOf3<ColorGradient, String, ExprRef>) {
        let value: Def.ValueChoice.T2 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }
}


// MARK: VizEncode: size

public extension VizEncode where Channel == FacetedEncoding.EncodingSize {
    enum SizeChannel {
        /// Size of the mark.
        ///
        /// - For "point", "square" and "circle", – the symbol size, or pixel area of the mark.
        /// - For "bar" and "tick" – the bar and tick’s size.
        /// - For "text" – the text’s font size.
        ///
        /// - Size is unsupported for "line", "area", and "rect". (Use "trail" instead of line with varying size)
        case size
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Field Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingSize, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionMarkPropFieldDefNumber { def }

    /// Creates an empty instance of this encoding.
    init(_ size: SizeChannel) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ size: SizeChannel, field: FieldNameRepresentable) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ size: SizeChannel, repeat: RepeatRef) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingSize, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionDatumDefNumber { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ size: SizeChannel, datum: ExplicitNull) {
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ size: SizeChannel, datum: Double) {
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ size: SizeChannel, datum: String) {
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ size: SizeChannel, datum: Bool) {
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ size: SizeChannel, datum: DateTime) {
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ size: SizeChannel, expression: String) {
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ size: SizeChannel, datum: RepeatRef) {
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingSize, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefWithConditionMarkPropFieldOrDatumDefNumber { def }

    /// Creates this encoding with the given constant value.
    init(_ size: SizeChannel, value constant: Double) {
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ size: SizeChannel, expr expression: ExprRef) {
        let value: Def.ValueChoice.T2 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }
}



// MARK: VizEncode: strokeWidth

public extension VizEncode where Channel == FacetedEncoding.EncodingStrokeWidth {
    enum StrokeWidthChannel {
        /// Stroke width of the marks.
        ///
        /// - Default value: If undefined, the default stroke width depends on mark config’s strokeWidth property.
        case strokeWidth
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Field Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingStrokeWidth, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionMarkPropFieldDefNumber { def }

    /// Creates an empty instance of this encoding.
    init(_ strokeWidth: StrokeWidthChannel) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ strokeWidth: StrokeWidthChannel, field: FieldNameRepresentable) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ strokeWidth: StrokeWidthChannel, repeat: RepeatRef) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingStrokeWidth, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionDatumDefNumber { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeWidth: StrokeWidthChannel, datum: ExplicitNull) {
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeWidth: StrokeWidthChannel, datum: Double) {
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeWidth: StrokeWidthChannel, datum: String) {
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeWidth: StrokeWidthChannel, datum: Bool) {
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeWidth: StrokeWidthChannel, datum: DateTime) {
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeWidth: StrokeWidthChannel, expression: String) {
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ strokeWidth: StrokeWidthChannel, datum: RepeatRef) {
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingStrokeWidth, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefWithConditionMarkPropFieldOrDatumDefNumber { def }

    /// Creates this encoding with the given constant value.
    init(_ strokeWidth: StrokeWidthChannel, value constant: Double) {
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ strokeWidth: StrokeWidthChannel, expr expression: ExprRef) {
        let value: Def.ValueChoice.T2 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }
}



// MARK: VizEncode: strokeOpacity

public extension VizEncode where Channel == FacetedEncoding.EncodingStrokeOpacity {
    enum StrokeOpacityChannel {
        /// Stroke opacity of the marks.
        case strokeOpacity
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Field Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingStrokeOpacity, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionMarkPropFieldDefNumber { def }

    /// Creates an empty instance of this encoding.
    init(_ strokeOpacity: StrokeOpacityChannel) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ strokeOpacity: StrokeOpacityChannel, field: FieldNameRepresentable) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ strokeOpacity: StrokeOpacityChannel, repeat: RepeatRef) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingStrokeOpacity, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionDatumDefNumber { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeOpacity: StrokeOpacityChannel, datum: ExplicitNull) {
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeOpacity: StrokeOpacityChannel, datum: Double) {
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeOpacity: StrokeOpacityChannel, datum: String) {
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeOpacity: StrokeOpacityChannel, datum: Bool) {
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeOpacity: StrokeOpacityChannel, datum: DateTime) {
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeOpacity: StrokeOpacityChannel, expression: String) {
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ strokeOpacity: StrokeOpacityChannel, datum: RepeatRef) {
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingStrokeOpacity, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefWithConditionMarkPropFieldOrDatumDefNumber { def }

    /// Creates this encoding with the given constant value.
    init(_ strokeOpacity: StrokeOpacityChannel, value constant: Double) {
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ strokeOpacity: StrokeOpacityChannel, expr expression: ExprRef) {
        let value: Def.ValueChoice.T2 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }
}



// MARK: VizEncode: fillOpacity

public extension VizEncode where Channel == FacetedEncoding.EncodingFillOpacity {
    enum FillOpacityChannel {
        /// Fill opacity of the marks.
        case fillOpacity
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Field Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingFillOpacity, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionMarkPropFieldDefNumber { def }

    /// Creates an empty instance of this encoding.
    init(_ fillOpacity: FillOpacityChannel) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ fillOpacity: FillOpacityChannel, field: FieldNameRepresentable) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ fillOpacity: FillOpacityChannel, repeat: RepeatRef) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingFillOpacity, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionDatumDefNumber { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ fillOpacity: FillOpacityChannel, datum: ExplicitNull) {
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ fillOpacity: FillOpacityChannel, datum: Double) {
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ fillOpacity: FillOpacityChannel, datum: String) {
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ fillOpacity: FillOpacityChannel, datum: Bool) {
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ fillOpacity: FillOpacityChannel, datum: DateTime) {
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ fillOpacity: FillOpacityChannel, expression: String) {
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ fillOpacity: FillOpacityChannel, datum: RepeatRef) {
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingFillOpacity, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefWithConditionMarkPropFieldOrDatumDefNumber { def }

    /// Creates this encoding with the given constant value.
    init(_ fillOpacity: FillOpacityChannel, value constant: Double) {
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ fillOpacity: FillOpacityChannel, expr expression: ExprRef) {
        let value: Def.ValueChoice.T2 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }
}



// MARK: VizEncode: opacity

public extension VizEncode where Channel == FacetedEncoding.EncodingOpacity {
    enum OpacityChannel {
        /// Opacity of the marks.
        case opacity
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Field Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingOpacity, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionMarkPropFieldDefNumber { def }

    /// Creates an empty instance of this encoding.
    init(_ opacity: OpacityChannel) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ opacity: OpacityChannel, field: FieldNameRepresentable) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ opacity: OpacityChannel, repeat: RepeatRef) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingOpacity, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionDatumDefNumber { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ opacity: OpacityChannel, datum: ExplicitNull) {
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ opacity: OpacityChannel, datum: Double) {
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ opacity: OpacityChannel, datum: String) {
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ opacity: OpacityChannel, datum: Bool) {
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ opacity: OpacityChannel, datum: DateTime) {
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ opacity: OpacityChannel, expression: String) {
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ opacity: OpacityChannel, datum: RepeatRef) {
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingOpacity, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefWithConditionMarkPropFieldOrDatumDefNumber { def }

    /// Creates this encoding with the given constant value.
    init(_ opacity: OpacityChannel, value constant: Double) {
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ opacity: OpacityChannel, expr expression: ExprRef) {
        let value: Def.ValueChoice.T2 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }
}



// MARK: VizEncode: angle

public extension VizEncode where Channel == FacetedEncoding.EncodingAngle {
    enum AngleChannel {
        /// Rotation angle of point and text marks.
        case angle
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Field Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingAngle, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionMarkPropFieldDefNumber { def }

    /// Creates an empty instance of this encoding.
    init(_ angle: AngleChannel) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ angle: AngleChannel, field: FieldNameRepresentable) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ angle: AngleChannel, repeat: RepeatRef) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingAngle, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionDatumDefNumber { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ angle: AngleChannel, datum: ExplicitNull) {
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ angle: AngleChannel, datum: Double) {
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ angle: AngleChannel, datum: String) {
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ angle: AngleChannel, datum: Bool) {
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ angle: AngleChannel, datum: DateTime) {
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ angle: AngleChannel, expression: String) {
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ angle: AngleChannel, datum: RepeatRef) {
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingAngle, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefWithConditionMarkPropFieldOrDatumDefNumber { def }

    /// Creates this encoding with the given constant value.
    init(_ angle: AngleChannel, value constant: Double) {
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ angle: AngleChannel, expr expression: ExprRef) {
        let value: Def.ValueChoice.T2 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }
}



// MARK: VizEncode: theta


public extension VizEncode where Channel == FacetedEncoding.EncodingTheta {
    enum ThetaChannel {
        /// For arc marks, the arc length in radians if theta2 is not specified, otherwise the start arc angle. (A value of 0 indicates up or “north”, increasing values proceed clockwise.)
        /// For text marks, polar coordinate angle in radians.
        case theta
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Field Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingTheta, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> PositionFieldDefBase { def }

    /// Creates an empty instance of this encoding.
    init(_ theta: ThetaChannel) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ theta: ThetaChannel, field: FieldNameRepresentable) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ theta: ThetaChannel, repeat: RepeatRef) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingTheta, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> PositionDatumDefBase { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ theta: ThetaChannel, datum: ExplicitNull) {
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ theta: ThetaChannel, datum: Double) {
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ theta: ThetaChannel, datum: String) {
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ theta: ThetaChannel, datum: Bool) {
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ theta: ThetaChannel, datum: DateTime) {
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ theta: ThetaChannel, expression: String) {
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ theta: ThetaChannel, datum: RepeatRef) {
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingTheta, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefNumberWidthHeightExprRef { def }

    /// Creates this encoding with the given constant value.
    init(_ theta: ThetaChannel, value constant: Double) {
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ theta: ThetaChannel, value constant: LiteralWidth) {
        let value: Def.ValueChoice.T2 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }

    /// Creates this encoding with the given constant value.
    init(_ theta: ThetaChannel, expr expression: LiteralHeight) {
        let value: Def.ValueChoice.T3 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }

    /// Creates this encoding with the given constant value.
    init(_ theta: ThetaChannel, expr expression: ExprRef) {
        let value: Def.ValueChoice.T4 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }

}


// MARK: VizEncode: theta2

public extension VizEncode where Channel == FacetedEncoding.EncodingTheta2 {
    enum Theta2Channel {
        /// The end angle of arc marks in radians. A value of 0 indicates up or “north”, increasing values proceed clockwise.
        case theta2
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Field Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingTheta2, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> SecondaryFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ theta2: Theta2Channel) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ theta2: Theta2Channel, field: FieldNameRepresentable) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ theta2: Theta2Channel, repeat: RepeatRef) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingTheta2, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> DatumDef { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ theta2: Theta2Channel, datum: ExplicitNull) {
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ theta2: Theta2Channel, datum: Double) {
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ theta2: Theta2Channel, datum: String) {
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ theta2: Theta2Channel, datum: Bool) {
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ theta2: Theta2Channel, datum: DateTime) {
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ theta2: Theta2Channel, expression: String) {
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ theta2: Theta2Channel, datum: RepeatRef) {
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingTheta2, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefNumberWidthHeightExprRef { def }

    /// Creates this encoding with the given constant value.
    init(_ theta2: Theta2Channel, value constant: Double) {
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ theta2: Theta2Channel, value constant: LiteralWidth) {
        let value: Def.ValueChoice.T2 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }

    /// Creates this encoding with the given constant value.
    init(_ theta2: Theta2Channel, expr expression: LiteralHeight) {
        let value: Def.ValueChoice.T3 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }

    /// Creates this encoding with the given constant value.
    init(_ theta2: Theta2Channel, expr expression: ExprRef) {
        let value: Def.ValueChoice.T4 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }
}



// MARK: VizEncode: radius

public extension VizEncode where Channel == FacetedEncoding.EncodingRadius {
    enum RadiusChannel {
        /// The outer radius in pixels of arc marks.
        case radius
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Field Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingRadius, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> PositionFieldDefBase { def }

    /// Creates an empty instance of this encoding.
    init(_ radius: RadiusChannel) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ radius: RadiusChannel, field: FieldNameRepresentable) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ radius: RadiusChannel, repeat: RepeatRef) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingRadius, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> PositionDatumDefBase { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ radius: RadiusChannel, datum: ExplicitNull) {
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ radius: RadiusChannel, datum: Double) {
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ radius: RadiusChannel, datum: String) {
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ radius: RadiusChannel, datum: Bool) {
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ radius: RadiusChannel, datum: DateTime) {
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ radius: RadiusChannel, expression: String) {
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ radius: RadiusChannel, datum: RepeatRef) {
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingRadius, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefNumberWidthHeightExprRef { def }

    /// Creates this encoding with the given constant value.
    init(_ radius: RadiusChannel, value constant: Double) {
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }


    /// Creates this encoding with the given constant value.
    init(_ radius: RadiusChannel, value constant: LiteralWidth) {
        let value: Def.ValueChoice.T2 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }

    /// Creates this encoding with the given constant value.
    init(_ radius: RadiusChannel, expr expression: LiteralHeight) {
        let value: Def.ValueChoice.T3 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }

    /// Creates this encoding with the given constant value.
    init(_ radius: RadiusChannel, expr expression: ExprRef) {
        let value: Def.ValueChoice.T4 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }
}



// MARK: VizEncode: radius2

public extension VizEncode where Channel == FacetedEncoding.EncodingRadius2 {
    enum Radius2Channel {
        /// The inner radius in pixels of arc marks.
        case radius2
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Field Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingRadius2, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> SecondaryFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ radius2: Radius2Channel) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ radius2: Radius2Channel, field: FieldNameRepresentable) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ radius2: Radius2Channel, repeat: RepeatRef) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingRadius2, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> DatumDef { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ radius2: Radius2Channel, datum: ExplicitNull) {
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ radius2: Radius2Channel, datum: Double) {
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ radius2: Radius2Channel, datum: String) {
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ radius2: Radius2Channel, datum: Bool) {
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ radius2: Radius2Channel, datum: DateTime) {
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ radius2: Radius2Channel, expression: String) {
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ radius2: Radius2Channel, datum: RepeatRef) {
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingRadius2, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefNumberWidthHeightExprRef { def }

    /// Creates this encoding with the given constant value.
    init(_ radius2: Radius2Channel, value constant: Double) {
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }


    /// Creates this encoding with the given constant value.
    init(_ radius2: Radius2Channel, value constant: LiteralWidth) {
        let value: Def.ValueChoice.T2 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }

    /// Creates this encoding with the given constant value.
    init(_ radius2: Radius2Channel, expr expression: LiteralHeight) {
        let value: Def.ValueChoice.T3 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }

    /// Creates this encoding with the given constant value.
    init(_ radius2: Radius2Channel, expr expression: ExprRef) {
        let value: Def.ValueChoice.T4 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }
}



// MARK: VizEncode: xError

public extension VizEncode where Channel == FacetedEncoding.EncodingXError {
    enum XErrorChannel {
        case xError
    }

    typealias ChannelFieldType = Channel.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.T2
}

/// Empty Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingXError, Def == SecondaryFieldDef {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> SecondaryFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ xError: XErrorChannel) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    init(_ xError: XErrorChannel, field: FieldNameRepresentable) {
        /// Creates this encoding with the value mapped to the given field name in the data.
        self.deriveChannel = { .init($0) }
        self.def = .init(field: .init(field.fieldName))
    }
}

/// Field Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingXError, Def == ValueDefNumber {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefNumber { def }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ xError: XErrorChannel, value constant: Double) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: constant)
    }
}





// MARK: VizEncode: xError2


public extension VizEncode where Channel == FacetedEncoding.EncodingXError2 {
    enum XError2Channel {
        case xError2
    }

    typealias ChannelFieldType = Channel.RawValue.T1
    typealias ChannelValueType = Channel.RawValue.T2
}

/// Empty Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingXError2, Def == SecondaryFieldDef {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> SecondaryFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ xError2: XError2Channel) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    init(_ xError2: XError2Channel, field: FieldNameRepresentable) {
        /// Creates this encoding with the value mapped to the given field name in the data.
        self.deriveChannel = { .init($0) }
        self.def = .init(field: .init(field.fieldName))
    }
}

/// Field Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingXError2, Def == ValueDefNumber {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefNumber { def }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ xError2: XError2Channel, value constant: Double) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: constant)
    }
}




// MARK: VizEncode: yError


public extension VizEncode where Channel == FacetedEncoding.EncodingYError {
    enum YErrorChannel {
        case yError
    }

    typealias ChannelFieldType = Channel.RawValue.T1
    typealias ChannelValueType = Channel.RawValue.T2
}

/// Empty Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingYError, Def == SecondaryFieldDef {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> SecondaryFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ yError: YErrorChannel) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    init(_ yError: YErrorChannel, field: FieldNameRepresentable) {
        /// Creates this encoding with the value mapped to the given field name in the data.
        self.deriveChannel = { .init($0) }
        self.def = .init(field: .init(field.fieldName))
    }
}

/// Field Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingYError, Def == ValueDefNumber {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefNumber { def }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ yError: YErrorChannel, value constant: Double) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: constant)
    }
}



// MARK: VizEncode: yError2


public extension VizEncode where Channel == FacetedEncoding.EncodingYError2 {
    enum YError2Channel {
        case yError2
    }

    typealias ChannelFieldType = Channel.RawValue.T1
    typealias ChannelValueType = Channel.RawValue.T2
}

/// Empty Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingYError2, Def == SecondaryFieldDef {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> SecondaryFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ yError2: YError2Channel) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    init(_ yError2: YError2Channel, field: FieldNameRepresentable) {
        /// Creates this encoding with the value mapped to the given field name in the data.
        self.deriveChannel = { .init($0) }
        self.def = .init(field: .init(field.fieldName))
    }
}

/// Field Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingYError2, Def == ValueDefNumber {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefNumber { def }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ yError2: YError2Channel, value constant: Double) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: constant)
    }
}



// MARK: VizEncode: column


public extension VizEncode where Channel == FacetedEncoding.EncodingColumn {
    enum ColumnChannel {
        /// Facet, row and column are special encoding channels that facets single plots into trellis plots (or small multiples).
        case column
    }

    typealias ChannelFieldType = Channel.RawValue
}

/// Empty Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingColumn, Def == RowColumnEncodingFieldDef {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> RowColumnEncodingFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ column: ColumnChannel) {
        self.deriveChannel = { .init($0) }
        self.def = .init()
    }

    init(_ column: ColumnChannel, field: FieldNameRepresentable) {
        /// Creates this encoding with the value mapped to the given field name in the data.
        self.deriveChannel = { .init($0) }
        self.def = .init(field: .init(field.fieldName))
    }
}

// MARK: VizEncode: row


public extension VizEncode where Channel == FacetedEncoding.EncodingRow {
    enum RowChannel {
        /// Facet, row and column are special encoding channels that facets single plots into trellis plots (or small multiples).
        case row
    }

    typealias ChannelFieldType = Channel.RawValue
}

/// Empty Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingRow, Def == RowColumnEncodingFieldDef {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> RowColumnEncodingFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ row: RowChannel) {
        self.deriveChannel = { .init($0) }
        self.def = .init()
    }

    init(_ row: RowChannel, field: FieldNameRepresentable) {
        /// Creates this encoding with the value mapped to the given field name in the data.
        self.deriveChannel = { .init($0) }
        self.def = .init(field: .init(field.fieldName))
    }
}




// MARK: VizEncode: facet


public extension VizEncode where Channel == FacetedEncoding.EncodingFacet {
    enum FacetChannel {
        /// Facet, row and column are special encoding channels that facets single plots into trellis plots (or small multiples).
        case facet
    }

    typealias ChannelFieldType = Channel.RawValue
}

/// Empty Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingFacet, Def == FacetEncodingFieldDef {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FacetEncodingFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ facet: FacetChannel) {
        self.deriveChannel = { .init($0) }
        self.def = .init()
    }

    init(_ facet: FacetChannel, field: FieldNameRepresentable) {
        /// Creates this encoding with the value mapped to the given field name in the data.
        self.deriveChannel = { .init($0) }
        self.def = .init(field: .init(field.fieldName))
    }
}


// MARK: VizEncode: latitude

public extension VizEncode where Channel == FacetedEncoding.EncodingLatitude {
    enum LatitudeChannel {
        /// Longitude and latitude channels can be used to encode geographic coordinate data via a projection. In addition, longitude2 and latitude2 can specify the span of geographically projected ranged area, bar, rect, and rule.
        case latitude
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelValueType = Channel.RawValue.RawValue.T2

//    func fieldType(for field: Self.ChannelFieldType) -> Self.ChannelFieldType { field }
}

/// Empty Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingLatitude, Def == LatLongFieldDef {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> LatLongFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ latitude: LatitudeChannel) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ latitude: LatitudeChannel, field: FieldNameRepresentable) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ latitude: LatitudeChannel, repeat: RepeatRef) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingLatitude, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> DatumDef { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ latitude: LatitudeChannel, datum: ExplicitNull) {
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ latitude: LatitudeChannel, datum: Double) {
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ latitude: LatitudeChannel, datum: String) {
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ latitude: LatitudeChannel, datum: Bool) {
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ latitude: LatitudeChannel, datum: DateTime) {
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ latitude: LatitudeChannel, expression: String) {
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ latitude: LatitudeChannel, datum: RepeatRef) {
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}


// MARK: VizEncode: longitude


public extension VizEncode where Channel == FacetedEncoding.EncodingLongitude {
    enum LongitudeChannel {
        /// Longitude and latitude channels can be used to encode geographic coordinate data via a projection. In addition, longitude2 and latitude2 can specify the span of geographically projected ranged area, bar, rect, and rule.
        case longitude
    }
    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelValueType = Channel.RawValue.RawValue.T2
}

/// Empty Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingLongitude, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> LatLongFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ longitude: LongitudeChannel) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ longitude: LongitudeChannel, field: FieldNameRepresentable) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ longitude: LongitudeChannel, repeat: RepeatRef) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingLongitude, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> DatumDef { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ longitude: LongitudeChannel, datum: ExplicitNull) {
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ longitude: LongitudeChannel, datum: Double) {
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ longitude: LongitudeChannel, datum: String) {
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ longitude: LongitudeChannel, datum: Bool) {
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ longitude: LongitudeChannel, datum: DateTime) {
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ longitude: LongitudeChannel, expression: String) {
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ longitude: LongitudeChannel, datum: RepeatRef) {
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}



// MARK: VizEncode: latitude2


public extension VizEncode where Channel == FacetedEncoding.EncodingLatitude2 {
    enum Latitude2Channel {
        /// Longitude and latitude channels can be used to encode geographic coordinate data via a projection. In addition, longitude2 and latitude2 can specify the span of geographically projected ranged area, bar, rect, and rule.
        case latitude2
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Empty Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingLatitude2, Def == SecondaryFieldDef {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> SecondaryFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ latitude2: Latitude2Channel) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ latitude2: Latitude2Channel, field: FieldNameRepresentable) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ latitude2: Latitude2Channel, repeat: RepeatRef) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingLatitude2, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> DatumDef { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ latitude2: Latitude2Channel, datum: ExplicitNull) {
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ latitude2: Latitude2Channel, datum: Double) {
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ latitude2: Latitude2Channel, datum: String) {
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ latitude2: Latitude2Channel, datum: Bool) {
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ latitude2: Latitude2Channel, datum: DateTime) {
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ latitude2: Latitude2Channel, expression: String) {
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ latitude2: Latitude2Channel, datum: RepeatRef) {
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}


// MARK: VizEncode: longitude2


public extension VizEncode where Channel == FacetedEncoding.EncodingLongitude2 {
    enum Longitude2Channel {
        /// Longitude and latitude channels can be used to encode geographic coordinate data via a projection. In addition, longitude2 and latitude2 can specify the span of geographically projected ranged area, bar, rect, and rule.
        case longitude2
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Empty Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingLongitude2, Def == SecondaryFieldDef {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> SecondaryFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ longitude2: Longitude2Channel) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ longitude2: Longitude2Channel, field: FieldNameRepresentable) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ longitude2: Longitude2Channel, repeat: RepeatRef) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingLongitude2, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> DatumDef { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ longitude2: Longitude2Channel, datum: ExplicitNull) {
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ longitude2: Longitude2Channel, datum: Double) {
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ longitude2: Longitude2Channel, datum: String) {
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ longitude2: Longitude2Channel, datum: Bool) {
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ longitude2: Longitude2Channel, datum: DateTime) {
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ longitude2: Longitude2Channel, expression: String) {
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ longitude2: Longitude2Channel, datum: RepeatRef) {
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}



// MARK: VizEncode: href

public extension VizEncode where Channel == FacetedEncoding.EncodingHref {
    enum HrefChannel {
        /// A URL to load upon mouse click.
        case href
    }

    typealias ChannelFieldType = Channel.RawValue.T1
    typealias ChannelValueType = Channel.RawValue.T2
}

/// Field Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingHref, Def == Channel.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionStringFieldDefString { def }

    /// Creates an empty instance of this encoding.
    init(_ href: HrefChannel) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ href: HrefChannel, field: FieldNameRepresentable) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ href: HrefChannel, repeat: RepeatRef) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }
}

/// Value Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingHref, Def == StringValueDefWithCondition {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefWithConditionMarkPropFieldOrDatumDefStringNull { def }

    /// Creates this encoding with the given constant value.
    init(_ href: HrefChannel, value constant: ExplicitNull) {
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ href: HrefChannel, value constant: String) {
        let value: Def.ValueChoice.T2.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(.init(value)))
    }

    /// Creates this encoding with the given constant value.
    init(_ href: HrefChannel, expr expression: ExprRef) {
        let value: Def.ValueChoice.T2.T2 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(.init(value))) // ambiguous with the other expr init?
    }
}


// MARK: VizEncode: description

public extension VizEncode where Channel == FacetedEncoding.EncodingDescription {
    enum DescriptionChannel {
        /// A text description of this mark for ARIA accessibility. For SVG output the "aria-label" attribute will be set to this description.
        case description
    }

    typealias ChannelFieldType = Channel.RawValue.T1
    typealias ChannelValueType = Channel.RawValue.T2
}

/// Field Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingDescription, Def == Channel.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionStringFieldDefString { def }

    /// Creates an empty instance of this encoding.
    init(_ description: DescriptionChannel) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ description: DescriptionChannel, field: FieldNameRepresentable) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ description: DescriptionChannel, repeat: RepeatRef) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }
}

/// Value Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingDescription, Def == StringValueDefWithCondition {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefWithConditionMarkPropFieldOrDatumDefStringNull { def }

    /// Creates this encoding with the given constant value.
    init(_ description: DescriptionChannel, value constant: ExplicitNull) {
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ description: DescriptionChannel, value constant: String) {
        let value: Def.ValueChoice.T2.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(.init(value)))
    }

    /// Creates this encoding with the given constant value.
    init(_ description: DescriptionChannel, expr expression: ExprRef) {
        let value: Def.ValueChoice.T2.T2 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(.init(value))) // ambiguous with the other expr init?
    }
}

// MARK: VizEncode: url

public extension VizEncode where Channel == FacetedEncoding.EncodingUrl {
    enum UrlChannel {
        case url
    }

    typealias ChannelFieldType = Channel.RawValue.T1
    typealias ChannelValueType = Channel.RawValue.T2
}

/// Field Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingUrl, Def == Channel.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionStringFieldDefString { def }

    /// Creates an empty instance of this encoding.
    init(_ url: UrlChannel) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ url: UrlChannel, field: FieldNameRepresentable) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ url: UrlChannel, repeat: RepeatRef) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }
}

/// Value Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingUrl, Def == Channel.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> StringValueDefWithCondition { def }

    /// Creates this encoding with the given constant value.
    init(_ url: UrlChannel, value constant: ExplicitNull) {
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ url: UrlChannel, value constant: String) {
        let value: Def.ValueChoice.T2.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(.init(value)))
    }

    /// Creates this encoding with the given constant value.
    init(_ url: UrlChannel, expr expression: ExprRef) {
        let value: Def.ValueChoice.T2.T2 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(.init(value))) // ambiguous with the other expr init?
    }
}


// MARK: VizEncode: strokeDash

public extension VizEncode where Channel == FacetedEncoding.EncodingStrokeDash {
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
public extension VizEncode where Channel == FacetedEncoding.EncodingStrokeDash, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionMarkPropFieldDefNumberArray { def }

    /// Creates an empty instance of this encoding.
    init(_ strokeDash: StrokeDashChannel) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ strokeDash: StrokeDashChannel, field: FieldNameRepresentable) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ strokeDash: StrokeDashChannel, repeat: RepeatRef) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }
}

public extension VizEncode where Channel == FacetedEncoding.EncodingStrokeDash, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionDatumDefNumberArray { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeDash: StrokeDashChannel, datum: ExplicitNull) {
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeDash: StrokeDashChannel, datum: Double) {
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeDash: StrokeDashChannel, datum: String) {
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeDash: StrokeDashChannel, datum: Bool) {
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeDash: StrokeDashChannel, datum: DateTime) {
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeDash: StrokeDashChannel, expression: String) {
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ strokeDash: StrokeDashChannel, datum: RepeatRef) {
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

public extension VizEncode where Channel == FacetedEncoding.EncodingStrokeDash, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefWithConditionMarkPropFieldOrDatumDefNumberArray { def }

    /// Creates this encoding with the given constant value.
    init(_ strokeDash: StrokeDashChannel, value constant: [Double]) {
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ strokeDash: StrokeDashChannel, expr expression: ExprRef) {
        let value: Def.ValueChoice.T2 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }
}


// MARK: VizEncode: key

public extension VizEncode where Channel == FacetedEncoding.EncodingKey {
    enum KeyChannel {
        case key
    }

    typealias ChannelFieldType = Channel.RawValue
}

/// Field Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingKey, Def == Channel.RawValue {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> TypedFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ key: KeyChannel) {
        self.deriveChannel = { .init($0) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ key: KeyChannel, field: FieldNameRepresentable) {
        self.deriveChannel = { .init($0) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ key: KeyChannel, repeat: RepeatRef) {
        self.deriveChannel = { .init($0) }
        self.def = .init(field: .init(`repeat`))
    }
}


// MARK: VizEncode: shape

public extension VizEncode where Channel == FacetedEncoding.EncodingShape {
    enum ShapeChannel {
        /// Shape of the mark.
        ///
        /// - For point marks the supported values include: - plotting shapes: "circle", "square", "cross", "diamond", "triangle-up", "triangle-down", "triangle-right", or "triangle-left". - the line symbol "stroke" - centered directional shapes "arrow", "wedge", or "triangle" - a custom SVG path string (For correct sizing, custom shape paths should be defined within a square bounding box with coordinates ranging from -1 to 1 along both the x and y dimensions.)
        /// - For geoshape marks it should be a field definition of the geojson data
        ///
        /// Default value: If undefined, the default shape depends on mark config’s shape property. ("circle" if unset.)
        case shape
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Field Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingShape, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionMarkPropFieldDefTypeForShapeStringNull { def }

    /// Creates an empty instance of this encoding.
    init(_ shape: ShapeChannel) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ shape: ShapeChannel, field: FieldNameRepresentable) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ shape: ShapeChannel, repeat: RepeatRef) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingShape, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionDatumDefStringNull { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ shape: ShapeChannel, datum: ExplicitNull) {
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ shape: ShapeChannel, datum: Double) {
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ shape: ShapeChannel, datum: String) {
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ shape: ShapeChannel, datum: Bool) {
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ shape: ShapeChannel, datum: DateTime) {
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ shape: ShapeChannel, expression: String) {
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ shape: ShapeChannel, datum: RepeatRef) {
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingShape, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefWithConditionMarkPropFieldOrDatumDefTypeForShapeStringNull { def }

    /// Creates this encoding with the given constant value.
    init(_ shape: ShapeChannel, value constant: SymbolShape?) {
        let value: Nullable<SymbolShape> = constant.map({ Nullable($0) }) ?? .v1(ExplicitNull())
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: value)
    }
}



// MARK: VizEncode: detail

public extension VizEncode where Channel == FacetedEncoding.EncodingDetail {
    enum DetailChannel {
        case detail
    }

    typealias ChannelFieldType = Channel.RawValue.T1 // TypedFieldDef
    typealias ChannelMultiFieldType = Channel.RawValue.T2 // [TypedFieldDef]
}

public extension VizEncode where Channel == FacetedEncoding.EncodingDetail, Def == Channel.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> TypedFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ detail: DetailChannel) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ detail: DetailChannel, field: FieldNameRepresentable) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ detail: DetailChannel, repeat: RepeatRef) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }
}


// MARK: VizEncode: order

public extension VizEncode where Channel == FacetedEncoding.EncodingOrder {
    enum OrderChannel {
        case order
    }

    typealias ChannelFieldType = Channel.RawValue.T1.T1 // OrderFieldDef
    typealias ChannelMultiFieldType = Channel.RawValue.T1.T2 // [OrderFieldDef]
    typealias ChannelValueType = Channel.RawValue.T2 // OrderValueDef

}

public extension VizEncode where Channel == FacetedEncoding.EncodingOrder, Def == Channel.RawValue.T1.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> OrderFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ order: OrderChannel) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ order: OrderChannel, field: FieldNameRepresentable) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ order: OrderChannel, repeat: RepeatRef) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }
}

public extension VizEncode where Channel == FacetedEncoding.EncodingOrder, Def == Channel.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> OrderValueDef { def }

    /// Creates this encoding with the given constant value.
    init(_ order: OrderChannel, value constant: Double) {
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ order: OrderChannel, expr expression: ExprRef) {
        let value: Def.ValueChoice.T2 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) 
    }
}

// MARK: VizEncode: text

public extension VizEncode where Channel == FacetedEncoding.EncodingText {
    enum TextChannel {
        case text
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Field Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingText, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionStringFieldDefText { def }

    /// Creates an empty instance of this encoding.
    init(_ text: TextChannel) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ text: TextChannel, field: FieldNameRepresentable) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ text: TextChannel, repeat: RepeatRef) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingText, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionStringDatumDefText { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ text: TextChannel, datum: ExplicitNull) {
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ text: TextChannel, datum: Double) {
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ text: TextChannel, datum: String) {
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ text: TextChannel, datum: Bool) {
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ text: TextChannel, datum: DateTime) {
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ text: TextChannel, expression: String) {
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ text: TextChannel, datum: RepeatRef) {
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingText, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefWithConditionStringFieldDefText { def }

    /// Creates this encoding with the given constant value.
    init(_ text: TextChannel, value string: String) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(.init(string)))
    }

    /// Creates this encoding with the given constant value.
    init(_ text: TextChannel, values stringArray: [String]) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(.init(stringArray)))
    }

    /// Creates this encoding with the given constant value.
    init(_ text: TextChannel, expression: ExprRef) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(expression))
    }

}



// MARK: VizEncode: tooltip

public extension VizEncode where Channel == FacetedEncoding.EncodingTooltip {
    enum TooltipChannel {
        case tooltip
    }

    typealias ChannelNullType = Channel.RawValue.T1
    typealias ChannelFieldType = Channel.RawValue.T2.T1
    typealias ChannelValueType = Channel.RawValue.T2.T2
    typealias ChannelMultiFieldType = Channel.RawValue.T2.T3
}

public extension VizEncode where Channel == FacetedEncoding.EncodingTooltip, Def == Channel.RawValue.T2.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> StringFieldDefWithCondition { def }

    /// Creates an empty instance of this encoding.
    init(_ tooltip: TooltipChannel) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ tooltip: TooltipChannel, field: FieldNameRepresentable) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ tooltip: TooltipChannel, repeat: RepeatRef) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }
}

public extension VizEncode where Channel == FacetedEncoding.EncodingTooltip, Def == Channel.RawValue.T2.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> StringValueDefWithCondition { def }

    /// Creates this encoding with the given constant value.
    init(_ tooltip: TooltipChannel, value null: ExplicitNull) {
        let value: Def.ValueChoice.T1 = null
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(.init(value)))
    }

    /// Creates this encoding with the given constant value.
    init(_ tooltip: TooltipChannel, value constant: String) {
        let value: Def.ValueChoice.T2.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(.init(value)))
    }

    /// Creates this encoding with the given constant value.
    init(_ tooltip: TooltipChannel, expr expression: ExprRef) {
        let value: Def.ValueChoice.T2.T2 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(.init(value)))
    }
}

public extension VizEncode where Channel == FacetedEncoding.EncodingTooltip, Def == Channel.RawValue.T2.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> [StringFieldDef] { def }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ tooltip: TooltipChannel, fields: [FieldNameRepresentable]) {
        self.deriveChannel = { .init(.init($0)) }
        self.def = fields.map {
            StringFieldDef(field: .init($0.fieldName))
        }
    }
}


private func emptyConstructor(channel: EncodingChannel) -> VizEncodeType {
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


extension FacetedEncoding.EncodingDetail : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .detail

    public func addChannel(to encodings: inout FacetedEncoding) {
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

extension FacetedEncoding.EncodingOrder : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .order
    public func addChannel(to encodings: inout FacetedEncoding) {
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


extension FacetedEncoding.EncodingTooltip : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .tooltip
    public func addChannel(to encodings: inout FacetedEncoding) {
        if encodings.tooltip != nil {
            // TODO: in theory, we could handle the special case of one tooltip with an array of fields being added to another tooltip with an array of fields…
            warnReplaceEncoding(self)
        }
        encodings.tooltip = self
    }
}



// MARK: VizEncodingChannelType Single-Field

extension FacetedEncoding.EncodingText : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .text
    public func addChannel(to encodings: inout FacetedEncoding) {
        if encodings.text != nil {
            warnReplaceEncoding(self)
        }
        encodings.text = self
    }
}

extension FacetedEncoding.EncodingAngle : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .angle
    public func addChannel(to encodings: inout FacetedEncoding) {
        if encodings.angle != nil {
            warnReplaceEncoding(self)
        }
        encodings.angle = self
    }
}

extension FacetedEncoding.EncodingColor : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .color
    public func addChannel(to encodings: inout FacetedEncoding) {
        if encodings.color != nil {
            warnReplaceEncoding(self)
        }
        encodings.color = self
    }
}

extension FacetedEncoding.EncodingDescription : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .description
    public func addChannel(to encodings: inout FacetedEncoding) {
        if encodings.description != nil {
            warnReplaceEncoding(self)
        }
        encodings.description = self
    }
}

extension FacetedEncoding.EncodingFill : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .fill
    public func addChannel(to encodings: inout FacetedEncoding) {
        if encodings.fill != nil {
            warnReplaceEncoding(self)
        }
        encodings.fill = self
    }
}

extension FacetedEncoding.EncodingFillOpacity : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .fillOpacity
    public func addChannel(to encodings: inout FacetedEncoding) {
        if encodings.fillOpacity != nil {
            warnReplaceEncoding(self)
        }
        encodings.fillOpacity = self
    }
}

extension FacetedEncoding.EncodingHref : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .href
    public func addChannel(to encodings: inout FacetedEncoding) {
        if encodings.href != nil {
            warnReplaceEncoding(self)
        }
        encodings.href = self
    }
}

extension FacetedEncoding.EncodingLatitude : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .latitude
    public func addChannel(to encodings: inout FacetedEncoding) {
        if encodings.latitude != nil {
            warnReplaceEncoding(self)
        }
        encodings.latitude = self
    }
}

extension FacetedEncoding.EncodingLatitude2 : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .latitude2
    public func addChannel(to encodings: inout FacetedEncoding) {
        if encodings.latitude2 != nil {
            warnReplaceEncoding(self)
        }
        encodings.latitude2 = self
    }
}

extension FacetedEncoding.EncodingLongitude : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .longitude
    public func addChannel(to encodings: inout FacetedEncoding) {
        if encodings.longitude != nil {
            warnReplaceEncoding(self)
        }
        encodings.longitude = self
    }
}

extension FacetedEncoding.EncodingLongitude2 : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .longitude2
    public func addChannel(to encodings: inout FacetedEncoding) {
        if encodings.longitude2 != nil {
            warnReplaceEncoding(self)
        }
        encodings.longitude2 = self
    }
}

extension FacetedEncoding.EncodingOpacity : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .opacity
    public func addChannel(to encodings: inout FacetedEncoding) {
        if encodings.opacity != nil {
            warnReplaceEncoding(self)
        }
        encodings.opacity = self
    }
}


extension FacetedEncoding.EncodingRadius : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .radius
    public func addChannel(to encodings: inout FacetedEncoding) {
        if encodings.radius != nil {
            warnReplaceEncoding(self)
        }
        encodings.radius = self
    }
}

extension FacetedEncoding.EncodingRadius2 : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .radius2
    public func addChannel(to encodings: inout FacetedEncoding) {
        if encodings.radius2 != nil {
            warnReplaceEncoding(self)
        }
        encodings.radius2 = self
    }
}

extension FacetedEncoding.EncodingShape : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .shape
    public func addChannel(to encodings: inout FacetedEncoding) {
        if encodings.shape != nil {
            warnReplaceEncoding(self)
        }
        encodings.shape = self
    }
}

extension FacetedEncoding.EncodingSize : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .size
    public func addChannel(to encodings: inout FacetedEncoding) {
        if encodings.size != nil {
            warnReplaceEncoding(self)
        }
        encodings.size = self
    }
}

extension FacetedEncoding.EncodingStroke : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .stroke
    public func addChannel(to encodings: inout FacetedEncoding) {
        if encodings.stroke != nil {
            warnReplaceEncoding(self)
        }
        encodings.stroke = self
    }
}

extension FacetedEncoding.EncodingStrokeDash : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .strokeDash
    public func addChannel(to encodings: inout FacetedEncoding) {
        if encodings.strokeDash != nil {
            warnReplaceEncoding(self)
        }
        encodings.strokeDash = self
    }
}

extension FacetedEncoding.EncodingStrokeOpacity : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .strokeOpacity
    public func addChannel(to encodings: inout FacetedEncoding) {
        if encodings.strokeOpacity != nil {
            warnReplaceEncoding(self)
        }
        encodings.strokeOpacity = self
    }
}

extension FacetedEncoding.EncodingStrokeWidth : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .strokeWidth
    public func addChannel(to encodings: inout FacetedEncoding) {
        if encodings.strokeWidth != nil {
            warnReplaceEncoding(self)
        }
        encodings.strokeWidth = self
    }
}

extension FacetedEncoding.EncodingTheta : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .theta
    public func addChannel(to encodings: inout FacetedEncoding) {
        if encodings.theta != nil {
            warnReplaceEncoding(self)
        }
        encodings.theta = self
    }
}

extension FacetedEncoding.EncodingTheta2 : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .theta2
    public func addChannel(to encodings: inout FacetedEncoding) {
        if encodings.theta2 != nil {
            warnReplaceEncoding(self)
        }
        encodings.theta2 = self
    }
}


extension FacetedEncoding.EncodingUrl : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .url
    public func addChannel(to encodings: inout FacetedEncoding) {
        if encodings.url != nil {
            warnReplaceEncoding(self)
        }
        encodings.url = self
    }
}

extension FacetedEncoding.EncodingX : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .x
    public func addChannel(to encodings: inout FacetedEncoding) {
        if encodings.x != nil {
            warnReplaceEncoding(self)
        }
        encodings.x = self
    }
}

extension FacetedEncoding.EncodingX2 : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .x2
    public func addChannel(to encodings: inout FacetedEncoding) {
        if encodings.x2 != nil {
            warnReplaceEncoding(self)
        }
        encodings.x2 = self
    }
}

extension FacetedEncoding.EncodingXError : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .xError
    public func addChannel(to encodings: inout FacetedEncoding) {
        if encodings.xError != nil {
            warnReplaceEncoding(self)
        }
        encodings.xError = self
    }
}

extension FacetedEncoding.EncodingXError2 : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .xError2
    public func addChannel(to encodings: inout FacetedEncoding) {
        if encodings.xError2 != nil {
            warnReplaceEncoding(self)
        }
        encodings.xError2 = self
    }
}

extension FacetedEncoding.EncodingY : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .y
    public func addChannel(to encodings: inout FacetedEncoding) {
        if encodings.y != nil {
            warnReplaceEncoding(self)
        }
        encodings.y = self
    }
}

extension FacetedEncoding.EncodingY2 : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .y2
    public func addChannel(to encodings: inout FacetedEncoding) {
        if encodings.y2 != nil {
            warnReplaceEncoding(self)
        }
        encodings.y2 = self
    }
}

extension FacetedEncoding.EncodingYError : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .yError
    public func addChannel(to encodings: inout FacetedEncoding) {
        if encodings.yError != nil {
            warnReplaceEncoding(self)
        }
        encodings.yError = self
    }
}

extension FacetedEncoding.EncodingYError2 : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .yError2
    public func addChannel(to encodings: inout FacetedEncoding) {
        if encodings.yError2 != nil {
            warnReplaceEncoding(self)
        }
        encodings.yError2 = self
    }
}

extension FacetedEncoding.EncodingRow : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .row
    public func addChannel(to encodings: inout FacetedEncoding) {
        if encodings.row != nil {
            warnReplaceEncoding(self)
        }
        encodings.row = self
    }
}

extension FacetedEncoding.EncodingColumn : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .column
    public func addChannel(to encodings: inout FacetedEncoding) {
        if encodings.column != nil {
            warnReplaceEncoding(self)
        }
        encodings.column = self
    }
}

extension FacetedEncoding.EncodingFacet : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .facet
    public func addChannel(to encodings: inout FacetedEncoding) {
        if encodings.facet != nil {
            warnReplaceEncoding(self)
        }
        encodings.facet = self
    }
}

extension FacetedEncoding.EncodingKey : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .key
    public func addChannel(to encodings: inout FacetedEncoding) {
        if encodings.key != nil {
            warnReplaceEncoding(self)
        }
        encodings.key = self
    }
}


/// Issues a warning to the console that the existing encoding is being replaced
func warnReplaceEncoding<C: VizEncodingChannelType>(_ instance: C) {
    print("warnReplaceEncoding: encoding for \(C.encodingChannel.rawValue) overrides existing definition")
}


/// Work-in-progress, simply to highlight a line with a deprecation warning
@available(*, deprecated, message: "work-in-progress")
fileprivate func wip<T>(_ value: T) -> T { value }
