import GGSpec
import BricBrac

// A DSL for constructing a data visualization in Swift.


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

/// A type that converts the properties of an encapsulated instance into dynamic builder DSL types. For example, the following will be equivalent:
///
/// ```swift
/// var ob = Thing()
/// ob.name = "ABC"
/// ob.name("ABC")
/// ```
///
/// In addition, properties that reach towards `OneOf` types will also have setters for each of the union types. For example:
///
/// ```swift
/// struct Thing {
///     var prop: OneOf2<String>.Or<Int>
/// }
///
/// thing.prop = .v1("String")
/// thing.prop = .v2(123)
///
/// thing.prop("ABC")
/// thing.prop(123)
/// ```
///
/// - Note: This type is compatible with `RawRepresentable`, but it does not conform to it. The encapsulated `rawValue` is not guaranteed to completely represent the underlying value.
public protocol EncapsulatedPropertyRouter {
    associatedtype RawValue
    var rawValue: RawValue { get set }
}

extension EncapsulatedPropertyRouter {
    /// Fluent DSL setting function for all the mutable properties of an instance
    @inlinable public subscript<U>(dynamicMember keyPath: WritableKeyPath<RawValue, U>) -> (U) -> (Self) {
        { assigning(value: $0, to: keyPath, with: { $0 }) }
    }

    /// Fluent DSL setting function for all the mutable properties of a raw instance
    @inlinable public subscript<R: RawInitializable, U>(dynamicMember keyPath: WritableKeyPath<RawValue, R?>) -> (U) -> (Self) where R.RawValue == U {
        { assigning(value: $0, to: keyPath, with: { R(rawValue: $0) }) }
    }

    /// Fluent DSL setting function for all the mutable `OneOf` properties of an instance
    @inlinable public subscript<Choice: OneOf2Type, U>(dynamicMember keyPath: WritableKeyPath<RawValue, Choice?>) -> (U) -> (Self) where Choice.T1 == U {
        { assigning(value: $0, to: keyPath, with: { .init($0) }) }
    }

    /// Fluent DSL setting function for all the mutable `OneOf` properties of an instance that can be initialized with a raw value
    @inlinable public subscript<Choice: OneOf2Type, R: RawInitializable, U>(dynamicMember keyPath: WritableKeyPath<RawValue, Choice?>) -> (U) -> (Self) where Choice.T1 == R, R.RawValue == U {
        { assigning(value: $0, to: keyPath, with: { .init(R(rawValue: $0)) }) }
    }

    /// Fluent DSL setting function for all the mutable `OneOf` properties of an instance
    @inlinable public subscript<Choice: OneOf2Type, U>(dynamicMember keyPath: WritableKeyPath<RawValue, Choice?>) -> (U) -> (Self) where Choice.T2 == U {
        { assigning(value: $0, to: keyPath, with: { .init($0) }) }
    }

    /// Fluent DSL setting function for all the mutable `OneOf` properties of an instance that can be initialized with a raw value
    @inlinable public subscript<Choice: OneOf2Type, R: RawInitializable, U>(dynamicMember keyPath: WritableKeyPath<RawValue, Choice?>) -> (U) -> (Self) where Choice.T2 == R, R.RawValue == U {
        { assigning(value: $0, to: keyPath, with: { .init(R(rawValue: $0)) }) }
    }

    /// Fluent DSL setting function for all the mutable `OneOf` properties of an instance
    @inlinable public subscript<Choice: OneOf3Type, U>(dynamicMember keyPath: WritableKeyPath<RawValue, Choice?>) -> (U) -> (Self) where Choice.T3 == U {
        { assigning(value: $0, to: keyPath, with: { .init($0) }) }
    }

    /// Fluent DSL setting function for all the mutable `OneOf` properties of an instance that can be initialized with a raw value
    @inlinable public subscript<Choice: OneOf3Type, R: RawInitializable, U>(dynamicMember keyPath: WritableKeyPath<RawValue, Choice?>) -> (U) -> (Self) where Choice.T3 == R, R.RawValue == U {
        { assigning(value: $0, to: keyPath, with: { .init(R(rawValue: $0)) }) }
    }

    /// Fluent DSL setting function for all the mutable `OneOf` properties of an instance
    @inlinable public subscript<Choice: OneOf4Type, U>(dynamicMember keyPath: WritableKeyPath<RawValue, Choice?>) -> (U) -> (Self) where Choice.T4 == U {
        { assigning(value: $0, to: keyPath, with: { .init($0) }) }
    }

    /// Fluent DSL setting function for all the mutable `OneOf` properties of an instance that can be initialized with a raw value
    @inlinable public subscript<Choice: OneOf4Type, R: RawInitializable, U>(dynamicMember keyPath: WritableKeyPath<RawValue, Choice?>) -> (U) -> (Self) where Choice.T4 == R, R.RawValue == U {
        { assigning(value: $0, to: keyPath, with: { .init(R(rawValue: $0)) }) }
    }

    /// Fluent DSL setting function for all the mutable `OneOf` properties of an instance
    @inlinable public subscript<Choice: OneOf5Type, U>(dynamicMember keyPath: WritableKeyPath<RawValue, Choice?>) -> (U) -> (Self) where Choice.T5 == U {
        { assigning(value: $0, to: keyPath, with: { .init($0) }) }
    }

    /// Fluent DSL setting function for all the mutable `OneOf` properties of an instance that can be initialized with a raw value
    @inlinable public subscript<Choice: OneOf5Type, R: RawInitializable, U>(dynamicMember keyPath: WritableKeyPath<RawValue, Choice?>) -> (U) -> (Self) where Choice.T5 == R, R.RawValue == U {
        { assigning(value: $0, to: keyPath, with: { .init(R(rawValue: $0)) }) }
    }

    /// Assigns the given  value to the keyPath using the specific transform function
    @usableFromInline func assigning<T, U>(value: T, to keyPath: WritableKeyPath<RawValue, U>, with transform: (T) throws -> (U)) rethrows -> Self {
        var this = self
        this.rawValue[keyPath: keyPath] = try transform(value)
        return this
    }
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

/// An element that can be added to a `VizEncode`, sich as `VizAxis`, `VizLegend`, and `VizScale`
public protocol VizEncodingElementType : VizSpecBuilderType {
    func add<E: VizMarkElementType>(to encoding: inout E)
}

public protocol VizMarkType : VizSpecElementType {
    var encodings: EncodingChannelMap { get }
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
public struct VizTheme : VizSpecElementType, EncapsulatedPropertyRouter {
    public var rawValue: GGSpec.ConfigTheme

    public init(rawValue: RawValue = .init()) { self.rawValue = rawValue }

    public func add<M>(to spec: inout VizSpec<M>) where M : Pure {
        spec.config = rawValue
    }
}



@dynamicMemberLookup
public struct VizProjection : VizSpecElementType, EncapsulatedPropertyRouter, VizDSLType {
    public var rawValue: GGSpec.Projection

    public init(rawValue projection: Projection) {
        self.rawValue = projection
    }

    public init(_ type: ProjectionType? = nil, projection: GGSpec.Projection = GGSpec.Projection()) {
        self.rawValue = projection
        if let type = type {
            self.rawValue.type = .init(.init(type))
        }
    }

    public func add<M>(to spec: inout VizSpec<M>) where M : Pure {
        spec.projection = rawValue
    }
}


// MARK: DataTransform


@dynamicMemberLookup
public struct VizTransform<Def : VizTransformDefType> : VizSpecElementType, VizDSLType, EncapsulatedPropertyRouter {
    public var rawValue: Def
    private let makeElements: () -> [VizLayerElementType]

    public func add<M>(to spec: inout VizSpec<M>) where M : Pure {
        spec.transform[defaulting: []].append(rawValue.anyTransform)
        for element in makeElements() {
            element.add(to: &spec)
        }
    }
}

// MARK: DataTransform: Sample

extension SampleTransform : VizTransformDefType {
    public var anyTransform: DataTransformation { .init(self) }
}

public extension VizTransform where Def == SampleTransform {
    enum SampleLiteral { case sample }
    init(_ sampleTransform: SampleLiteral, sample: Double = 999, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.rawValue = .init(sample: sample)
        self.makeElements = makeElements
    }
}

extension AggregateTransform : VizTransformDefType {
    public var anyTransform: DataTransformation { .init(self) }
}

public extension VizTransform where Def == AggregateTransform {
    enum AggregateLiteral { case aggregate }
    init(_ aggregateTransform: AggregateLiteral, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.rawValue = .init()
        self.makeElements = makeElements
    }
}

extension BinTransform : VizTransformDefType {
    public var anyTransform: DataTransformation { .init(self) }
}

public extension VizTransform where Def == BinTransform {
    enum BinLiteral { case bin }
    init(_ binTransform: BinLiteral, field: FieldNameRepresentable, params: BinParams?, output as: [FieldNameRepresentable], @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.rawValue = .init(as: .init(`as`.map(\.fieldName)), bin: params.map({ .init($0) }) ?? .init(true), field: field.fieldName)
        self.makeElements = makeElements
    }
}

extension CalculateTransform : VizTransformDefType {
    public var anyTransform: DataTransformation { .init(self) }
}

public extension VizTransform where Def == CalculateTransform {
    enum CalculateLiteral { case calculate }
    init(_ calculateTransform: CalculateLiteral, output as: FieldNameRepresentable, expression calculate: Expr, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.rawValue = .init(as: `as`.fieldName, calculate: calculate)
        self.makeElements = makeElements
    }
}

extension DensityTransform : VizTransformDefType {
    public var anyTransform: DataTransformation { .init(self) }
}

public extension VizTransform where Def == DensityTransform {
    enum DensityLiteral { case density }
    init(_ densityTransform: DensityLiteral, field density: FieldNameRepresentable, group groupby: [FieldNameRepresentable]? = nil, bandwidth: Double? = nil, counts: Bool? = nil, cumulative: Bool? = nil, extent: [DensityTransform.ExtentItem]? = nil, maxsteps: Double? = nil, minsteps: Double? = nil, steps: Double? = nil, sampleOutput: FieldNameRepresentable? = nil, densityOutput: FieldNameRepresentable? = nil, @VizLayerElementArrayBuilder _ makeElements: @escaping (_ sampleValueOutput: FieldNameRepresentable, _ densityEstimateOutput: FieldNameRepresentable) -> [VizLayerElementType]) {
        self.rawValue = .init(as: sampleOutput == nil && densityOutput == nil ? nil : [(sampleOutput ?? "value").fieldName, (densityOutput ?? "density").fieldName], bandwidth: bandwidth, counts: counts, cumulative: cumulative, density: density.fieldName, extent: extent, groupby: groupby?.map(\.fieldName), maxsteps: maxsteps, minsteps: minsteps, steps: steps)
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
        self.rawValue = .init(filter: filter)
        self.makeElements = makeElements
    }
}

extension FlattenTransform : VizTransformDefType {
    public var anyTransform: DataTransformation { .init(self) }
}

public extension VizTransform where Def == FlattenTransform {
    enum FlattenLiteral { case flatten }
    init(_ flattenTransform: FlattenLiteral, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.rawValue = .init()
        self.makeElements = makeElements
    }
}

extension FoldTransform : VizTransformDefType {
    public var anyTransform: DataTransformation { .init(self) }
}

public extension VizTransform where Def == FoldTransform {
    enum FoldLiteral { case fold }
    init(_ foldTransform: FoldLiteral, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.rawValue = .init()
        self.makeElements = makeElements
    }
}

extension ImputeTransform : VizTransformDefType {
    public var anyTransform: DataTransformation { .init(self) }
}

public extension VizTransform where Def == ImputeTransform {
    enum ImputeLiteral { case impute }
    init(_ imputeTransform: ImputeLiteral, impute: FieldNameRepresentable, key: FieldNameRepresentable, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.rawValue = .init(impute: impute.fieldName, key: key.fieldName)
        self.makeElements = makeElements
    }
}

extension JoinAggregateTransform : VizTransformDefType {
    public var anyTransform: DataTransformation { .init(self) }
}

public extension VizTransform where Def == JoinAggregateTransform {
    enum JoinAggregateLiteral { case joinAggregate }
    init(_ joinAggregateTransform: JoinAggregateLiteral, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.rawValue = .init()
        self.makeElements = makeElements
    }
}

extension LoessTransform : VizTransformDefType {
    public var anyTransform: DataTransformation { .init(self) }
}

public extension VizTransform where Def == LoessTransform {
    enum LoessLiteral { case loess }
    init(_ loessTransform: LoessLiteral, field: FieldNameRepresentable, on: FieldNameRepresentable, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.rawValue = .init(loess: field.fieldName, on: on.fieldName)
        self.makeElements = makeElements
    }
}

extension LookupTransform : VizTransformDefType {
    public var anyTransform: DataTransformation { .init(self) }
}

public extension VizTransform where Def == LookupTransform {
    enum LookupLiteral { case lookup }
    init(_ lookupTransform: LookupLiteral, field: FieldNameRepresentable, data: LookupData, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.rawValue = .init(from: .init(data), lookup: field.fieldName)
        self.makeElements = makeElements
    }

