

public protocol VizDSLType {
}


public protocol FacetOrient {
}

public struct VFacetOrient : FacetOrient { }
public struct HFacetOrient : FacetOrient { }
public struct ZFacetOrient : FacetOrient { }
public struct RFacetOrient : FacetOrient { }

public struct FacetLayer<Field, O: FacetOrient> {
    public init(fields: [Field]) {
    }
}

public extension FacetLayer where Field == Never {
    init() {
    }
}

public typealias VFacet<Field> = FacetLayer<Field, VFacetOrient>
public typealias HFacet<Field> = FacetLayer<Field, HFacetOrient>
public typealias ZFacet<Field> = FacetLayer<Field, ZFacetOrient>
public typealias RFacet<Field> = FacetLayer<Field, RFacetOrient>


public protocol VizSpecElementType {
    func add<M: Pure>(to spec: inout VizSpec<M>)
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


@dynamicMemberLookup
public struct VizTheme : VizSpecElementType, VizDSLType {
    var config: GGSpec.Config

    public init(config: GGSpec.Config = GGSpec.Config()) {
        self.config = config
    }
    
    public func add<M>(to spec: inout VizSpec<M>) where M : Pure {
        spec.config = config
    }
}

public extension VizTheme {
    /// Creates a setter function for the given dynamic keypath, allowing a fluent API for all the properties
    subscript<U>(dynamicMember keyPath: WritableKeyPath<GGSpec.Config, U>) -> (U) -> (Self) {
        setting(path: (\Self.config).appending(path: keyPath))
    }
}

@dynamicMemberLookup
public struct VizMark<Def : VizMarkDefType> : VizMarkType, VizDSLType {
    public var markDef: Def
    public var encodings: FacetedEncoding = FacetedEncoding()
}

public extension VizMark {
    /// Creates a setter function for the given dynamic keypath, allowing a fluent API for all the properties
    subscript<U>(dynamicMember keyPath: WritableKeyPath<Def, U>) -> (U) -> (Self) {
        setting(path: (\Self.markDef).appending(path: keyPath))
    }
}

public extension VizMark {
    /// Adds this `VizMark` to an enclosing spec
    func add<M>(to spec: inout VizSpec<M>) where M : Pure {
        spec.mark = self.markDef.anyMark
        spec.encoding = self.encodings
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
    init(_ primitiveMark: PrimitiveMarkType, @VizEncodeArrayBuilder makeEncodings: () -> [VizEncodeType]) {
        markDef = MarkDef(type: primitiveMark)
        addEncodings(makeEncodings())
    }
}

public extension VizMark where Def == BoxPlotDef {
    init(_ boxPlot: BoxPlotLiteral, @VizEncodeArrayBuilder makeEncodings: () -> [VizEncodeType]) {
        markDef = BoxPlotDef(type: boxPlot)
        addEncodings(makeEncodings())
    }
}

public extension VizMark where Def == ErrorBarDef {
    init(_ errorBar: ErrorBarLiteral, @VizEncodeArrayBuilder makeEncodings: () -> [VizEncodeType]) {
        markDef = ErrorBarDef(type: errorBar)
        addEncodings(makeEncodings())
    }
}

public extension VizMark where Def == ErrorBandDef {
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
    func addChannel(to encodings: inout FacetedEncoding)
}

@dynamicMemberLookup
public struct VizEncode<Channel : VizEncodingChannelType, Def : Pure> : VizEncodeType {
    private var def: Def
    private let def2enc: (Def) -> (Channel)
}

public extension VizEncode {
    /// Creates a setter function for the given dynamic keypath, allowing a fluent API for all the properties
    subscript<U>(dynamicMember keyPath: WritableKeyPath<Def, U>) -> (U) -> (Self) {
         setting(path: (\Self.def).appending(path: keyPath))
    }
}

public extension VizEncode {
    func addEncoding(to encodings: inout FacetedEncoding) {
        def2enc(def).addChannel(to: &encodings)
    }
}


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

//    @available(*, unavailable, message: "first statement of builder be an element")
//    static func buildBlock(_ components: VizChannel...) -> [VizChannel] {
//      fatalError()
//    }
}


//public typealias VizMarkArrayBuilder = VizArrayBuilder<VizMarkType>
public typealias VizSpecElementArrayBuilder = VizArrayBuilder<VizSpecElementType>
public typealias VizEncodeArrayBuilder = VizArrayBuilder<VizEncodeType>


/// A layer for a visualization, either top-level
public protocol VizLayerType : VizDSLType {

}

public struct VizLayer : VizLayerType {
    public var layer: SimpleVizSpec

}

@dynamicMemberLookup
public struct Viz<M: Pure> : VizLayerType {
    var spec: VizSpec<M>

    public init(@VizSpecElementArrayBuilder _ makeElements: () -> [VizSpecElementType]) {
        var spec = VizSpec<M>()
        for element in makeElements() {
            element.add(to: &spec)
        }
        self.spec = spec
    }
}

public extension Viz {
    /// Creates a setter function for the given dynamic keypath, allowing a fluent API for all the properties
    subscript<U>(dynamicMember keyPath: WritableKeyPath<VizSpec<M>, U>) -> (U) -> (Self) {
        setting(path: (\Self.spec).appending(path: keyPath))
    }
}

extension Viz : CustomDebugStringConvertible {
    /// The Viz's description is the JSON describing the spec
    public var debugDescription: String { spec.jsonDebugDescription }
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







#if false // boilerplate for constructors for encodings

// MARK: VizEncode: XXX

public extension VizEncode where Channel == FacetedEncoding.EncodingXXX {
    enum XXXChannel { case xxx }
}

/// Empty Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingXXX, Def == Void {
    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    init(_ xxx: XXXChannel) {
        self.def2enc = { .init(.init($0)) }
    }
}

/// Field Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingXXX, Def == Channel.RawValue.RawValue.T1 {
    init(_ xxx: XXXChannel, field: FieldName) {
        /// Creates this encoding with the value mapped to the given field name in the data.
        self.def2enc = { .init(.init($0)) }
        self.def = .init(field: .init(field))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ xxx: XXXChannel, repeat: RepeatRef) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingXXX, Def == Channel.RawValue.RawValue.T2 {
    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ xxx: XXXChannel, datum: ExplicitNull) {
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ xxx: XXXChannel, datum: Double) {
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ xxx: XXXChannel, datum: String) {
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ xxx: XXXChannel, datum: Bool) {
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ xxx: XXXChannel, datum: DateTime) {
        let datetime: Def.DatumChoice.T2 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ xxx: XXXChannel, expression: String) {
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    init(_ xxx: XXXChannel, datum: RepeatRef) {
        let ref: Def.DatumChoice.T4 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingXXX, Def == Channel.RawValue.RawValue.T3 {
    /// Creates this encoding with the given constant value.
    init(_ xxx: XXXChannel, value constant: Double) {
        let value: Def.ValueChoice.T1 = constant
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ xxx: XXXChannel, value constant: LiteralWidth) {
        let value: Def.ValueChoice.T2 = constant
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ xxx: XXXChannel, value constant: LiteralHeight) {
        let value: Def.ValueChoice.T3 = constant
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ xxx: XXXChannel, value constant: ExprRef) {
        let value: Def.ValueChoice.T4 = constant
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }
}
#endif






// MARK: VizEncode: X

public extension VizEncode where Channel == FacetedEncoding.EncodingX {
    enum XChannel { case x }
}

/// Empty Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingX, Def == PositionFieldDef {
    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    init(_ x: XChannel) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ x: XChannel, field: FieldName) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init(field: .init(field))
    }
}

/// Field Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingX, Def == Channel.RawValue.RawValue.T1 {

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ x: XChannel, repeat: RepeatRef) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingX, Def == Channel.RawValue.RawValue.T2 {
    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ x: XChannel, datum: ExplicitNull) {
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ x: XChannel, datum: Double) {
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ x: XChannel, datum: String) {
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ x: XChannel, datum: Bool) {
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ x: XChannel, datum: DateTime) {
        let datetime: Def.DatumChoice.T2 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ x: XChannel, expression: String) {
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    init(_ x: XChannel, datum: RepeatRef) {
        let ref: Def.DatumChoice.T4 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingX, Def == Channel.RawValue.RawValue.T3 {
    /// Creates this encoding with the given constant value.
    init(_ x: XChannel, value constant: Double) {
        let value: Def.ValueChoice.T1 = constant
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ x: XChannel, value constant: LiteralWidth) {
        let value: Def.ValueChoice.T2 = constant
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ x: XChannel, value constant: LiteralHeight) {
        let value: Def.ValueChoice.T3 = constant
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ x: XChannel, value constant: ExprRef) {
        let value: Def.ValueChoice.T4 = constant
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }
}








// MARK: VizEncode: Y

public extension VizEncode where Channel == FacetedEncoding.EncodingY {
    enum YChannel { case y }
}

/// Empty Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingY, Def == PositionFieldDef {
    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    init(_ y: YChannel) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ y: YChannel, field: FieldName) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init(field: .init(field))
    }

}