    init(_ lookupTransform: LookupLiteral, field: FieldNameRepresentable, selection: LookupSelection, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.rawValue = .init(from: .init(selection), lookup: field.fieldName)
        self.makeElements = makeElements
    }
}

extension QuantileTransform : VizTransformDefType {
    public var anyTransform: DataTransformation { .init(self) }
}

public extension VizTransform where Def == QuantileTransform {
    enum QuantileLiteral { case quantile }
    init(_ quantileTransform: QuantileLiteral, field: FieldNameRepresentable, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.rawValue = .init(quantile: field.fieldName)
        self.makeElements = makeElements
    }
}

extension RegressionTransform : VizTransformDefType {
    public var anyTransform: DataTransformation { .init(self) }
}

public extension VizTransform where Def == RegressionTransform {
    enum RegressionLiteral { case regression }
    init(_ regressionTransform: RegressionLiteral, field: FieldName, on: FieldName, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.rawValue = .init(on: on.fieldName, regression: field.fieldName)
        self.makeElements = makeElements
    }
}

extension TimeUnitTransform : VizTransformDefType {
    public var anyTransform: DataTransformation { .init(self) }
}

public extension VizTransform where Def == TimeUnitTransform {
    enum TimeUnitLiteral { case timeUnit }
    init(_ timeUnitTransform: TimeUnitLiteral, field: FieldNameRepresentable, timeUnit: TimeUnit, output as: FieldNameRepresentable, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.rawValue = .init(as: `as`.fieldName, field: field.fieldName, timeUnit: .init(timeUnit))
        self.makeElements = makeElements
    }

    init(_ timeUnitTransform: TimeUnitLiteral, field: FieldNameRepresentable, params: TimeUnitParams, output as: FieldNameRepresentable, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.rawValue = .init(as: `as`.fieldName, field: field.fieldName, timeUnit: .init(params))
        self.makeElements = makeElements
    }

}

extension StackTransform : VizTransformDefType {
    public var anyTransform: DataTransformation { .init(self) }
}

public extension VizTransform where Def == StackTransform {
    enum StackLiteral { case stack }
    init(_ stackTransform: StackLiteral, field stack: FieldNameRepresentable, startField: FieldNameRepresentable, endField: FieldNameRepresentable, @VizLayerElementArrayBuilder _ makeElements: @escaping (_ startField: FieldNameRepresentable, _ endField: FieldNameRepresentable) -> [VizLayerElementType]) {
        self.rawValue = .init(as: .init([startField.fieldName, endField.fieldName]), stack: stack.fieldName)
        self.makeElements = { makeElements(startField, endField) }
    }
}

extension WindowTransform : VizTransformDefType {
    public var anyTransform: DataTransformation { .init(self) }
}

public extension VizTransform where Def == WindowTransform {
    enum WindowLiteral { case window }
    init(_ windowTransform: WindowLiteral, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.rawValue = .init()
        self.makeElements = makeElements
    }
}

extension PivotTransform : VizTransformDefType {
    public var anyTransform: DataTransformation { .init(self) }
}

public extension VizTransform where Def == PivotTransform {
    enum PivotLiteral { case pivot }
    init(_ pivotTransform: PivotLiteral, pivot: FieldNameRepresentable, value: FieldNameRepresentable, @VizLayerElementArrayBuilder _ makeElements: @escaping () -> [VizLayerElementType]) {
        self.rawValue = .init(pivot: pivot.fieldName, value: value.fieldName)
        self.makeElements = makeElements
    }
}


// MARK: Layers

/// A `Viz` encapsulates a top-level `VizSpec` layer and is used as the basis for the builder DSL.
@dynamicMemberLookup
public struct Viz<M: Pure> : VizLayerType, EncapsulatedPropertyRouter {
    public var rawValue: VizSpec<M>

    public init(rawValue: VizSpec<M> = VizSpec<M>()) {
        self.rawValue = rawValue
    }