/// Field Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingY, Def == Channel.RawValue.RawValue.T1 {
    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ y: YChannel, repeat: RepeatRef) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingY, Def == Channel.RawValue.RawValue.T2 {
    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ y: YChannel, datum: ExplicitNull) {
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ y: YChannel, datum: Double) {
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ y: YChannel, datum: String) {
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ y: YChannel, datum: Bool) {
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ y: YChannel, datum: DateTime) {
        let datetime: Def.DatumChoice.T2 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ y: YChannel, expression: String) {
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    init(_ y: YChannel, datum: RepeatRef) {
        let ref: Def.DatumChoice.T4 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingY, Def == Channel.RawValue.RawValue.T3 {
    /// Creates this encoding with the given constant value.
    init(_ y: YChannel, value constant: Double) {
        let value: Def.ValueChoice.T1 = constant
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ y: YChannel, value constant: LiteralWidth) {
        let value: Def.ValueChoice.T2 = constant
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ y: YChannel, value constant: LiteralHeight) {
        let value: Def.ValueChoice.T3 = constant
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ y: YChannel, value constant: ExprRef) {
        let value: Def.ValueChoice.T4 = constant
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }
}









// MARK: VizEncode: Color

public extension VizEncode where Channel == FacetedEncoding.EncodingColor {
    enum ColorChannel { case color }
}

/// Field Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingColor, Def == Channel.RawValue.RawValue.T1 {
    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    init(_ color: ColorChannel) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ color: ColorChannel, field: FieldName) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init(field: .init(field))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ color: ColorChannel, repeat: RepeatRef) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingColor, Def == Channel.RawValue.RawValue.T2 {
    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ color: ColorChannel, datum: ExplicitNull) {
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ color: ColorChannel, datum: Double) {
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ color: ColorChannel, datum: String) {
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ color: ColorChannel, datum: Bool) {
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ color: ColorChannel, datum: DateTime) {
        let datetime: Def.DatumChoice.T2 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ color: ColorChannel, expression: String) {
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    init(_ color: ColorChannel, datum: RepeatRef) {
        let ref: Def.DatumChoice.T4 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingColor, Def == Channel.RawValue.RawValue.T3 {
    /// Creates this encoding with the given constant value.
    init(_ color: ColorChannel, value constant: ExplicitNull) {
        let value: Def.ValueChoice.T1 = constant
        self.def2enc = { .init(.init($0)) }
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
    init(_ color: ColorChannel, value constant: ExprRef) {
        self.init(color, value: .init(constant))
    }

    private init(_ color: ColorChannel, value constant: OneOf3<ColorGradient, String, ExprRef>) {
        let value: Def.ValueChoice.T2 = constant
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }
}




// MARK: VizEncode: Fill

public extension VizEncode where Channel == FacetedEncoding.EncodingFill {
    enum FillChannel { case fill }
}

/// Field Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingFill, Def == Channel.RawValue.RawValue.T1 {
    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    init(_ fill: FillChannel) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ fill: FillChannel, field: FieldName) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init(field: .init(field))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ fill: FillChannel, repeat: RepeatRef) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingFill, Def == Channel.RawValue.RawValue.T2 {
    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ fill: FillChannel, datum: ExplicitNull) {
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ fill: FillChannel, datum: Double) {
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ fill: FillChannel, datum: String) {
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ fill: FillChannel, datum: Bool) {
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ fill: FillChannel, datum: DateTime) {
        let datetime: Def.DatumChoice.T2 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ fill: FillChannel, expression: String) {
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    init(_ fill: FillChannel, datum: RepeatRef) {
        let ref: Def.DatumChoice.T4 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingFill, Def == Channel.RawValue.RawValue.T3 {
    /// Creates this encoding with the given constant value.
    init(_ fill: FillChannel, value constant: ExplicitNull) {
        let value: Def.ValueChoice.T1 = constant
        self.def2enc = { .init(.init($0)) }
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
    init(_ fill: FillChannel, value constant: ExprRef) {
        self.init(fill, value: .init(constant))
    }

    private init(_ fill: FillChannel, value constant: OneOf3<ColorGradient, String, ExprRef>) {
        let value: Def.ValueChoice.T2 = constant
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }
}






// MARK: VizEncode: Stroke

public extension VizEncode where Channel == FacetedEncoding.EncodingStroke {
    enum StrokeChannel { case stroke }
}

/// Field Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingStroke, Def == Channel.RawValue.RawValue.T1 {
    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    init(_ stroke: StrokeChannel) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ stroke: StrokeChannel, field: FieldName) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init(field: .init(field))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ stroke: StrokeChannel, repeat: RepeatRef) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingStroke, Def == Channel.RawValue.RawValue.T2 {
    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ stroke: StrokeChannel, datum: ExplicitNull) {
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ stroke: StrokeChannel, datum: Double) {
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ stroke: StrokeChannel, datum: String) {
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ stroke: StrokeChannel, datum: Bool) {
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ stroke: StrokeChannel, datum: DateTime) {
        let datetime: Def.DatumChoice.T2 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ stroke: StrokeChannel, expression: String) {
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    init(_ stroke: StrokeChannel, datum: RepeatRef) {
        let ref: Def.DatumChoice.T4 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingStroke, Def == Channel.RawValue.RawValue.T3 {
    /// Creates this encoding with the given constant value.
    init(_ stroke: StrokeChannel, value constant: ExplicitNull) {
        let value: Def.ValueChoice.T1 = constant
        self.def2enc = { .init(.init($0)) }
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
    init(_ stroke: StrokeChannel, value constant: ExprRef) {
        self.init(stroke, value: .init(constant))
    }

    private init(_ stroke: StrokeChannel, value constant: OneOf3<ColorGradient, String, ExprRef>) {
        let value: Def.ValueChoice.T2 = constant
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }
}







//// MARK: VizEncode: XXX
//
//public extension VizEncode where Channel == FacetedEncoding.EncodingXXX {
//    enum EncodingXXXType { case XXX }
//}
//
//public extension VizEncode where Channel == FacetedEncoding.EncodingXXX, Def == FacetedEncoding.EncodingXXX.RawValue.RawValue.T1 {
//    init(_ size: EncodingXXXType, field: FieldName) {
//        self.def2enc = { .init(.init($0)) }
//        self.def = .init(field: .init(field))
//    }
//}






// MARK: VizEncode: size

public extension VizEncode where Channel == FacetedEncoding.EncodingSize {
    enum SizeChannel { case size }
}

/// Field Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingSize, Def == Channel.RawValue.RawValue.T1 {
    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    init(_ Size: SizeChannel) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ Size: SizeChannel, field: FieldName) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init(field: .init(field))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ Size: SizeChannel, repeat: RepeatRef) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingSize, Def == Channel.RawValue.RawValue.T2 {
    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ Size: SizeChannel, datum: ExplicitNull) {
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ Size: SizeChannel, datum: Double) {
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ Size: SizeChannel, datum: String) {
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ Size: SizeChannel, datum: Bool) {
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ Size: SizeChannel, datum: DateTime) {
        let datetime: Def.DatumChoice.T2 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ Size: SizeChannel, expression: String) {
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    init(_ Size: SizeChannel, datum: RepeatRef) {
        let ref: Def.DatumChoice.T4 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingSize, Def == Channel.RawValue.RawValue.T3 {
    /// Creates this encoding with the given constant value.
    init(_ Size: SizeChannel, value constant: Double) {
        let value: Def.ValueChoice.T1 = constant
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ Size: SizeChannel, expr constant: ExprRef) {
        let value: Def.ValueChoice.T2 = constant
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }
}







// MARK: VizEncode: strokeWidth

public extension VizEncode where Channel == FacetedEncoding.EncodingStrokeWidth {
    enum StrokeWidthChannel { case strokeWidth }
}

/// Field Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingStrokeWidth, Def == Channel.RawValue.RawValue.T1 {
    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    init(_ StrokeWidth: StrokeWidthChannel) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ StrokeWidth: StrokeWidthChannel, field: FieldName) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init(field: .init(field))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ StrokeWidth: StrokeWidthChannel, repeat: RepeatRef) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingStrokeWidth, Def == Channel.RawValue.RawValue.T2 {
    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ StrokeWidth: StrokeWidthChannel, datum: ExplicitNull) {
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ StrokeWidth: StrokeWidthChannel, datum: Double) {
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ StrokeWidth: StrokeWidthChannel, datum: String) {
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ StrokeWidth: StrokeWidthChannel, datum: Bool) {
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ StrokeWidth: StrokeWidthChannel, datum: DateTime) {
        let datetime: Def.DatumChoice.T2 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ StrokeWidth: StrokeWidthChannel, expression: String) {
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    init(_ StrokeWidth: StrokeWidthChannel, datum: RepeatRef) {
        let ref: Def.DatumChoice.T4 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingStrokeWidth, Def == Channel.RawValue.RawValue.T3 {
    /// Creates this encoding with the given constant value.
    init(_ StrokeWidth: StrokeWidthChannel, value constant: Double) {
        let value: Def.ValueChoice.T1 = constant
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ StrokeWidth: StrokeWidthChannel, expr constant: ExprRef) {
        let value: Def.ValueChoice.T2 = constant
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }
}









// MARK: VizEncode: strokeOpacity

public extension VizEncode where Channel == FacetedEncoding.EncodingStrokeOpacity {
    enum StrokeOpacityChannel { case strokeOpacity }
}

/// Field Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingStrokeOpacity, Def == Channel.RawValue.RawValue.T1 {
    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    init(_ StrokeOpacity: StrokeOpacityChannel) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ StrokeOpacity: StrokeOpacityChannel, field: FieldName) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init(field: .init(field))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ StrokeOpacity: StrokeOpacityChannel, repeat: RepeatRef) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingStrokeOpacity, Def == Channel.RawValue.RawValue.T2 {
    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ StrokeOpacity: StrokeOpacityChannel, datum: ExplicitNull) {
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ StrokeOpacity: StrokeOpacityChannel, datum: Double) {
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ StrokeOpacity: StrokeOpacityChannel, datum: String) {
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ StrokeOpacity: StrokeOpacityChannel, datum: Bool) {
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ StrokeOpacity: StrokeOpacityChannel, datum: DateTime) {
        let datetime: Def.DatumChoice.T2 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ StrokeOpacity: StrokeOpacityChannel, expression: String) {
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    init(_ StrokeOpacity: StrokeOpacityChannel, datum: RepeatRef) {
        let ref: Def.DatumChoice.T4 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingStrokeOpacity, Def == Channel.RawValue.RawValue.T3 {
    /// Creates this encoding with the given constant value.
    init(_ StrokeOpacity: StrokeOpacityChannel, value constant: Double) {
        let value: Def.ValueChoice.T1 = constant
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ StrokeOpacity: StrokeOpacityChannel, expr constant: ExprRef) {
        let value: Def.ValueChoice.T2 = constant
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }
}








// MARK: VizEncode: fillOpacity

public extension VizEncode where Channel == FacetedEncoding.EncodingFillOpacity {
    enum FillOpacityChannel { case fillOpacity }
}

/// Field Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingFillOpacity, Def == Channel.RawValue.RawValue.T1 {
    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    init(_ FillOpacity: FillOpacityChannel) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ FillOpacity: FillOpacityChannel, field: FieldName) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init(field: .init(field))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ FillOpacity: FillOpacityChannel, repeat: RepeatRef) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingFillOpacity, Def == Channel.RawValue.RawValue.T2 {
    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ FillOpacity: FillOpacityChannel, datum: ExplicitNull) {
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ FillOpacity: FillOpacityChannel, datum: Double) {
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ FillOpacity: FillOpacityChannel, datum: String) {
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ FillOpacity: FillOpacityChannel, datum: Bool) {
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ FillOpacity: FillOpacityChannel, datum: DateTime) {
        let datetime: Def.DatumChoice.T2 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ FillOpacity: FillOpacityChannel, expression: String) {
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    init(_ FillOpacity: FillOpacityChannel, datum: RepeatRef) {
        let ref: Def.DatumChoice.T4 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingFillOpacity, Def == Channel.RawValue.RawValue.T3 {
    /// Creates this encoding with the given constant value.
    init(_ FillOpacity: FillOpacityChannel, value constant: Double) {
        let value: Def.ValueChoice.T1 = constant
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ FillOpacity: FillOpacityChannel, expr constant: ExprRef) {
        let value: Def.ValueChoice.T2 = constant
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }
}







// MARK: VizEncode: opacity

public extension VizEncode where Channel == FacetedEncoding.EncodingOpacity {
    enum OpacityChannel { case opacity }
}

/// Field Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingOpacity, Def == Channel.RawValue.RawValue.T1 {
    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    init(_ Opacity: OpacityChannel) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ Opacity: OpacityChannel, field: FieldName) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init(field: .init(field))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ Opacity: OpacityChannel, repeat: RepeatRef) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingOpacity, Def == Channel.RawValue.RawValue.T2 {
    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ Opacity: OpacityChannel, datum: ExplicitNull) {
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ Opacity: OpacityChannel, datum: Double) {
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ Opacity: OpacityChannel, datum: String) {
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ Opacity: OpacityChannel, datum: Bool) {
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ Opacity: OpacityChannel, datum: DateTime) {
        let datetime: Def.DatumChoice.T2 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ Opacity: OpacityChannel, expression: String) {
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    init(_ Opacity: OpacityChannel, datum: RepeatRef) {
        let ref: Def.DatumChoice.T4 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingOpacity, Def == Channel.RawValue.RawValue.T3 {
    /// Creates this encoding with the given constant value.
    init(_ Opacity: OpacityChannel, value constant: Double) {
        let value: Def.ValueChoice.T1 = constant
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ Opacity: OpacityChannel, expr constant: ExprRef) {
        let value: Def.ValueChoice.T2 = constant
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }
}





// MARK: VizEncode: angle

public extension VizEncode where Channel == FacetedEncoding.EncodingAngle {
    enum AngleChannel { case angle }
}

/// Field Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingAngle, Def == Channel.RawValue.RawValue.T1 {
    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    init(_ Angle: AngleChannel) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ Angle: AngleChannel, field: FieldName) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init(field: .init(field))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ Angle: AngleChannel, repeat: RepeatRef) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingAngle, Def == Channel.RawValue.RawValue.T2 {
    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ Angle: AngleChannel, datum: ExplicitNull) {
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ Angle: AngleChannel, datum: Double) {
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ Angle: AngleChannel, datum: String) {
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ Angle: AngleChannel, datum: Bool) {
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ Angle: AngleChannel, datum: DateTime) {
        let datetime: Def.DatumChoice.T2 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ Angle: AngleChannel, expression: String) {
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    init(_ Angle: AngleChannel, datum: RepeatRef) {
        let ref: Def.DatumChoice.T4 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingAngle, Def == Channel.RawValue.RawValue.T3 {
    /// Creates this encoding with the given constant value.
    init(_ Angle: AngleChannel, value constant: Double) {
        let value: Def.ValueChoice.T1 = constant
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ Angle: AngleChannel, expr constant: ExprRef) {
        let value: Def.ValueChoice.T2 = constant
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }
}



// MARK: VizEncode: theta


public extension VizEncode where Channel == FacetedEncoding.EncodingTheta {
    enum ThetaChannel { case theta }
}

/// Field Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingTheta, Def == Channel.RawValue.RawValue.T1 {
    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    init(_ Theta: ThetaChannel) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ Theta: ThetaChannel, field: FieldName) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init(field: .init(field))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ Theta: ThetaChannel, repeat: RepeatRef) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingTheta, Def == Channel.RawValue.RawValue.T2 {
    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ Theta: ThetaChannel, datum: ExplicitNull) {
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ Theta: ThetaChannel, datum: Double) {
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ Theta: ThetaChannel, datum: String) {
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ Theta: ThetaChannel, datum: Bool) {
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ Theta: ThetaChannel, datum: DateTime) {
        let datetime: Def.DatumChoice.T2 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ Theta: ThetaChannel, expression: String) {
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    init(_ Theta: ThetaChannel, datum: RepeatRef) {
        let ref: Def.DatumChoice.T4 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingTheta, Def == Channel.RawValue.RawValue.T3 {
    /// Creates this encoding with the given constant value.
    init(_ Theta: ThetaChannel, value constant: Double) {
        let value: Def.ValueChoice.T1 = constant
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ Theta: ThetaChannel, value constant: LiteralWidth) {
        let value: Def.ValueChoice.T2 = constant
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }

    /// Creates this encoding with the given constant value.
    init(_ Theta: ThetaChannel, expr constant: LiteralHeight) {
        let value: Def.ValueChoice.T3 = constant
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }

    /// Creates this encoding with the given constant value.
    init(_ Theta: ThetaChannel, expr constant: ExprRef) {
        let value: Def.ValueChoice.T4 = constant
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }

}


// MARK: VizEncode: theta

public extension VizEncode where Channel == FacetedEncoding.EncodingTheta2 {
    enum Theta2Channel { case theta2 }
}

/// Field Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingTheta2, Def == Channel.RawValue.RawValue.T1 {
    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    init(_ Theta2: Theta2Channel) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ Theta2: Theta2Channel, field: FieldName) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init(field: .init(field))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ Theta2: Theta2Channel, repeat: RepeatRef) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingTheta2, Def == Channel.RawValue.RawValue.T2 {
    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ Theta2: Theta2Channel, datum: ExplicitNull) {
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ Theta2: Theta2Channel, datum: Double) {
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ Theta2: Theta2Channel, datum: String) {
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ Theta2: Theta2Channel, datum: Bool) {
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ Theta2: Theta2Channel, datum: DateTime) {
        let datetime: Def.DatumChoice.T2 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ Theta2: Theta2Channel, expression: String) {
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    init(_ Theta2: Theta2Channel, datum: RepeatRef) {
        let ref: Def.DatumChoice.T4 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingTheta2, Def == Channel.RawValue.RawValue.T3 {
    /// Creates this encoding with the given constant value.
    init(_ Theta2: Theta2Channel, value constant: Double) {
        let value: Def.ValueChoice.T1 = constant
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }

    /// Creates this encoding with the given constant value.
    init(_ Theta2: Theta2Channel, value constant: LiteralWidth) {
        let value: Def.ValueChoice.T2 = constant
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }

    /// Creates this encoding with the given constant value.
    init(_ Theta2: Theta2Channel, expr constant: LiteralHeight) {
        let value: Def.ValueChoice.T3 = constant
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }

    /// Creates this encoding with the given constant value.
    init(_ Theta2: Theta2Channel, expr constant: ExprRef) {
        let value: Def.ValueChoice.T4 = constant
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }
}


// MARK: VizEncode: radius

public extension VizEncode where Channel == FacetedEncoding.EncodingRadius {
    enum RadiusChannel { case radius }
}

/// Field Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingRadius, Def == Channel.RawValue.RawValue.T1 {
    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    init(_ Radius: RadiusChannel) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ Radius: RadiusChannel, field: FieldName) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init(field: .init(field))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ Radius: RadiusChannel, repeat: RepeatRef) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingRadius, Def == Channel.RawValue.RawValue.T2 {
    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ Radius: RadiusChannel, datum: ExplicitNull) {
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ Radius: RadiusChannel, datum: Double) {
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ Radius: RadiusChannel, datum: String) {
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ Radius: RadiusChannel, datum: Bool) {
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ Radius: RadiusChannel, datum: DateTime) {
        let datetime: Def.DatumChoice.T2 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ Radius: RadiusChannel, expression: String) {
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    init(_ Radius: RadiusChannel, datum: RepeatRef) {
        let ref: Def.DatumChoice.T4 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingRadius, Def == Channel.RawValue.RawValue.T3 {
    /// Creates this encoding with the given constant value.
    init(_ Radius: RadiusChannel, value constant: Double) {
        let value: Def.ValueChoice.T1 = constant
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }


    /// Creates this encoding with the given constant value.
    init(_ Radius: RadiusChannel, value constant: LiteralWidth) {
        let value: Def.ValueChoice.T2 = constant
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }

    /// Creates this encoding with the given constant value.
    init(_ Radius: RadiusChannel, expr constant: LiteralHeight) {
        let value: Def.ValueChoice.T3 = constant
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }

    /// Creates this encoding with the given constant value.
    init(_ Radius: RadiusChannel, expr constant: ExprRef) {
        let value: Def.ValueChoice.T4 = constant
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }
}


// MARK: VizEncode: radius2

public extension VizEncode where Channel == FacetedEncoding.EncodingRadius2 {
    enum Radius2Channel { case radius2 }
}

/// Field Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingRadius2, Def == Channel.RawValue.RawValue.T1 {
    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    init(_ Radius2: Radius2Channel) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init()
    }

    /// Creates this encoding with the value mapped to the given field name in the data.
    init(_ Radius2: Radius2Channel, field: FieldName) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init(field: .init(field))
    }

    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ Radius2: Radius2Channel, repeat: RepeatRef) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init(field: .init(`repeat`))
    }

}

/// Datum Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingRadius2, Def == Channel.RawValue.RawValue.T2 {
    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ Radius2: Radius2Channel, datum: ExplicitNull) {
        let value: Def.DatumChoice.T1.RawValue.T1 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ Radius2: Radius2Channel, datum: Double) {
        let value: Def.DatumChoice.T1.RawValue.T2 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ Radius2: Radius2Channel, datum: String) {
        let value: Def.DatumChoice.T1.RawValue.T3 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ Radius2: Radius2Channel, datum: Bool) {
        let value: Def.DatumChoice.T1.RawValue.T4 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(.init(value)))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ Radius2: Radius2Channel, datum: DateTime) {
        let datetime: Def.DatumChoice.T2 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(datetime))
    }

    /// Creates this encoding with the given datum that will be resolved against the scaled data values.
    init(_ Radius2: Radius2Channel, expression: String) {
        let ref: Def.DatumChoice.T3 = .init(expr: .init(expression))
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }

    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    init(_ Radius2: Radius2Channel, datum: RepeatRef) {
        let ref: Def.DatumChoice.T4 = datum
        self.def2enc = { .init(.init($0)) }
        self.def = .init(datum: .init(ref))
    }
}

/// Value Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingRadius2, Def == Channel.RawValue.RawValue.T3 {
    /// Creates this encoding with the given constant value.
    init(_ Radius2: Radius2Channel, value constant: Double) {
        let value: Def.ValueChoice.T1 = constant
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: .init(value))
    }


    /// Creates this encoding with the given constant value.
    init(_ Radius2: Radius2Channel, value constant: LiteralWidth) {
        let value: Def.ValueChoice.T2 = constant
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }

    /// Creates this encoding with the given constant value.
    init(_ Radius2: Radius2Channel, expr constant: LiteralHeight) {
        let value: Def.ValueChoice.T3 = constant
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }

    /// Creates this encoding with the given constant value.
    init(_ Radius2: Radius2Channel, expr constant: ExprRef) {
        let value: Def.ValueChoice.T4 = constant
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: .init(value)) // ambiguous with the other expr init?
    }
}