    public init(spec fromSpec: VizSpec<M> = VizSpec<M>(), @VizSpecElementArrayBuilder _ makeElements: () -> [VizSpecElementType]) {
        var spec = fromSpec
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
public struct VizMark<Def : VizMarkDefType> : VizMarkType, VizDSLType, EncapsulatedPropertyRouter {
    public var markDef: Def
    public var encodings: EncodingChannelMap = EncodingChannelMap()

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

public extension VizMark where Def == MarkDef {
    init(_ primitiveMark: PrimitiveMarkType) {
        self.init(primitiveMark) { }
    }

    init(_ primitiveMark: PrimitiveMarkType, @VizMarkElementArrayBuilder makeEncodings: () -> [VizMarkElementType]) {
        markDef = MarkDef(type: primitiveMark)
        addEncodings(makeEncodings())
    }
}

public extension VizMark where Def == BoxPlotDef {
    init(_ boxPlot: BoxPlotLiteral) {
        self.init(boxPlot) { }
    }

    init(_ boxPlot: BoxPlotLiteral, @VizMarkElementArrayBuilder makeEncodings: () -> [VizMarkElementType]) {
        markDef = BoxPlotDef(type: boxPlot)
        addEncodings(makeEncodings())
    }
}

public extension VizMark where Def == ErrorBarDef {
    init(_ errorBar: ErrorBarLiteral) {
        self.init(errorBar) { }
    }

    init(_ errorBar: ErrorBarLiteral, @VizMarkElementArrayBuilder makeEncodings: () -> [VizMarkElementType]) {
        markDef = ErrorBarDef(type: errorBar)
        addEncodings(makeEncodings())
    }
}

public extension VizMark where Def == ErrorBandDef {
    init(_ errorBand: ErrorBandLiteral) {
        self.init(errorBand) { }
    }

    init(_ errorBand: ErrorBandLiteral, @VizMarkElementArrayBuilder makeEncodings: () -> [VizMarkElementType]) {
        markDef = ErrorBandDef(type: errorBand)
        addEncodings(makeEncodings())
    }
}

public protocol VizMarkElementType : VizDSLType {
    /// Adds this encoding information to the given `EncodingChannelMap`
    func addEncoding(to encodings: inout EncodingChannelMap)
}



// MARK: Guides

public typealias AnyGuide = OneOf<AxisDef>.Or<LegendDef>.Or<HeaderDef>

public protocol VizGuideDefType : Pure {
    var anyGuide: AnyGuide { get }
}

extension AxisDef : VizGuideDefType {
    public var anyGuide: AnyGuide { .init(self) }
}

extension LegendDef : VizGuideDefType {
    public var anyGuide: AnyGuide { .init(self) }
}

extension HeaderDef : VizGuideDefType {
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
public protocol VizAxisEncodeElementType : VizGuidedEncodeElementType {
    var rawValue: AxisDef { get }
}

/// A `VizEncodeElementType` that can contain a legend
public protocol VizLegendEncodeElementType : VizGuidedEncodeElementType {
    var rawValue: LegendDef { get }
}

/// A `VizEncodeElementType` that can contain a header
public protocol VizHeaderEncodeElementType : VizGuidedEncodeElementType {
    var rawValue: HeaderDef { get }
}

public protocol VizScaleEncodeElementType : VizEncodeElementType {
    var rawValue: ScaleDef { get }
}


extension VizEncodeElementType {
    /// If this element has an axis, returns the axis def.
    var axis: AxisDef? {
        if let axisElement = self as? VizAxisEncodeElementType {
            return axisElement.rawValue
        } else {
            return nil
        }
    }

    /// If this element has an legend, returns the legend def.
    var legend: LegendDef? {
        if let legendElement = self as? VizLegendEncodeElementType {
            return legendElement.rawValue
        } else {
            return nil
        }
    }

    /// If this element has an header, returns the header def.
    var header: HeaderDef? {
        if let headerElement = self as? VizHeaderEncodeElementType {
            return headerElement.rawValue
        } else {
            return nil
        }
    }

    /// If this element has an scale, returns the scale def.
    var scale: ScaleDef? {
        if let scaleElement = self as? VizScaleEncodeElementType {
            return scaleElement.rawValue
        } else {
            return nil
        }
    }
}

/// Scales map data values (numbers, dates, categories, etc.) to visual values (pixels, colors, sizes).
@dynamicMemberLookup
public struct VizScale<Def : VizGuideDefType> : VizScaleEncodeElementType, VizDSLType, EncapsulatedPropertyRouter {
    public var rawValue: ScaleDef

    public init(rawValue scaleDef: ScaleDef = ScaleDef()) {
        self.rawValue = scaleDef
    }
}

/// A guide, which can be an `.axis`, `.legend`, or `.header`
public protocol VizGuideType : VizEncodeElementType {
}


@dynamicMemberLookup
public struct VizGuide<Def : VizGuideDefType> : VizGuideType, VizDSLType, EncapsulatedPropertyRouter {
    public var rawValue: Def

    public init(rawValue guideDef: Def) {
        self.rawValue = guideDef
    }
}

extension VizGuide : VizGuidedEncodeElementType {

}

extension VizGuide : VizLegendEncodeElementType where Def == LegendDef {
    public enum LegendGuide {
        /// A legend is a guide that shows the values for non-positional visual scales such as color, size, or line dash patterns.
        case legend
    }

    public init(_ legend: LegendGuide = .legend, guideDef: LegendDef = LegendDef()) {
        self.rawValue = guideDef
    }
}

extension VizGuide : VizAxisEncodeElementType where Def == AxisDef {
    public enum AxisGuide {
        /// An axis is a guide that for positional scales
        case axis
    }

    public init(_ axis: AxisGuide = .axis, guideDef: AxisDef = AxisDef()) {
        self.rawValue = guideDef
    }
}

extension VizGuide : VizHeaderEncodeElementType where Def == HeaderDef {
    public enum HeaderGuide {
        /// An header is a guide that for headers
        case header
    }

    public init(_ header: HeaderGuide = .header, guideDef: HeaderDef = HeaderDef()) {
        self.rawValue = guideDef
    }
}



// MARK: Builders

//public typealias VizMarkArrayBuilder = VizArrayBuilder<VizMarkType>

public typealias VizSpecElementArrayBuilder = VizArrayBuilder<VizSpecElementType>
public typealias VizLayerElementArrayBuilder = VizArrayBuilder<VizLayerElementType>
public typealias VizMarkElementArrayBuilder = VizArrayBuilder<VizMarkElementType>


@resultBuilder
public enum VizArrayBuilder<Element> {
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

public extension VizSpec {
    /// Set the given specification a repeat along a single dimension.
    ///
    /// - Parameters:
    ///   - repeatSpec: the specification to repeat
    ///   - fields: the fields to apply to the repeat fields
    ///   - repeatArrangement: the arrangement of the repeat (`.horizontal`, `.vertical`, `.wrap`, `.overlay`)
    mutating func setRepeating(spec repeatSpec: Self, fields: [FieldName], arrangement repeatArrangement: LayerArrangement) {
        self.arrangement = nil // .repeat
        self.spec = .init(repeatSpec) // add it as the `repeat spec`
        switch repeatArrangement {
        case .overlay:
            self.repeat = .init(LayerRepeatMapping(layer: fields))
        case .horizontal:
            self.repeat = .init(RepeatMapping(column: fields))
        case .vertical:
            self.repeat = .init(RepeatMapping(row: fields))
        case .wrap:
            self.repeat = .init(fields)
        }
    }
}

public struct VizRepeat : VizSpecElementType, VizLayerType {
    var repeatArrangement: LayerArrangement
    let repeatFields: [FieldNameRepresentable]
    let makeElements: () -> [VizLayerElementType]

    public init(_ repeatArrangement: LayerArrangement, fields repeatFields: [FieldNameRepresentable], @VizLayerElementArrayBuilder _ makeElements: @escaping (_ ref: RepeatRef) -> [VizLayerElementType]) {
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




// MARK: Encodings


public protocol VizEncodingChannelType : Pure, RawCodable {
    static var encodingChannel: EncodingChannel { get }

    func addChannel(to encodings: inout EncodingChannelMap, elements: [VizEncodeElementType])
}

@dynamicMemberLookup
public struct VizEncode<Channel : VizEncodingChannelType, Def : Pure> : EncapsulatedPropertyRouter {
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
    public func addEncoding(to encodings: inout EncodingChannelMap) {
        deriveChannel(rawValue).addChannel(to: &encodings, elements: makeElements())
    }
}



// MARK: VizEncode: X

public extension VizEncode where Channel == EncodingChannelMap.XEncoding {
    enum XChannel {
        /// x and y position channels determine the position of the marks, or width/height of horizontal/vertical "area" and "bar". In addition, x2 and y2 can specify the span of ranged area, bar, rect, and rule.
        case x
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Empty Initializers
public extension VizEncode where Channel == EncodingChannelMap.XEncoding, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> PositionFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ x: XChannel, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ x: XChannel, field: FieldNameRepresentable, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ x: XChannel, repeat: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == EncodingChannelMap.XEncoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> PositionDatumDef { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ x: XChannel, datum: ExplicitNull, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ x: XChannel, datum: Double, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ x: XChannel, datum: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ x: XChannel, datum: Bool, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ x: XChannel, datum: DateTime, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ x: XChannel, expression: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ x: XChannel, datum: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == EncodingChannelMap.XEncoding, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefNumberWidthHeightExprRef { def }

    /// Creates this encoding with the given constant value.
    init(_ x: XChannel, value constant: Double, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ x: XChannel, value constant: LiteralWidth, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ x: XChannel, value constant: LiteralHeight, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T3 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with a dynamic expression.
    init(_ x: XChannel, expression: ExprRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T4 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }
}








// MARK: VizEncode: Y

public extension VizEncode where Channel == EncodingChannelMap.YEncoding {

    enum YChannel {
        /// x and y position channels determine the position of the marks, or width/height of horizontal/vertical "area" and "bar". In addition, x2 and y2 can specify the span of ranged area, bar, rect, and rule.
        case y
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Empty Initializers
public extension VizEncode where Channel == EncodingChannelMap.YEncoding, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> PositionFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ y: YChannel, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ y: YChannel, field: FieldNameRepresentable, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ y: YChannel, repeat: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == EncodingChannelMap.YEncoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> PositionDatumDef { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ y: YChannel, datum: ExplicitNull, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ y: YChannel, datum: Double, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ y: YChannel, datum: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ y: YChannel, datum: Bool, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ y: YChannel, datum: DateTime, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ y: YChannel, expression: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ y: YChannel, datum: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == EncodingChannelMap.YEncoding, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefNumberWidthHeightExprRef { def }

    /// Creates this encoding with the given constant value.
    init(_ y: YChannel, value constant: Double, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ y: YChannel, value constant: LiteralWidth, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ y: YChannel, value constant: LiteralHeight, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T3 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with a dynamic expression.
    init(_ y: YChannel, expression: ExprRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T4 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }
}




// MARK: VizEncode: x2

public extension VizEncode where Channel == EncodingChannelMap.X2Encoding {



    enum X2Channel {
        /// x and y position channels determine the position of the marks, or width/height of horizontal/vertical "area" and "bar". In addition, x2 and y2 can specify the span of ranged area, bar, rect, and rule.
        case x2
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Empty Initializers
public extension VizEncode where Channel == EncodingChannelMap.X2Encoding, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> SecondaryFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ x2: X2Channel, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ x2: X2Channel, field: FieldNameRepresentable, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ x2: X2Channel, repeat: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == EncodingChannelMap.X2Encoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> DatumDef { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ x2: X2Channel, datum: ExplicitNull, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ x2: X2Channel, datum: Double, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ x2: X2Channel, datum: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ x2: X2Channel, datum: Bool, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ x2: X2Channel, datum: DateTime, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ x2: X2Channel, expression: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ x2: X2Channel, datum: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == EncodingChannelMap.X2Encoding, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefNumberWidthHeightExprRef { def }

    /// Creates this encoding with the given constant value.
    init(_ x2: X2Channel, value constant: Double, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ x2: X2Channel, value constant: LiteralWidth, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ x2: X2Channel, value constant: LiteralHeight, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T3 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with a dynamic expression.
    init(_ x2: X2Channel, expression: ExprRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T4 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }
}






// MARK: VizEncode: y2


public extension VizEncode where Channel == EncodingChannelMap.Y2Encoding {



    enum Y2Channel {
        /// x and y position channels determine the position of the marks, or width/height of horizontal/vertical "area" and "bar". In addition, x2 and y2 can specify the span of ranged area, bar, rect, and rule.
        case y2
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Empty Initializers
public extension VizEncode where Channel == EncodingChannelMap.Y2Encoding, Def == SecondaryFieldDef {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> SecondaryFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ y2: Y2Channel, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ y2: Y2Channel, field: FieldNameRepresentable, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ y2: Y2Channel, repeat: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == EncodingChannelMap.Y2Encoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> DatumDef { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ y2: Y2Channel, datum: ExplicitNull, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ y2: Y2Channel, datum: Double, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ y2: Y2Channel, datum: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ y2: Y2Channel, datum: Bool, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ y2: Y2Channel, datum: DateTime, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ y2: Y2Channel, expression: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ y2: Y2Channel, datum: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == EncodingChannelMap.Y2Encoding, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefNumberWidthHeightExprRef { def }

    /// Creates this encoding with the given constant value.
    init(_ y2: Y2Channel, value constant: Double, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ y2: Y2Channel, value constant: LiteralWidth, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ y2: Y2Channel, value constant: LiteralHeight, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T3 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with a dynamic expression.
    init(_ y2: Y2Channel, expression: ExprRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T4 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }
}




// MARK: VizEncode: Color

public extension VizEncode where Channel == EncodingChannelMap.ColorEncoding {



    enum ColorChannel {
        /// Color of the marks – either fill or stroke color based on the filled property of mark definition. By default, color represents fill color for "area", "bar", "tick", "text", "trail", "circle", and "square" / stroke color for "line" and "point".
        case color
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Field Initializers
public extension VizEncode where Channel == EncodingChannelMap.ColorEncoding, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionMarkPropFieldDefGradientStringNull { def }

    /// Creates an empty instance of this encoding.
    init(_ color: ColorChannel, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ color: ColorChannel, field: FieldNameRepresentable, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ color: ColorChannel, repeat: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == EncodingChannelMap.ColorEncoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionDatumDefGradientStringNull { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ color: ColorChannel, datum: ExplicitNull, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ color: ColorChannel, datum: Double, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ color: ColorChannel, datum: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ color: ColorChannel, datum: Bool, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ color: ColorChannel, datum: DateTime, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ color: ColorChannel, expression: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ color: ColorChannel, datum: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == EncodingChannelMap.ColorEncoding, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefWithConditionMarkPropFieldOrDatumDefGradientStringNull { def }

    /// Creates this encoding with the given constant value.
    init(_ color: ColorChannel, value constant: ExplicitNull, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ color: ColorChannel, value constant: ColorGradientLinear, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.init(color, value: .init(.init(constant)), makeElements: makeElements)
    }

    /// Creates this encoding with the given constant value.
    init(_ color: ColorChannel, value constant: ColorGradientRadial, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.init(color, value: .init(.init(constant)), makeElements: makeElements)
    }

    /// Creates this encoding with the given constant color value.
    init(_ color: ColorChannel, value constant: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.init(color, value: .init(constant), makeElements: makeElements)
    }

    /// Creates this encoding with the given constant color expression.
    init(_ color: ColorChannel, expression: ExprRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.init(color, value: .init(expression), makeElements: makeElements)
    }

    private init(_ color: ColorChannel, value constant: OneOf3<ColorGradient, String, ExprRef>, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }
}





// MARK: VizEncode: Fill

public extension VizEncode where Channel == EncodingChannelMap.FillEncoding {



    enum FillChannel {
        /// Fill color of the marks. Default value: If undefined, the default color depends on mark config’s color property.
        case fill
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Field Initializers
public extension VizEncode where Channel == EncodingChannelMap.FillEncoding, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionMarkPropFieldDefGradientStringNull { def }

    /// Creates an empty instance of this encoding.
    init(_ fill: FillChannel, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ fill: FillChannel, field: FieldNameRepresentable, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ fill: FillChannel, repeat: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == EncodingChannelMap.FillEncoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionDatumDefGradientStringNull { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ fill: FillChannel, datum: ExplicitNull, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ fill: FillChannel, datum: Double, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ fill: FillChannel, datum: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ fill: FillChannel, datum: Bool, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ fill: FillChannel, datum: DateTime, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ fill: FillChannel, expression: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ fill: FillChannel, datum: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == EncodingChannelMap.FillEncoding, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefWithConditionMarkPropFieldOrDatumDefGradientStringNull { def }

    /// Creates this encoding with the given constant value.
    init(_ fill: FillChannel, value constant: ExplicitNull, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ fill: FillChannel, value constant: ColorGradientLinear, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.init(fill, value: .init(.init(constant)), makeElements: makeElements)
    }

    /// Creates this encoding with the given constant value.
    init(_ fill: FillChannel, value constant: ColorGradientRadial, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.init(fill, value: .init(.init(constant)), makeElements: makeElements)
    }

    /// Creates this encoding with the given constant color value.
    init(_ fill: FillChannel, value constant: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.init(fill, value: .init(constant), makeElements: makeElements)
    }

    // TODO: need to be able to create with constants
//    /// Creates this encoding with the given constant color value.
//    init(_ fill: FillChannel, value constant: ColorCode, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
//    self.makeElements = makeElements
//        self.init(fill, value: .init(constant))
//    }

    /// Creates this encoding with the given constant color expression.
    init(_ fill: FillChannel, expression: ExprRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.init(fill, value: .init(expression), makeElements: makeElements)
    }

    private init(_ fill: FillChannel, value constant: OneOf3<ColorGradient, String, ExprRef>, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }
}



// MARK: VizEncode: Stroke

public extension VizEncode where Channel == EncodingChannelMap.StrokeEncoding {



    enum StrokeChannel {
        /// Stroke color of the marks. Default value: If undefined, the default color depends on mark config’s color property.
        case stroke
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Field Initializers
public extension VizEncode where Channel == EncodingChannelMap.StrokeEncoding, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionMarkPropFieldDefGradientStringNull { def }

    /// Creates an empty instance of this encoding.
    init(_ stroke: StrokeChannel, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ stroke: StrokeChannel, field: FieldNameRepresentable, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ stroke: StrokeChannel, repeat: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == EncodingChannelMap.StrokeEncoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionDatumDefGradientStringNull { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ stroke: StrokeChannel, datum: ExplicitNull, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ stroke: StrokeChannel, datum: Double, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ stroke: StrokeChannel, datum: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ stroke: StrokeChannel, datum: Bool, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ stroke: StrokeChannel, datum: DateTime, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ stroke: StrokeChannel, expression: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ stroke: StrokeChannel, datum: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == EncodingChannelMap.StrokeEncoding, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefWithConditionMarkPropFieldOrDatumDefGradientStringNull { def }

    /// Creates this encoding with the given constant value.
    init(_ stroke: StrokeChannel, value constant: ExplicitNull, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ stroke: StrokeChannel, value constant: ColorGradientLinear, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.init(stroke, value: .init(.init(constant)), makeElements: makeElements)
    }

    /// Creates this encoding with the given constant value.
    init(_ stroke: StrokeChannel, value constant: ColorGradientRadial, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.init(stroke, value: .init(.init(constant)), makeElements: makeElements)
    }

    /// Creates this encoding with the given constant color value.
    init(_ stroke: StrokeChannel, value constant: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.init(stroke, value: .init(constant), makeElements: makeElements)
    }

    /// Creates this encoding with the given constant color expression.
    init(_ stroke: StrokeChannel, expression: ExprRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.init(stroke, value: .init(expression), makeElements: makeElements)
    }

    private init(_ stroke: StrokeChannel, value constant: OneOf3<ColorGradient, String, ExprRef>, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }
}


// MARK: VizEncode: size

public extension VizEncode where Channel == EncodingChannelMap.SizeEncoding {



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
public extension VizEncode where Channel == EncodingChannelMap.SizeEncoding, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionMarkPropFieldDefNumber { def }

    /// Creates an empty instance of this encoding.
    init(_ size: SizeChannel, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ size: SizeChannel, field: FieldNameRepresentable, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ size: SizeChannel, repeat: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == EncodingChannelMap.SizeEncoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionDatumDefNumber { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ size: SizeChannel, datum: ExplicitNull, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ size: SizeChannel, datum: Double, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ size: SizeChannel, datum: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ size: SizeChannel, datum: Bool, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ size: SizeChannel, datum: DateTime, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ size: SizeChannel, expression: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ size: SizeChannel, datum: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == EncodingChannelMap.SizeEncoding, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefWithConditionMarkPropFieldOrDatumDefNumber { def }

    /// Creates this encoding with the given constant value.
    init(_ size: SizeChannel, value constant: Double, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with a dynamic expression.
    init(_ size: SizeChannel, expr expression: ExprRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }
}



// MARK: VizEncode: strokeWidth

public extension VizEncode where Channel == EncodingChannelMap.StrokeWidthEncoding {



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
public extension VizEncode where Channel == EncodingChannelMap.StrokeWidthEncoding, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionMarkPropFieldDefNumber { def }

    /// Creates an empty instance of this encoding.
    init(_ strokeWidth: StrokeWidthChannel, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ strokeWidth: StrokeWidthChannel, field: FieldNameRepresentable, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ strokeWidth: StrokeWidthChannel, repeat: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == EncodingChannelMap.StrokeWidthEncoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionDatumDefNumber { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeWidth: StrokeWidthChannel, datum: ExplicitNull, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeWidth: StrokeWidthChannel, datum: Double, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeWidth: StrokeWidthChannel, datum: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeWidth: StrokeWidthChannel, datum: Bool, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeWidth: StrokeWidthChannel, datum: DateTime, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeWidth: StrokeWidthChannel, expression: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ strokeWidth: StrokeWidthChannel, datum: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == EncodingChannelMap.StrokeWidthEncoding, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefWithConditionMarkPropFieldOrDatumDefNumber { def }

    /// Creates this encoding with the given constant value.
    init(_ strokeWidth: StrokeWidthChannel, value constant: Double, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with a dynamic expression.
    init(_ strokeWidth: StrokeWidthChannel, expr expression: ExprRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }
}



// MARK: VizEncode: strokeOpacity

public extension VizEncode where Channel == EncodingChannelMap.StrokeOpacityEncoding {



    enum StrokeOpacityChannel {
        /// Stroke opacity of the marks.
        case strokeOpacity
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Field Initializers
public extension VizEncode where Channel == EncodingChannelMap.StrokeOpacityEncoding, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionMarkPropFieldDefNumber { def }

    /// Creates an empty instance of this encoding.
    init(_ strokeOpacity: StrokeOpacityChannel, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ strokeOpacity: StrokeOpacityChannel, field: FieldNameRepresentable, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ strokeOpacity: StrokeOpacityChannel, repeat: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == EncodingChannelMap.StrokeOpacityEncoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionDatumDefNumber { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeOpacity: StrokeOpacityChannel, datum: ExplicitNull, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeOpacity: StrokeOpacityChannel, datum: Double, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeOpacity: StrokeOpacityChannel, datum: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeOpacity: StrokeOpacityChannel, datum: Bool, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeOpacity: StrokeOpacityChannel, datum: DateTime, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeOpacity: StrokeOpacityChannel, expression: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ strokeOpacity: StrokeOpacityChannel, datum: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == EncodingChannelMap.StrokeOpacityEncoding, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefWithConditionMarkPropFieldOrDatumDefNumber { def }

    /// Creates this encoding with the given constant value.
    init(_ strokeOpacity: StrokeOpacityChannel, value constant: Double, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with a dynamic expression.
    init(_ strokeOpacity: StrokeOpacityChannel, expr expression: ExprRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }
}



// MARK: VizEncode: fillOpacity

public extension VizEncode where Channel == EncodingChannelMap.FillOpacityEncoding {



    enum FillOpacityChannel {
        /// Fill opacity of the marks.
        case fillOpacity
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Field Initializers
public extension VizEncode where Channel == EncodingChannelMap.FillOpacityEncoding, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionMarkPropFieldDefNumber { def }

    /// Creates an empty instance of this encoding.
    init(_ fillOpacity: FillOpacityChannel, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ fillOpacity: FillOpacityChannel, field: FieldNameRepresentable, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ fillOpacity: FillOpacityChannel, repeat: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == EncodingChannelMap.FillOpacityEncoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionDatumDefNumber { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ fillOpacity: FillOpacityChannel, datum: ExplicitNull, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ fillOpacity: FillOpacityChannel, datum: Double, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ fillOpacity: FillOpacityChannel, datum: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ fillOpacity: FillOpacityChannel, datum: Bool, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ fillOpacity: FillOpacityChannel, datum: DateTime, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ fillOpacity: FillOpacityChannel, expression: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ fillOpacity: FillOpacityChannel, datum: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == EncodingChannelMap.FillOpacityEncoding, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefWithConditionMarkPropFieldOrDatumDefNumber { def }

    /// Creates this encoding with the given constant value.
    init(_ fillOpacity: FillOpacityChannel, value constant: Double, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with a dynamic expression.
    init(_ fillOpacity: FillOpacityChannel, expr expression: ExprRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }
}



// MARK: VizEncode: opacity

public extension VizEncode where Channel == EncodingChannelMap.OpacityEncoding {



    enum OpacityChannel {
        /// Opacity of the marks.
        case opacity
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Field Initializers
public extension VizEncode where Channel == EncodingChannelMap.OpacityEncoding, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionMarkPropFieldDefNumber { def }

    /// Creates an empty instance of this encoding.
    init(_ opacity: OpacityChannel, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ opacity: OpacityChannel, field: FieldNameRepresentable, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ opacity: OpacityChannel, repeat: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == EncodingChannelMap.OpacityEncoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionDatumDefNumber { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ opacity: OpacityChannel, datum: ExplicitNull, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ opacity: OpacityChannel, datum: Double, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ opacity: OpacityChannel, datum: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ opacity: OpacityChannel, datum: Bool, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ opacity: OpacityChannel, datum: DateTime, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ opacity: OpacityChannel, expression: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ opacity: OpacityChannel, datum: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == EncodingChannelMap.OpacityEncoding, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefWithConditionMarkPropFieldOrDatumDefNumber { def }

    /// Creates this encoding with the given constant value.
    init(_ opacity: OpacityChannel, value constant: Double, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with a dynamic expression.
    init(_ opacity: OpacityChannel, expr expression: ExprRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }
}



// MARK: VizEncode: angle

public extension VizEncode where Channel == EncodingChannelMap.AngleEncoding {



    enum AngleChannel {
        /// Rotation angle of point and text marks.
        case angle
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Field Initializers
public extension VizEncode where Channel == EncodingChannelMap.AngleEncoding, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionMarkPropFieldDefNumber { def }

    /// Creates an empty instance of this encoding.
    init(_ angle: AngleChannel, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ angle: AngleChannel, field: FieldNameRepresentable, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ angle: AngleChannel, repeat: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == EncodingChannelMap.AngleEncoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionDatumDefNumber { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ angle: AngleChannel, datum: ExplicitNull, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ angle: AngleChannel, datum: Double, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ angle: AngleChannel, datum: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ angle: AngleChannel, datum: Bool, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ angle: AngleChannel, datum: DateTime, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ angle: AngleChannel, expression: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ angle: AngleChannel, datum: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == EncodingChannelMap.AngleEncoding, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefWithConditionMarkPropFieldOrDatumDefNumber { def }

    /// Creates this encoding with the given constant value.
    init(_ angle: AngleChannel, value constant: Double, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with a dynamic expression.
    init(_ angle: AngleChannel, expr expression: ExprRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }
}



// MARK: VizEncode: theta


public extension VizEncode where Channel == EncodingChannelMap.ThetaEncoding {



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
public extension VizEncode where Channel == EncodingChannelMap.ThetaEncoding, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> PositionFieldDefBase { def }

    /// Creates an empty instance of this encoding.
    init(_ theta: ThetaChannel, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ theta: ThetaChannel, field: FieldNameRepresentable, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ theta: ThetaChannel, repeat: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == EncodingChannelMap.ThetaEncoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> PositionDatumDefBase { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ theta: ThetaChannel, datum: ExplicitNull, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ theta: ThetaChannel, datum: Double, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ theta: ThetaChannel, datum: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ theta: ThetaChannel, datum: Bool, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ theta: ThetaChannel, datum: DateTime, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ theta: ThetaChannel, expression: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ theta: ThetaChannel, datum: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == EncodingChannelMap.ThetaEncoding, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefNumberWidthHeightExprRef { def }

    /// Creates this encoding with the given constant value.
    init(_ theta: ThetaChannel, value constant: Double, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ theta: ThetaChannel, value constant: LiteralWidth, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }

    /// Creates this encoding with a dynamic expression.
    init(_ theta: ThetaChannel, expr expression: LiteralHeight, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T3 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }

    /// Creates this encoding with a dynamic expression.
    init(_ theta: ThetaChannel, expr expression: ExprRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T4 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }

}


// MARK: VizEncode: theta2

public extension VizEncode where Channel == EncodingChannelMap.Theta2Encoding {



    enum Theta2Channel {
        /// The end angle of arc marks in radians. A value of 0 indicates up or “north”, increasing values proceed clockwise.
        case theta2
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Field Initializers
public extension VizEncode where Channel == EncodingChannelMap.Theta2Encoding, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> SecondaryFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ theta2: Theta2Channel, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ theta2: Theta2Channel, field: FieldNameRepresentable, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ theta2: Theta2Channel, repeat: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == EncodingChannelMap.Theta2Encoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> DatumDef { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ theta2: Theta2Channel, datum: ExplicitNull, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ theta2: Theta2Channel, datum: Double, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ theta2: Theta2Channel, datum: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ theta2: Theta2Channel, datum: Bool, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ theta2: Theta2Channel, datum: DateTime, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ theta2: Theta2Channel, expression: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ theta2: Theta2Channel, datum: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == EncodingChannelMap.Theta2Encoding, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefNumberWidthHeightExprRef { def }

    /// Creates this encoding with the given constant value.
    init(_ theta2: Theta2Channel, value constant: Double, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ theta2: Theta2Channel, value constant: LiteralWidth, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }

    /// Creates this encoding with a dynamic expression.
    init(_ theta2: Theta2Channel, expr expression: LiteralHeight, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T3 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }

    /// Creates this encoding with a dynamic expression.
    init(_ theta2: Theta2Channel, expr expression: ExprRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T4 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }
}



// MARK: VizEncode: radius

public extension VizEncode where Channel == EncodingChannelMap.RadiusEncoding {



    enum RadiusChannel {
        /// The outer radius in pixels of arc marks.
        case radius
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Field Initializers
public extension VizEncode where Channel == EncodingChannelMap.RadiusEncoding, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> PositionFieldDefBase { def }

    /// Creates an empty instance of this encoding.
    init(_ radius: RadiusChannel, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ radius: RadiusChannel, field: FieldNameRepresentable, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ radius: RadiusChannel, repeat: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == EncodingChannelMap.RadiusEncoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> PositionDatumDefBase { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ radius: RadiusChannel, datum: ExplicitNull, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ radius: RadiusChannel, datum: Double, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ radius: RadiusChannel, datum: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ radius: RadiusChannel, datum: Bool, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ radius: RadiusChannel, datum: DateTime, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ radius: RadiusChannel, expression: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ radius: RadiusChannel, datum: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == EncodingChannelMap.RadiusEncoding, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefNumberWidthHeightExprRef { def }

    /// Creates this encoding with the given constant value.
    init(_ radius: RadiusChannel, value constant: Double, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }


    /// Creates this encoding with the given constant value.
    init(_ radius: RadiusChannel, value constant: LiteralWidth, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }

    /// Creates this encoding with a dynamic expression.
    init(_ radius: RadiusChannel, expr expression: LiteralHeight, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T3 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }

    /// Creates this encoding with a dynamic expression.
    init(_ radius: RadiusChannel, expr expression: ExprRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T4 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }
}



// MARK: VizEncode: radius2

public extension VizEncode where Channel == EncodingChannelMap.Radius2Encoding {



    enum Radius2Channel {
        /// The inner radius in pixels of arc marks.
        case radius2
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Field Initializers
public extension VizEncode where Channel == EncodingChannelMap.Radius2Encoding, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> SecondaryFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ radius2: Radius2Channel, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ radius2: Radius2Channel, field: FieldNameRepresentable, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ radius2: Radius2Channel, repeat: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == EncodingChannelMap.Radius2Encoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> DatumDef { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ radius2: Radius2Channel, datum: ExplicitNull, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ radius2: Radius2Channel, datum: Double, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ radius2: Radius2Channel, datum: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ radius2: Radius2Channel, datum: Bool, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ radius2: Radius2Channel, datum: DateTime, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ radius2: Radius2Channel, expression: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ radius2: Radius2Channel, datum: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == EncodingChannelMap.Radius2Encoding, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefNumberWidthHeightExprRef { def }

    /// Creates this encoding with the given constant value.
    init(_ radius2: Radius2Channel, value constant: Double, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }


    /// Creates this encoding with the given constant value.
    init(_ radius2: Radius2Channel, value constant: LiteralWidth, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }

    /// Creates this encoding with a dynamic expression.
    init(_ radius2: Radius2Channel, expr expression: LiteralHeight, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T3 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }

    /// Creates this encoding with a dynamic expression.
    init(_ radius2: Radius2Channel, expr expression: ExprRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T4 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }
}



// MARK: VizEncode: xError

public extension VizEncode where Channel == EncodingChannelMap.XErrorEncoding {



    enum XErrorChannel {
        case xError
    }

    typealias ChannelFieldType = Channel.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.T2
}

/// Empty Initializers
public extension VizEncode where Channel == EncodingChannelMap.XErrorEncoding, Def == SecondaryFieldDef {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> SecondaryFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ xError: XErrorChannel, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    init(_ xError: XErrorChannel, field: FieldNameRepresentable, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        /// Creates this encoding with the value mapped to the given field name in the data.
        self.deriveChannel = { .init($0) }
        self.def = .init(field: .init(field.fieldName))
    }
}

/// Field Initializers
public extension VizEncode where Channel == EncodingChannelMap.XErrorEncoding, Def == ValueDefNumber {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefNumber { def }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ xError: XErrorChannel, value constant: Double, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: constant)
    }
}





// MARK: VizEncode: xError2


public extension VizEncode where Channel == EncodingChannelMap.XError2Encoding {



    enum XError2Channel {
        case xError2
    }

    typealias ChannelFieldType = Channel.RawValue.T1
    typealias ChannelValueType = Channel.RawValue.T2
}

/// Empty Initializers
public extension VizEncode where Channel == EncodingChannelMap.XError2Encoding, Def == SecondaryFieldDef {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> SecondaryFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ xError2: XError2Channel, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    init(_ xError2: XError2Channel, field: FieldNameRepresentable, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        /// Creates this encoding with the value mapped to the given field name in the data.
        self.deriveChannel = { .init($0) }
        self.def = .init(field: .init(field.fieldName))
    }
}

/// Field Initializers
public extension VizEncode where Channel == EncodingChannelMap.XError2Encoding, Def == ValueDefNumber {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefNumber { def }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ xError2: XError2Channel, value constant: Double, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: constant)
    }
}




// MARK: VizEncode: yError


public extension VizEncode where Channel == EncodingChannelMap.YErrorEncoding {



    enum YErrorChannel {
        case yError
    }

    typealias ChannelFieldType = Channel.RawValue.T1
    typealias ChannelValueType = Channel.RawValue.T2
}

/// Empty Initializers
public extension VizEncode where Channel == EncodingChannelMap.YErrorEncoding, Def == SecondaryFieldDef {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> SecondaryFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ yError: YErrorChannel, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    init(_ yError: YErrorChannel, field: FieldNameRepresentable, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        /// Creates this encoding with the value mapped to the given field name in the data.
        self.deriveChannel = { .init($0) }
        self.def = .init(field: .init(field.fieldName))
    }
}

/// Field Initializers
public extension VizEncode where Channel == EncodingChannelMap.YErrorEncoding, Def == ValueDefNumber {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefNumber { def }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ yError: YErrorChannel, value constant: Double, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: constant)
    }
}



// MARK: VizEncode: yError2


public extension VizEncode where Channel == EncodingChannelMap.YError2Encoding {



    enum YError2Channel {
        case yError2
    }

    typealias ChannelFieldType = Channel.RawValue.T1
    typealias ChannelValueType = Channel.RawValue.T2
}

/// Empty Initializers
public extension VizEncode where Channel == EncodingChannelMap.YError2Encoding, Def == SecondaryFieldDef {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> SecondaryFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ yError2: YError2Channel, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    init(_ yError2: YError2Channel, field: FieldNameRepresentable, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        /// Creates this encoding with the value mapped to the given field name in the data.
        self.deriveChannel = { .init($0) }
        self.def = .init(field: .init(field.fieldName))
    }
}

/// Field Initializers
public extension VizEncode where Channel == EncodingChannelMap.YError2Encoding, Def == ValueDefNumber {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefNumber { def }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ yError2: YError2Channel, value constant: Double, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: constant)
    }
}



// MARK: VizEncode: column


public extension VizEncode where Channel == EncodingChannelMap.ColumnEncoding {



    enum ColumnChannel {
        /// Facet, row and column are special encoding channels that facets single plots into trellis plots (or small multiples).
        case column
    }

    typealias ChannelFieldType = Channel.RawValue
}

/// Empty Initializers
public extension VizEncode where Channel == EncodingChannelMap.ColumnEncoding, Def == RowColumnEncodingFieldDef {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> RowColumnEncodingFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ column: ColumnChannel, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init($0) }
        self.def = .init()
    }

    init(_ column: ColumnChannel, field: FieldNameRepresentable, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        /// Creates this encoding with the value mapped to the given field name in the data.
        self.deriveChannel = { .init($0) }
        self.def = .init(field: .init(field.fieldName))
    }
}

// MARK: VizEncode: row


public extension VizEncode where Channel == EncodingChannelMap.RowEncoding {



    enum RowChannel {
        /// Facet, row and column are special encoding channels that facets single plots into trellis plots (or small multiples).
        case row
    }

    typealias ChannelFieldType = Channel.RawValue
}

/// Empty Initializers
public extension VizEncode where Channel == EncodingChannelMap.RowEncoding, Def == RowColumnEncodingFieldDef {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> RowColumnEncodingFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ row: RowChannel, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init($0) }
        self.def = .init()
    }

    init(_ row: RowChannel, field: FieldNameRepresentable, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        /// Creates this encoding with the value mapped to the given field name in the data.
        self.deriveChannel = { .init($0) }
        self.def = .init(field: .init(field.fieldName))
    }
}




// MARK: VizEncode: facet


public extension VizEncode where Channel == EncodingChannelMap.FacetEncoding {



    enum FacetChannel {
        /// Facet, row and column are special encoding channels that facets single plots into trellis plots (or small multiples).
        case facet
    }

    typealias ChannelFieldType = Channel.RawValue
}

/// Empty Initializers
public extension VizEncode where Channel == EncodingChannelMap.FacetEncoding, Def == FacetEncodingFieldDef {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FacetEncodingFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ facet: FacetChannel, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init($0) }
        self.def = .init()
    }

    init(_ facet: FacetChannel, field: FieldNameRepresentable, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        /// Creates this encoding with the value mapped to the given field name in the data.
        self.deriveChannel = { .init($0) }
        self.def = .init(field: .init(field.fieldName))
    }
}


// MARK: VizEncode: latitude

public extension VizEncode where Channel == EncodingChannelMap.LatitudeEncoding {



    enum LatitudeChannel {
        /// Longitude and latitude channels can be used to encode geographic coordinate data via a projection. In addition, longitude2 and latitude2 can specify the span of geographically projected ranged area, bar, rect, and rule.
        case latitude
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelValueType = Channel.RawValue.RawValue.T2

//    func fieldType(for field: Self.ChannelFieldType) -> Self.ChannelFieldType { field }
}

/// Empty Initializers
public extension VizEncode where Channel == EncodingChannelMap.LatitudeEncoding, Def == LatLongFieldDef {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> LatLongFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ latitude: LatitudeChannel, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ latitude: LatitudeChannel, field: FieldNameRepresentable, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ latitude: LatitudeChannel, repeat: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == EncodingChannelMap.LatitudeEncoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> DatumDef { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ latitude: LatitudeChannel, datum: ExplicitNull, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ latitude: LatitudeChannel, datum: Double, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ latitude: LatitudeChannel, datum: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ latitude: LatitudeChannel, datum: Bool, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ latitude: LatitudeChannel, datum: DateTime, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ latitude: LatitudeChannel, expression: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ latitude: LatitudeChannel, datum: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}


// MARK: VizEncode: longitude


public extension VizEncode where Channel == EncodingChannelMap.LongitudeEncoding {



    enum LongitudeChannel {
        /// Longitude and latitude channels can be used to encode geographic coordinate data via a projection. In addition, longitude2 and latitude2 can specify the span of geographically projected ranged area, bar, rect, and rule.
        case longitude
    }
    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelValueType = Channel.RawValue.RawValue.T2
}

/// Empty Initializers
public extension VizEncode where Channel == EncodingChannelMap.LongitudeEncoding, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> LatLongFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ longitude: LongitudeChannel, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ longitude: LongitudeChannel, field: FieldNameRepresentable, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ longitude: LongitudeChannel, repeat: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == EncodingChannelMap.LongitudeEncoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> DatumDef { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ longitude: LongitudeChannel, datum: ExplicitNull, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ longitude: LongitudeChannel, datum: Double, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ longitude: LongitudeChannel, datum: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ longitude: LongitudeChannel, datum: Bool, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ longitude: LongitudeChannel, datum: DateTime, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ longitude: LongitudeChannel, expression: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ longitude: LongitudeChannel, datum: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}



// MARK: VizEncode: latitude2


public extension VizEncode where Channel == EncodingChannelMap.Latitude2Encoding {



    enum Latitude2Channel {
        /// Longitude and latitude channels can be used to encode geographic coordinate data via a projection. In addition, longitude2 and latitude2 can specify the span of geographically projected ranged area, bar, rect, and rule.
        case latitude2
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Empty Initializers
public extension VizEncode where Channel == EncodingChannelMap.Latitude2Encoding, Def == SecondaryFieldDef {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> SecondaryFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ latitude2: Latitude2Channel, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ latitude2: Latitude2Channel, field: FieldNameRepresentable, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ latitude2: Latitude2Channel, repeat: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == EncodingChannelMap.Latitude2Encoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> DatumDef { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ latitude2: Latitude2Channel, datum: ExplicitNull, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ latitude2: Latitude2Channel, datum: Double, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ latitude2: Latitude2Channel, datum: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ latitude2: Latitude2Channel, datum: Bool, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ latitude2: Latitude2Channel, datum: DateTime, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ latitude2: Latitude2Channel, expression: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ latitude2: Latitude2Channel, datum: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}


// MARK: VizEncode: longitude2


public extension VizEncode where Channel == EncodingChannelMap.Longitude2Encoding {



    enum Longitude2Channel {
        /// Longitude and latitude channels can be used to encode geographic coordinate data via a projection. In addition, longitude2 and latitude2 can specify the span of geographically projected ranged area, bar, rect, and rule.
        case longitude2
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Empty Initializers
public extension VizEncode where Channel == EncodingChannelMap.Longitude2Encoding, Def == SecondaryFieldDef {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> SecondaryFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ longitude2: Longitude2Channel, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ longitude2: Longitude2Channel, field: FieldNameRepresentable, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ longitude2: Longitude2Channel, repeat: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == EncodingChannelMap.Longitude2Encoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> DatumDef { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ longitude2: Longitude2Channel, datum: ExplicitNull, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ longitude2: Longitude2Channel, datum: Double, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ longitude2: Longitude2Channel, datum: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ longitude2: Longitude2Channel, datum: Bool, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ longitude2: Longitude2Channel, datum: DateTime, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ longitude2: Longitude2Channel, expression: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ longitude2: Longitude2Channel, datum: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}



// MARK: VizEncode: href

public extension VizEncode where Channel == EncodingChannelMap.HrefEncoding {



    enum HrefChannel {
        /// A URL to load upon mouse click.
        case href
    }

    typealias ChannelFieldType = Channel.RawValue.T1
    typealias ChannelValueType = Channel.RawValue.T2
}

/// Field Initializers
public extension VizEncode where Channel == EncodingChannelMap.HrefEncoding, Def == Channel.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionStringFieldDefString { def }

    /// Creates an empty instance of this encoding.
    init(_ href: HrefChannel, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ href: HrefChannel, field: FieldNameRepresentable, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ href: HrefChannel, repeat: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }
}

/// Value Initializers
public extension VizEncode where Channel == EncodingChannelMap.HrefEncoding, Def == StringValueDefWithCondition {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefWithConditionMarkPropFieldOrDatumDefStringNull { def }

    /// Creates this encoding with the given constant value.
    init(_ href: HrefChannel, value constant: ExplicitNull, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ href: HrefChannel, value constant: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(.init(value)))
    }

    /// Creates this encoding with a dynamic expression.
    init(_ href: HrefChannel, expr expression: ExprRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2.T2 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(.init(value))) // ambiguous with the other expr init?
    }
}


// MARK: VizEncode: description

public extension VizEncode where Channel == EncodingChannelMap.DescriptionEncoding {



    enum DescriptionChannel {
        /// A text description of this mark for ARIA accessibility. For SVG output the "aria-label" attribute will be set to this description.
        case description
    }

    typealias ChannelFieldType = Channel.RawValue.T1
    typealias ChannelValueType = Channel.RawValue.T2
}

/// Field Initializers
public extension VizEncode where Channel == EncodingChannelMap.DescriptionEncoding, Def == Channel.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionStringFieldDefString { def }

    /// Creates an empty instance of this encoding.
    init(_ description: DescriptionChannel, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ description: DescriptionChannel, field: FieldNameRepresentable, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ description: DescriptionChannel, repeat: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }
}

/// Value Initializers
public extension VizEncode where Channel == EncodingChannelMap.DescriptionEncoding, Def == StringValueDefWithCondition {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefWithConditionMarkPropFieldOrDatumDefStringNull { def }

    /// Creates this encoding with the given constant value.
    init(_ description: DescriptionChannel, value constant: ExplicitNull, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ description: DescriptionChannel, value constant: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(.init(value)))
    }

    /// Creates this encoding with a dynamic expression.
    init(_ description: DescriptionChannel, expr expression: ExprRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2.T2 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(.init(value))) // ambiguous with the other expr init?
    }
}

// MARK: VizEncode: url

public extension VizEncode where Channel == EncodingChannelMap.UrlEncoding {



    enum UrlChannel {
        case url
    }

    typealias ChannelFieldType = Channel.RawValue.T1
    typealias ChannelValueType = Channel.RawValue.T2
}

/// Field Initializers
public extension VizEncode where Channel == EncodingChannelMap.UrlEncoding, Def == Channel.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionStringFieldDefString { def }

    /// Creates an empty instance of this encoding.
    init(_ url: UrlChannel, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ url: UrlChannel, field: FieldNameRepresentable, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ url: UrlChannel, repeat: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }
}

/// Value Initializers
public extension VizEncode where Channel == EncodingChannelMap.UrlEncoding, Def == Channel.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> StringValueDefWithCondition { def }

    /// Creates this encoding with the given constant value.
    init(_ url: UrlChannel, value constant: ExplicitNull, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ url: UrlChannel, value constant: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(.init(value)))
    }

    /// Creates this encoding with a dynamic expression.
    init(_ url: UrlChannel, expr expression: ExprRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2.T2 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(.init(value))) // ambiguous with the other expr init?
    }
}


// MARK: VizEncode: strokeDash

public extension VizEncode where Channel == EncodingChannelMap.StrokeDashEncoding {



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
public extension VizEncode where Channel == EncodingChannelMap.StrokeDashEncoding, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionMarkPropFieldDefNumberArray { def }

    /// Creates an empty instance of this encoding.
    init(_ strokeDash: StrokeDashChannel, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ strokeDash: StrokeDashChannel, field: FieldNameRepresentable, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ strokeDash: StrokeDashChannel, repeat: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }
}

public extension VizEncode where Channel == EncodingChannelMap.StrokeDashEncoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionDatumDefNumberArray { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeDash: StrokeDashChannel, datum: ExplicitNull, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeDash: StrokeDashChannel, datum: Double, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeDash: StrokeDashChannel, datum: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeDash: StrokeDashChannel, datum: Bool, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeDash: StrokeDashChannel, datum: DateTime, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ strokeDash: StrokeDashChannel, expression: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ strokeDash: StrokeDashChannel, datum: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

public extension VizEncode where Channel == EncodingChannelMap.StrokeDashEncoding, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefWithConditionMarkPropFieldOrDatumDefNumberArray { def }

    /// Creates this encoding with the given constant value.
    init(_ strokeDash: StrokeDashChannel, value constant: [Double], @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with a dynamic expression.
    init(_ strokeDash: StrokeDashChannel, expr expression: ExprRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }
}


// MARK: VizEncode: key

public extension VizEncode where Channel == EncodingChannelMap.KeyEncoding {
    enum KeyChannel {
        case key
    }

    typealias ChannelFieldType = Channel.RawValue
}

/// Field Initializers
public extension VizEncode where Channel == EncodingChannelMap.KeyEncoding, Def == Channel.RawValue {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> TypedFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ key: KeyChannel, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init($0) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ key: KeyChannel, field: FieldNameRepresentable, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init($0) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ key: KeyChannel, repeat: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init($0) }
        self.def = .init(field: .init(`repeat`))
    }
}


// MARK: VizEncode: shape

public extension VizEncode where Channel == EncodingChannelMap.ShapeEncoding {
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
public extension VizEncode where Channel == EncodingChannelMap.ShapeEncoding, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionMarkPropFieldDefTypeForShapeStringNull { def }

    /// Creates an empty instance of this encoding.
    init(_ shape: ShapeChannel, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ shape: ShapeChannel, field: FieldNameRepresentable, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ shape: ShapeChannel, repeat: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == EncodingChannelMap.ShapeEncoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionDatumDefStringNull { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ shape: ShapeChannel, datum: ExplicitNull, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ shape: ShapeChannel, datum: Double, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ shape: ShapeChannel, datum: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ shape: ShapeChannel, datum: Bool, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ shape: ShapeChannel, datum: DateTime, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ shape: ShapeChannel, expression: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ shape: ShapeChannel, datum: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == EncodingChannelMap.ShapeEncoding, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefWithConditionMarkPropFieldOrDatumDefTypeForShapeStringNull { def }

    /// Creates this encoding with the given constant value.
    init(_ shape: ShapeChannel, value constant: SymbolShape?, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Nullable<SymbolShape> = constant.map({ Nullable($0) }) ?? .v1(ExplicitNull())
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: value)
    }
}



// MARK: VizEncode: detail

public extension VizEncode where Channel == EncodingChannelMap.DetailEncoding {
    enum DetailChannel {
        case detail
    }

    typealias ChannelFieldType = Channel.RawValue.T1 // TypedFieldDef
    typealias ChannelMultiFieldType = Channel.RawValue.T2 // [TypedFieldDef]
}

public extension VizEncode where Channel == EncodingChannelMap.DetailEncoding, Def == Channel.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> TypedFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ detail: DetailChannel, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ detail: DetailChannel, field: FieldNameRepresentable, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ detail: DetailChannel, repeat: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }
}


// MARK: VizEncode: order

public extension VizEncode where Channel == EncodingChannelMap.OrderEncoding {
    enum OrderChannel {
        case order
    }

    typealias ChannelFieldType = Channel.RawValue.T1.T1 // OrderFieldDef
    typealias ChannelMultiFieldType = Channel.RawValue.T1.T2 // [OrderFieldDef]
    typealias ChannelValueType = Channel.RawValue.T2 // OrderValueDef

}

public extension VizEncode where Channel == EncodingChannelMap.OrderEncoding, Def == Channel.RawValue.T1.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> OrderFieldDef { def }

    /// Creates an empty instance of this encoding.
    init(_ order: OrderChannel, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ order: OrderChannel, field: FieldNameRepresentable, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ order: OrderChannel, repeat: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }
}

public extension VizEncode where Channel == EncodingChannelMap.OrderEncoding, Def == Channel.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> OrderValueDef { def }

    /// Creates this encoding with the given constant value.
    init(_ order: OrderChannel, value constant: Double, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with a dynamic expression.
    init(_ order: OrderChannel, expr expression: ExprRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }
}

// MARK: VizEncode: text

public extension VizEncode where Channel == EncodingChannelMap.TextEncoding {
    enum TextChannel {
        case text
    }

    typealias ChannelFieldType = Channel.RawValue.RawValue.T1
    typealias ChannelDatumType = Channel.RawValue.RawValue.T2
    typealias ChannelValueType = Channel.RawValue.RawValue.T3
}

/// Field Initializers
public extension VizEncode where Channel == EncodingChannelMap.TextEncoding, Def == Channel.RawValue.RawValue.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionStringFieldDefText { def }

    /// Creates an empty instance of this encoding.
    init(_ text: TextChannel, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ text: TextChannel, field: FieldNameRepresentable, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ text: TextChannel, repeat: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == EncodingChannelMap.TextEncoding, Def == Channel.RawValue.RawValue.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> FieldOrDatumDefWithConditionStringDatumDefText { def }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ text: TextChannel, datum: ExplicitNull, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ text: TextChannel, datum: Double, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ text: TextChannel, datum: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ text: TextChannel, datum: Bool, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ text: TextChannel, datum: DateTime, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let datetime: Def.DatumChoice.T2 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ text: TextChannel, expression: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    @available(*, unavailable, message: "use repeat field initializer")
    init(_ text: TextChannel, datum: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let ref: Def.DatumChoice.T4 = datum
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == EncodingChannelMap.TextEncoding, Def == Channel.RawValue.RawValue.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> ValueDefWithConditionStringFieldDefText { def }

    /// Creates this encoding with the given constant value.
    init(_ text: TextChannel, value string: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(.init(string)))
    }

    /// Creates this encoding with the given constant value.
    init(_ text: TextChannel, values stringArray: [String], @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(.init(stringArray)))
    }

    /// Creates this encoding with a dynamic expression.
    init(_ text: TextChannel, expression: ExprRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(expression))
    }

}



// MARK: VizEncode: tooltip

public extension VizEncode where Channel == EncodingChannelMap.TooltipEncoding {
    enum TooltipChannel {
        case tooltip
    }

    typealias ChannelNullType = Channel.RawValue.T1
    typealias ChannelFieldType = Channel.RawValue.T2.T1
    typealias ChannelValueType = Channel.RawValue.T2.T2
    typealias ChannelMultiFieldType = Channel.RawValue.T2.T3
}

public extension VizEncode where Channel == EncodingChannelMap.TooltipEncoding, Def == Channel.RawValue.T2.T1 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> StringFieldDefWithCondition { def }

    /// Creates an empty instance of this encoding.
    init(_ tooltip: TooltipChannel, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ tooltip: TooltipChannel, field: FieldNameRepresentable, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(field.fieldName))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ tooltip: TooltipChannel, repeat: RepeatRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }
}

public extension VizEncode where Channel == EncodingChannelMap.TooltipEncoding, Def == Channel.RawValue.T2.T2 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> StringValueDefWithCondition { def }

    /// Creates this encoding with the given constant value.
    init(_ tooltip: TooltipChannel, value null: ExplicitNull, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T1 = null
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(.init(value)))
    }

    /// Creates this encoding with the given constant value.
    init(_ tooltip: TooltipChannel, value constant: String, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2.T1 = constant
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(.init(value)))
    }

    /// Creates this encoding with a dynamic expression.
    init(_ tooltip: TooltipChannel, expr expression: ExprRef, @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        let value: Def.ValueChoice.T2.T2 = expression
        self.deriveChannel = { .init(.init($0)) }
        self.def = .init(value: .init(.init(value)))
    }
}

public extension VizEncode where Channel == EncodingChannelMap.TooltipEncoding, Def == Channel.RawValue.T2.T3 {
    /// Validate the type name to guard against future re-aliasing
    private func toDef(_ def: Def) -> [StringFieldDef] { def }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ tooltip: TooltipChannel, fields: [FieldNameRepresentable], @VizArrayBuilder<Channel.ChildElement> makeElements: @escaping () -> [Channel.ChildElement] = {[]}) {
        self.makeElements = makeElements
        self.deriveChannel = { .init(.init($0)) }
        self.def = fields.map {
            StringFieldDef(field: .init($0.fieldName))
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


extension EncodingChannelMap.DetailEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .detail
    public typealias ChildElement = VizUnguidedEncodeElementType

    public func addChannel(to encodings: inout EncodingChannelMap, elements: [VizEncodeElementType]) {
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

extension EncodingChannelMap.OrderEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .order
    public typealias ChildElement = VizUnguidedEncodeElementType

    public func addChannel(to encodings: inout EncodingChannelMap, elements: [VizEncodeElementType]) {
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


extension EncodingChannelMap.TooltipEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .tooltip
    public typealias ChildElement = VizUnguidedEncodeElementType

    public func addChannel(to encodings: inout EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.tooltip != nil {
            // TODO: in theory, we could handle the special case of one tooltip with an array of fields being added to another tooltip with an array of fields…
            warnReplaceEncoding(self)
        }
        encodings.tooltip = assignElementItems(elements)
    }
}



// MARK: VizEncodingChannelType Single-Field

extension EncodingChannelMap.TextEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .text
    public typealias ChildElement = VizUnguidedEncodeElementType

    public func addChannel(to encodings: inout EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.text != nil {
            warnReplaceEncoding(self)
        }
        encodings.text = assignElementItems(elements)
    }
}

extension EncodingChannelMap.AngleEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .angle
    public typealias ChildElement = VizUnguidedEncodeElementType

    public func addChannel(to encodings: inout EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.angle != nil {
            warnReplaceEncoding(self)
        }
        encodings.angle = assignElementItems(elements, legendKey: \.rawValue.rawValue[routing: \.legend, \.[noop: false], \.[noop: false]])
    }
}

extension EncodingChannelMap.ColorEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .color
    public typealias ChildElement = VizLegendEncodeElementType

    public func addChannel(to encodings: inout EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.color != nil {
            warnReplaceEncoding(self)
        }
        encodings.color = assignElementItems(elements, scaleKey: \.rawValue.rawValue[routing: \.scale, \.[noop: false], \.[noop: false]], legendKey: \.rawValue.rawValue[routing: \.legend, \.[noop: false], \.[noop: false]])
    }
}

extension EncodingChannelMap.DescriptionEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .description
    public typealias ChildElement = VizUnguidedEncodeElementType

    public func addChannel(to encodings: inout EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.description != nil {
            warnReplaceEncoding(self)
        }
        encodings.description = assignElementItems(elements)
    }
}

extension EncodingChannelMap.FillEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .fill
    public typealias ChildElement = VizLegendEncodeElementType

    public func addChannel(to encodings: inout EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.fill != nil {
            warnReplaceEncoding(self)
        }
        encodings.fill = assignElementItems(elements, scaleKey: \.rawValue.rawValue[routing: \.scale, \.[noop: false], \.[noop: false]], legendKey: \.rawValue.rawValue[routing: \.legend, \.[noop: false], \.[noop: false]])
    }
}

extension EncodingChannelMap.FillOpacityEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .fillOpacity
    public typealias ChildElement = VizLegendEncodeElementType

    public func addChannel(to encodings: inout EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.fillOpacity != nil {
            warnReplaceEncoding(self)
        }
        encodings.fillOpacity = assignElementItems(elements, scaleKey: \.rawValue.rawValue[routing: \.scale, \.[noop: false], \.[noop: false]], legendKey: \.rawValue.rawValue[routing: \.legend, \.[noop: false], \.[noop: false]])
    }
}

extension EncodingChannelMap.HrefEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .href
    public typealias ChildElement = VizUnguidedEncodeElementType

    public func addChannel(to encodings: inout EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.href != nil {
            warnReplaceEncoding(self)
        }
        encodings.href = assignElementItems(elements)
    }
}

extension EncodingChannelMap.LatitudeEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .latitude
    public typealias ChildElement = VizUnguidedEncodeElementType

    public func addChannel(to encodings: inout EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.latitude != nil {
            warnReplaceEncoding(self)
        }
        encodings.latitude = assignElementItems(elements)
    }
}

extension EncodingChannelMap.Latitude2Encoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .latitude2
    public typealias ChildElement = VizUnguidedEncodeElementType

    public func addChannel(to encodings: inout EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.latitude2 != nil {
            warnReplaceEncoding(self)
        }
        encodings.latitude2 = assignElementItems(elements)
    }
}

extension EncodingChannelMap.LongitudeEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .longitude
    public typealias ChildElement = VizUnguidedEncodeElementType

    public func addChannel(to encodings: inout EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.longitude != nil {
            warnReplaceEncoding(self)
        }
        encodings.longitude = assignElementItems(elements)
    }
}

extension EncodingChannelMap.Longitude2Encoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .longitude2
    public typealias ChildElement = VizUnguidedEncodeElementType

    public func addChannel(to encodings: inout EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.longitude2 != nil {
            warnReplaceEncoding(self)
        }
        encodings.longitude2 = assignElementItems(elements)
    }
}

extension EncodingChannelMap.OpacityEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .opacity
    public typealias ChildElement = VizLegendEncodeElementType

    public func addChannel(to encodings: inout EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.opacity != nil {
            warnReplaceEncoding(self)
        }
        encodings.opacity = assignElementItems(elements, scaleKey: \.rawValue.rawValue[routing: \.scale, \.[noop: false], \.[noop: false]], legendKey: \.rawValue.rawValue[routing: \.legend, \.[noop: false], \.[noop: false]])
    }
}


extension EncodingChannelMap.RadiusEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .radius
    public typealias ChildElement = VizUnguidedEncodeElementType

    public func addChannel(to encodings: inout EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.radius != nil {
            warnReplaceEncoding(self)
        }
        encodings.radius = assignElementItems(elements, scaleKey: \.rawValue.rawValue[routing: \.scale, \.scale, \.[noop: false]])
    }
}

extension EncodingChannelMap.Radius2Encoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .radius2
    public typealias ChildElement = VizUnguidedEncodeElementType

    public func addChannel(to encodings: inout EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.radius2 != nil {
            warnReplaceEncoding(self)
        }
        encodings.radius2 = assignElementItems(elements)
    }
}

extension EncodingChannelMap.ShapeEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .shape
    public typealias ChildElement = VizLegendEncodeElementType

    public func addChannel(to encodings: inout EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.shape != nil {
            warnReplaceEncoding(self)
        }
        encodings.shape = assignElementItems(elements, scaleKey: \.rawValue.rawValue[routing: \.scale, \.[noop: false], \.[noop: false]], legendKey: \.rawValue.rawValue[routing: \.legend, \.[noop: false], \.[noop: false]])
    }
}

extension EncodingChannelMap.SizeEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .size
    public typealias ChildElement = VizLegendEncodeElementType

    public func addChannel(to encodings: inout EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.size != nil {
            warnReplaceEncoding(self)
        }
        encodings.size = assignElementItems(elements, scaleKey: \.rawValue.rawValue[routing: \.scale, \.[noop: false], \.[noop: false]], legendKey: \.rawValue.rawValue[routing: \.legend, \.[noop: false], \.[noop: false]])
    }
}

extension EncodingChannelMap.StrokeEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .stroke
    public typealias ChildElement = VizLegendEncodeElementType

    public func addChannel(to encodings: inout EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.stroke != nil {
            warnReplaceEncoding(self)
        }
        encodings.stroke = assignElementItems(elements, scaleKey: \.rawValue.rawValue[routing: \.scale, \.[noop: false], \.[noop: false]], legendKey: \.rawValue.rawValue[routing: \.legend, \.[noop: false], \.[noop: false]])
    }
}

extension EncodingChannelMap.StrokeDashEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .strokeDash
    public typealias ChildElement = VizLegendEncodeElementType

    public func addChannel(to encodings: inout EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.strokeDash != nil {
            warnReplaceEncoding(self)
        }
        encodings.strokeDash = assignElementItems(elements, scaleKey: \.rawValue.rawValue[routing: \.scale, \.[noop: false], \.[noop: false]], legendKey: \.rawValue.rawValue[routing: \.legend, \.[noop: false], \.[noop: false]])
    }
}

extension EncodingChannelMap.StrokeOpacityEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .strokeOpacity
    public typealias ChildElement = VizLegendEncodeElementType

    public func addChannel(to encodings: inout EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.strokeOpacity != nil {
            warnReplaceEncoding(self)
        }
        encodings.strokeOpacity = assignElementItems(elements, scaleKey: \.rawValue.rawValue[routing: \.scale, \.[noop: false], \.[noop: false]], legendKey: \.rawValue.rawValue[routing: \.legend, \.[noop: false], \.[noop: false]])
    }
}

extension EncodingChannelMap.StrokeWidthEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .strokeWidth
    public typealias ChildElement = VizLegendEncodeElementType

    public func addChannel(to encodings: inout EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.strokeWidth != nil {
            warnReplaceEncoding(self)
        }
        encodings.strokeWidth = assignElementItems(elements, scaleKey: \.rawValue.rawValue[routing: \.scale, \.[noop: false], \.[noop: false]], legendKey: \.rawValue.rawValue[routing: \.legend, \.[noop: false], \.[noop: false]])
    }
}

extension EncodingChannelMap.ThetaEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .theta
    public typealias ChildElement = VizUnguidedEncodeElementType

    public func addChannel(to encodings: inout EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.theta != nil {
            warnReplaceEncoding(self)
        }
        encodings.theta = assignElementItems(elements, scaleKey: \.rawValue.rawValue[routing: \.scale, \.scale, \.[noop: false]])
    }
}

extension EncodingChannelMap.Theta2Encoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .theta2
    public typealias ChildElement = VizUnguidedEncodeElementType

    public func addChannel(to encodings: inout EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.theta2 != nil {
            warnReplaceEncoding(self)
        }
        encodings.theta2 = assignElementItems(elements)
    }
}


extension EncodingChannelMap.UrlEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .url
    public typealias ChildElement = VizUnguidedEncodeElementType

    public func addChannel(to encodings: inout EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.url != nil {
            warnReplaceEncoding(self)
        }
        encodings.url = assignElementItems(elements)
    }
}


extension VizEncodingChannelType {
    fileprivate func assignElementItems(_ elements: [VizEncodeElementType], scaleKey: WritableKeyPath<Self, Nullable<ScaleDef>?>? = nil, axisKey: WritableKeyPath<Self, Nullable<AxisDef>?>? = nil, legendKey: WritableKeyPath<Self, Nullable<LegendDef>?>? = nil, headerKey: WritableKeyPath<Self, Nullable<HeaderDef>?>? = nil) -> Self {
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

extension EncodingChannelMap.XEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .x
    public typealias ChildElement = VizAxisEncodeElementType

    public func addChannel(to encodings: inout EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.x != nil {
            warnReplaceEncoding(self)
        }

        encodings.x = assignElementItems(elements, scaleKey: \.rawValue.rawValue[routing: \.scale, \.scale, \.[noop: false]], axisKey: \.rawValue.rawValue[routing: \.axis, \.axis, \.[noop: false]])
    }
}

extension EncodingChannelMap.X2Encoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .x2
    public typealias ChildElement = VizUnguidedEncodeElementType

    public func addChannel(to encodings: inout EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.x2 != nil {
            warnReplaceEncoding(self)
        }
        encodings.x2 = assignElementItems(elements)
    }
}

extension EncodingChannelMap.XErrorEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .xError
    public typealias ChildElement = VizUnguidedEncodeElementType

    public func addChannel(to encodings: inout EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.xError != nil {
            warnReplaceEncoding(self)
        }
        encodings.xError = assignElementItems(elements)
    }
}

extension EncodingChannelMap.XError2Encoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .xError2
    public typealias ChildElement = VizUnguidedEncodeElementType

    public func addChannel(to encodings: inout EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.xError2 != nil {
            warnReplaceEncoding(self)
        }
        encodings.xError2 = assignElementItems(elements)
    }
}

extension EncodingChannelMap.YEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .y
    public typealias ChildElement = VizAxisEncodeElementType

    public func addChannel(to encodings: inout EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.y != nil {
            warnReplaceEncoding(self)
        }
        encodings.y = assignElementItems(elements, scaleKey: \.rawValue.rawValue[routing: \.scale, \.scale, \.[noop: false]], axisKey: \.rawValue.rawValue[routing: \.axis, \.axis, \.[noop: false]])

    }
}

extension EncodingChannelMap.Y2Encoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .y2
    public typealias ChildElement = VizUnguidedEncodeElementType

    public func addChannel(to encodings: inout EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.y2 != nil {
            warnReplaceEncoding(self)
        }
        encodings.y2 = assignElementItems(elements)
    }
}

extension EncodingChannelMap.YErrorEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .yError
    public typealias ChildElement = VizUnguidedEncodeElementType

    public func addChannel(to encodings: inout EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.yError != nil {
            warnReplaceEncoding(self)
        }
        encodings.yError = assignElementItems(elements)
    }
}

extension EncodingChannelMap.YError2Encoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .yError2
    public typealias ChildElement = VizUnguidedEncodeElementType

    public func addChannel(to encodings: inout EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.yError2 != nil {
            warnReplaceEncoding(self)
        }
        encodings.yError2 = assignElementItems(elements)
    }
}

extension EncodingChannelMap.RowEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .row
    public typealias ChildElement = VizHeaderEncodeElementType

    public func addChannel(to encodings: inout EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.row != nil {
            warnReplaceEncoding(self)
        }
        encodings.row = assignElementItems(elements, headerKey: \.rawValue.header)
    }
}

extension EncodingChannelMap.ColumnEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .column
    public typealias ChildElement = VizHeaderEncodeElementType

    public func addChannel(to encodings: inout EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.column != nil {
            warnReplaceEncoding(self)
        }
        encodings.column = assignElementItems(elements, headerKey: \.rawValue.header)
    }
}

extension EncodingChannelMap.FacetEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .facet
    public typealias ChildElement = VizHeaderEncodeElementType

    public func addChannel(to encodings: inout EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.facet != nil {
            warnReplaceEncoding(self)
        }
        encodings.facet = assignElementItems(elements, headerKey: \.rawValue.header)
    }
}

extension EncodingChannelMap.KeyEncoding : VizEncodingChannelType {
    public static let encodingChannel: EncodingChannel = .key
    public typealias ChildElement = VizUnguidedEncodeElementType

    public func addChannel(to encodings: inout EncodingChannelMap, elements: [VizEncodeElementType]) {
        if encodings.key != nil {
            warnReplaceEncoding(self)
        }
        encodings.key = assignElementItems(elements)
    }
}


/// Issues a warning to the console that the existing encoding is being replaced
func warnReplaceEncoding<C: VizEncodingChannelType>(_ instance: C) {
    print("warnReplaceEncoding: encoding for \(C.encodingChannel.rawValue) overrides existing definition")
}


/// Work-in-progress, simply to highlight a line with a deprecation warning
@available(*, deprecated, message: "work-in-progress")
fileprivate func wip<T>(_ value: T) -> T { value }

/// Work-in-progress death, simply to highlight a line with a deprecation warning
@available(*, deprecated, message: "work-in-progress")
fileprivate func hole<T>(_ params: Any...) -> T { fatalError(wip("derp")) }