// MARK: VizEncode: xError

public extension VizEncode where Channel == FacetedEncoding.EncodingXError {
    enum XErrorChannel { case xError }
}

/// Empty Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingXError, Def == SecondaryFieldDef {
    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    init(_ XError: XErrorChannel) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init()
    }

    init(_ XError: XErrorChannel, field: FieldName) {
        /// Creates this encoding with the value mapped to the given field name in the data.
        self.def2enc = { .init($0) }
        self.def = .init(field: .init(field))
    }
}

/// Field Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingXError, Def == ValueDefNumber {
    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ XError: XErrorChannel, value constant: Double) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: constant)
    }
}


// MARK: VizEncode: xError2


public extension VizEncode where Channel == FacetedEncoding.EncodingXError2 {
    enum XError2Channel { case xError2 }
}

/// Empty Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingXError2, Def == SecondaryFieldDef {
    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    init(_ XError2: XError2Channel) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init()
    }

    init(_ XError2: XError2Channel, field: FieldName) {
        /// Creates this encoding with the value mapped to the given field name in the data.
        self.def2enc = { .init($0) }
        self.def = .init(field: .init(field))
    }
}

/// Field Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingXError2, Def == ValueDefNumber {
    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ XError2: XError2Channel, value constant: Double) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: constant)
    }
}

// MARK: VizEncode: yError


public extension VizEncode where Channel == FacetedEncoding.EncodingYError {
    enum YErrorChannel { case yError }
}

/// Empty Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingYError, Def == SecondaryFieldDef {
    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    init(_ YError: YErrorChannel) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init()
    }

    init(_ YError: YErrorChannel, field: FieldName) {
        /// Creates this encoding with the value mapped to the given field name in the data.
        self.def2enc = { .init($0) }
        self.def = .init(field: .init(field))
    }
}

/// Field Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingYError, Def == ValueDefNumber {
    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ YError: YErrorChannel, value constant: Double) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: constant)
    }
}

// MARK: VizEncode: yError2


public extension VizEncode where Channel == FacetedEncoding.EncodingYError2 {
    enum YError2Channel { case yError2 }
}

/// Empty Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingYError2, Def == SecondaryFieldDef {
    /// Creates this encoding with the given repeated datum that will be resolved against the scaled data values.
    init(_ YError2: YError2Channel) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init()
    }

    init(_ YError2: YError2Channel, field: FieldName) {
        /// Creates this encoding with the value mapped to the given field name in the data.
        self.def2enc = { .init($0) }
        self.def = .init(field: .init(field))
    }
}

/// Field Initializers
public extension VizEncode where Channel == FacetedEncoding.EncodingYError2, Def == ValueDefNumber {
    /// Creates this encoding with the repeat reference to one or more fields.
    init(_ YError2: YError2Channel, value constant: Double) {
        self.def2enc = { .init(.init($0)) }
        self.def = .init(value: constant)
    }
}


// MARK: VizEncode: x2
// MARK: VizEncode: y2



// MARK: VizEncode: latitude
// MARK: VizEncode: latitude2
// MARK: VizEncode: longitude
// MARK: VizEncode: longitude2



// MARK: VizEncode: column
// MARK: VizEncode: facet
// MARK: VizEncode: row

// MARK: VizEncode: description

// MARK: VizEncode: detail

// MARK: VizEncode: href

// MARK: VizEncode: key

// MARK: VizEncode: order

// MARK: VizEncode: shape

// MARK: VizEncode: strokeDash

// MARK: VizEncode: text

// MARK: VizEncode: tooltip

// MARK: VizEncode: url




private func emptyConstructor(channel: EncodingChannel) -> VizEncodeType {
    switch channel {
    case .angle: return VizEncode(.angle)
    case .color: return VizEncode(.color)
    case .fill: return VizEncode(.fill)
    case .fillOpacity: return VizEncode(.fillOpacity)
    case .opacity: return VizEncode(.opacity)
    case .radius: return VizEncode(.radius)
    case .radius2: return VizEncode(.radius2)
    case .size: return VizEncode(.size)
    case .stroke: return VizEncode(.stroke)
    case .strokeOpacity: return VizEncode(.strokeOpacity)
    case .strokeWidth: return VizEncode(.strokeWidth)
    case .theta: return VizEncode(.theta)
    case .theta2: return VizEncode(.theta2)
    case .x: return VizEncode(.x)
    case .y: return VizEncode(.y)
    case .xError: return VizEncode(.xError)
    case .xError2: return VizEncode(.xError2)
    case .yError: return VizEncode(.yError)
    case .yError2: return VizEncode(.yError2)

    default: fatalError(wip("WIP"))

//    case .x2: return VizEncode(.x2)
//    case .y2: return VizEncode(.y2)
//    case .column: return VizEncode(.column)
//    case .description: return VizEncode(.description)
//    case .detail: return VizEncode(.detail)
//    case .facet: return VizEncode(.facet)
//    case .href: return VizEncode(.href)
//    case .key: return VizEncode(.key)
//    case .latitude: return VizEncode(.latitude)
//    case .latitude2: return VizEncode(.latitude2)
//    case .longitude: return VizEncode(.longitude)
//    case .longitude2: return VizEncode(.longitude2)
//    case .order: return VizEncode(.order)
//    case .row: return VizEncode(.row)
//    case .shape: return VizEncode(.shape)
//    case .strokeDash: return VizEncode(.strokeDash)
//    case .text: return VizEncode(.text)
//    case .tooltip: return VizEncode(.tooltip)
//    case .url: return VizEncode(.url)
    }
}



/// Work-in-progress, simply to highlight a line with a deprecation warning
@available(*, deprecated, message: "work-in-progress")
fileprivate func wip<T>(_ value: T) -> T { value }





// MARK: VizEncodingChannelType Boilerplate

extension FacetedEncoding.EncodingAngle : VizEncodingChannelType {
    public func addChannel(to encodings: inout FacetedEncoding) {
        encodings.angle = self
    }
}

extension FacetedEncoding.EncodingColor : VizEncodingChannelType {
    public func addChannel(to encodings: inout FacetedEncoding) {
        encodings.color = self
    }
}

extension FacetedEncoding.EncodingDescription : VizEncodingChannelType {
    public func addChannel(to encodings: inout FacetedEncoding) {
        encodings.description = self
    }
}

extension FacetedEncoding.EncodingDetail : VizEncodingChannelType {
    public func addChannel(to encodings: inout FacetedEncoding) {
        encodings.detail = self
    }
}

extension FacetedEncoding.EncodingFill : VizEncodingChannelType {
    public func addChannel(to encodings: inout FacetedEncoding) {
        encodings.fill = self
    }
}

extension FacetedEncoding.EncodingFillOpacity : VizEncodingChannelType {
    public func addChannel(to encodings: inout FacetedEncoding) {
        encodings.fillOpacity = self
    }
}

extension FacetedEncoding.EncodingHref : VizEncodingChannelType {
    public func addChannel(to encodings: inout FacetedEncoding) {
        encodings.href = self
    }
}

extension FacetedEncoding.EncodingLatitude : VizEncodingChannelType {
    public func addChannel(to encodings: inout FacetedEncoding) {
        encodings.latitude = self
    }
}

extension FacetedEncoding.EncodingLatitude2 : VizEncodingChannelType {
    public func addChannel(to encodings: inout FacetedEncoding) {
        encodings.latitude2 = self
    }
}

extension FacetedEncoding.EncodingLongitude : VizEncodingChannelType {
    public func addChannel(to encodings: inout FacetedEncoding) {
        encodings.longitude = self
    }
}

extension FacetedEncoding.EncodingLongitude2 : VizEncodingChannelType {
    public func addChannel(to encodings: inout FacetedEncoding) {
        encodings.longitude2 = self
    }
}

extension FacetedEncoding.EncodingOpacity : VizEncodingChannelType {
    public func addChannel(to encodings: inout FacetedEncoding) {
        encodings.opacity = self
    }
}

extension FacetedEncoding.EncodingOrder : VizEncodingChannelType {
    public func addChannel(to encodings: inout FacetedEncoding) {
        encodings.order = self
    }
}

extension FacetedEncoding.EncodingRadius : VizEncodingChannelType {
    public func addChannel(to encodings: inout FacetedEncoding) {
        encodings.radius = self
    }
}

extension FacetedEncoding.EncodingRadius2 : VizEncodingChannelType {
    public func addChannel(to encodings: inout FacetedEncoding) {
        encodings.radius2 = self
    }
}

extension FacetedEncoding.EncodingShape : VizEncodingChannelType {
    public func addChannel(to encodings: inout FacetedEncoding) {
        encodings.shape = self
    }
}

extension FacetedEncoding.EncodingSize : VizEncodingChannelType {
    public func addChannel(to encodings: inout FacetedEncoding) {
        encodings.size = self
    }
}

extension FacetedEncoding.EncodingStroke : VizEncodingChannelType {
    public func addChannel(to encodings: inout FacetedEncoding) {
        encodings.stroke = self
    }
}

extension FacetedEncoding.EncodingStrokeDash : VizEncodingChannelType {
    public func addChannel(to encodings: inout FacetedEncoding) {
        encodings.strokeDash = self
    }
}

extension FacetedEncoding.EncodingStrokeOpacity : VizEncodingChannelType {
    public func addChannel(to encodings: inout FacetedEncoding) {
        encodings.strokeOpacity = self
    }
}

extension FacetedEncoding.EncodingStrokeWidth : VizEncodingChannelType {
    public func addChannel(to encodings: inout FacetedEncoding) {
        encodings.strokeWidth = self
    }
}

extension FacetedEncoding.EncodingText : VizEncodingChannelType {
    public func addChannel(to encodings: inout FacetedEncoding) {
        encodings.text = self
    }
}

extension FacetedEncoding.EncodingTheta : VizEncodingChannelType {
    public func addChannel(to encodings: inout FacetedEncoding) {
        encodings.theta = self
    }
}

extension FacetedEncoding.EncodingTheta2 : VizEncodingChannelType {
    public func addChannel(to encodings: inout FacetedEncoding) {
        encodings.theta2 = self
    }
}

extension FacetedEncoding.EncodingTooltip : VizEncodingChannelType {
    public func addChannel(to encodings: inout FacetedEncoding) {
        encodings.tooltip = self
    }
}

extension FacetedEncoding.EncodingUrl : VizEncodingChannelType {
    public func addChannel(to encodings: inout FacetedEncoding) {
        encodings.url = self
    }
}

extension FacetedEncoding.EncodingX : VizEncodingChannelType {
    public func addChannel(to encodings: inout FacetedEncoding) {
        encodings.x = self
    }
}

extension FacetedEncoding.EncodingX2 : VizEncodingChannelType {
    public func addChannel(to encodings: inout FacetedEncoding) {
        encodings.x2 = self
    }
}

extension FacetedEncoding.EncodingXError : VizEncodingChannelType {
    public func addChannel(to encodings: inout FacetedEncoding) {
        encodings.xError = self
    }
}

extension FacetedEncoding.EncodingXError2 : VizEncodingChannelType {
    public func addChannel(to encodings: inout FacetedEncoding) {
        encodings.xError2 = self
    }
}

extension FacetedEncoding.EncodingY : VizEncodingChannelType {
    public func addChannel(to encodings: inout FacetedEncoding) {
        encodings.y = self
    }
}

extension FacetedEncoding.EncodingY2 : VizEncodingChannelType {
    public func addChannel(to encodings: inout FacetedEncoding) {
        encodings.y2 = self
    }
}

extension FacetedEncoding.EncodingYError : VizEncodingChannelType {
    public func addChannel(to encodings: inout FacetedEncoding) {
        encodings.yError = self
    }
}

extension FacetedEncoding.EncodingYError2 : VizEncodingChannelType {
    public func addChannel(to encodings: inout FacetedEncoding) {
        encodings.yError2 = self
    }
}

extension FacetedEncoding.EncodingRow : VizEncodingChannelType {
    public func addChannel(to encodings: inout FacetedEncoding) {
        encodings.row = self
    }
}

extension FacetedEncoding.EncodingColumn : VizEncodingChannelType {
    public func addChannel(to encodings: inout FacetedEncoding) {
        encodings.column = self
    }
}

extension FacetedEncoding.EncodingFacet : VizEncodingChannelType {
    public func addChannel(to encodings: inout FacetedEncoding) {
        encodings.facet = self
    }
}

extension FacetedEncoding.EncodingKey : VizEncodingChannelType {
    public func addChannel(to encodings: inout FacetedEncoding) {
        encodings.key = self
    }
}
