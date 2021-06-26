

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
public protocol FluentContainer {
    associatedtype RawValue
    var rawValue: RawValue { get set }
}

/// A wrapper around an arbitrary instance that exposes fluent-style
/// function properties for all of the writable key paths of the raw value.
@dynamicMemberLookup
@frozen public struct Fluent<RawValue> : RawIsomorphism, FluentContainer {
    public var rawValue: RawValue

    public init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
}

public extension Pure {
    // not working; spec.fluent.f(x) doesn't modify the underlying spec; use mutating get?
//    /// Exposes a `Fluent` interface to the given instance
//    @inlinable var fluent: Fluent<Self> {
//        mutating get { Fluent(self) }
//        set { self = newValue.rawValue }
//    }
}

extension FluentContainer {
    /// Fluent DSL setting function for all the mutable properties of an instance
    @inlinable public subscript<U>(dynamicMember keyPath: WritableKeyPath<RawValue, U>) -> (U) -> (Self) {
        { assigning(value: $0, to: keyPath, with: { $0 }) }
    }

    /// Fluent DSL setting function for all the mutable properties of a raw instance
    @inlinable public subscript<Raw: RawInitializable, U>(dynamicMember keyPath: WritableKeyPath<RawValue, Raw?>) -> (U) -> (Self) where Raw.RawValue == U {
        { assigning(value: $0, to: keyPath, with: { Raw(rawValue: $0) }) }
    }

    /// Fluent DSL setting function for all the mutable `OneOf` properties of an instance
    @inlinable public subscript<Choice: OneOfNType, U>(dynamicMember keyPath: WritableKeyPath<RawValue, Choice?>) -> (U) -> (Self) where Choice.T1 == U {
        { assigning(value: $0, to: keyPath, with: { .init($0) }) }
    }

    /// Fluent DSL setting function for all the mutable `OneOf` properties of an instance that can be initialized with a raw value
    @inlinable public subscript<Choice: OneOfNType, Raw: RawInitializable, U>(dynamicMember keyPath: WritableKeyPath<RawValue, Choice?>) -> (U) -> (Self) where Choice.T1 == Raw, Raw.RawValue == U {
        { assigning(value: $0, to: keyPath, with: { .init(Raw(rawValue: $0)) }) }
    }

    /// Fluent DSL setting function for all the mutable `OneOf` properties of an instance that can be initialized with a raw value to another `OneOf` type
    @inlinable public subscript<Choice: OneOf2Type, Raw: RawInitializable, Choice2: OneOfNType>(dynamicMember keyPath: WritableKeyPath<RawValue, Choice?>) -> (Choice2.T1) -> (Self) where Choice.T1 == Raw, Raw.RawValue == Choice2 {
        { assigning(value: $0, to: keyPath, with: { .init(Raw(rawValue: .init($0))) }) }
    }

    /// Fluent DSL setting function for all the mutable `OneOf` properties of an instance that can be initialized with a raw value to another `OneOf` type
    @inlinable public subscript<Choice1: OneOf2Type, Raw: RawInitializable, Choice2: OneOfNType, Choice3: OneOf2Type>(dynamicMember keyPath: WritableKeyPath<RawValue, Choice1?>) -> (Choice3.T1) -> (Self) where Choice1.T1 == Raw, Raw.RawValue == Choice2, Choice2.T1 == Choice3 {
        { assigning(value: $0, to: keyPath, with: { .init(Raw(rawValue: .init(.init($0)))) }) }
    }

    /// Fluent DSL setting function for all the mutable `OneOf` properties of an instance that can be initialized with a raw value to another `OneOf` type
    @inlinable public subscript<Choice1: OneOf2Type, Raw1: RawInitializable, Choice2: OneOfNType, Raw2: RawInitializable>(dynamicMember keyPath: WritableKeyPath<RawValue, Choice1?>) -> (Choice1.T1.RawValue.T1.RawValue) -> (Self) where Choice1.T1 == Raw1, Raw1.RawValue == Choice2, Choice2.T1 == Raw2 {
        { assigning(value: $0, to: keyPath, with: { .init(Raw1(rawValue: .init(Raw2(rawValue: $0)))) }) }
    }


    /// Fluent DSL setting function for all the mutable `OneOf` properties of an instance
    @inlinable public subscript<Choice: OneOf2Type, U>(dynamicMember keyPath: WritableKeyPath<RawValue, Choice?>) -> (U) -> (Self) where Choice.T2 == U {
        { assigning(value: $0, to: keyPath, with: { .init($0) }) }
    }

    /// Fluent DSL setting function for all the mutable `OneOf` properties of an instance that can be initialized with a raw value
    @inlinable public subscript<Choice: OneOf2Type, Raw: RawInitializable, U>(dynamicMember keyPath: WritableKeyPath<RawValue, Choice?>) -> (U) -> (Self) where Choice.T2 == Raw, Raw.RawValue == U {
        { assigning(value: $0, to: keyPath, with: { .init(Raw(rawValue: $0)) }) }
    }



    /// Fluent DSL setting function for all the mutable `OneOf` properties of an instance
    @inlinable public subscript<Choice: OneOf3Type, U>(dynamicMember keyPath: WritableKeyPath<RawValue, Choice?>) -> (U) -> (Self) where Choice.T3 == U {
        { assigning(value: $0, to: keyPath, with: { .init($0) }) }
    }

    /// Fluent DSL setting function for all the mutable `OneOf` properties of an instance that can be initialized with a raw value
    @inlinable public subscript<Choice: OneOf3Type, Raw: RawInitializable, U>(dynamicMember keyPath: WritableKeyPath<RawValue, Choice?>) -> (U) -> (Self) where Choice.T3 == Raw, Raw.RawValue == U {
        { assigning(value: $0, to: keyPath, with: { .init(Raw(rawValue: $0)) }) }
    }



    /// Fluent DSL setting function for all the mutable `OneOf` properties of an instance
    @inlinable public subscript<Choice: OneOf4Type, U>(dynamicMember keyPath: WritableKeyPath<RawValue, Choice?>) -> (U) -> (Self) where Choice.T4 == U {
        { assigning(value: $0, to: keyPath, with: { .init($0) }) }
    }


    /// Fluent DSL setting function for all the mutable `OneOf` properties of an instance that can be initialized with a raw value
    @inlinable public subscript<Choice: OneOf4Type, Raw: RawInitializable, U>(dynamicMember keyPath: WritableKeyPath<RawValue, Choice?>) -> (U) -> (Self) where Choice.T4 == Raw, Raw.RawValue == U {
        { assigning(value: $0, to: keyPath, with: { .init(Raw(rawValue: $0)) }) }
    }



    /// Fluent DSL setting function for all the mutable `OneOf` properties of an instance
    @inlinable public subscript<Choice: OneOf5Type, U>(dynamicMember keyPath: WritableKeyPath<RawValue, Choice?>) -> (U) -> (Self) where Choice.T5 == U {
        { assigning(value: $0, to: keyPath, with: { .init($0) }) }
    }

    /// Fluent DSL setting function for all the mutable `OneOf` properties of an instance that can be initialized with a raw value
    @inlinable public subscript<Choice: OneOf5Type, Raw: RawInitializable, U>(dynamicMember keyPath: WritableKeyPath<RawValue, Choice?>) -> (U) -> (Self) where Choice.T5 == Raw, Raw.RawValue == U {
        { assigning(value: $0, to: keyPath, with: { .init(Raw(rawValue: $0)) }) }
    }



    // these are deepest dynamic path we expose, explicitly to support easy initialization of constants like:
    // Choice1: TimeUnitChoice = OneOf<TimeUnit>.Or<TimeUnitParams>
    // Raw1: TimeUnit
    // Choice2: TimeUnit.RawValue = OneOf<SingleTimeUnit>.Or<MultiTimeUnit>
    // Raw2: SingleTimeUnit
    // Choice3: SingleTimeUnit.RawValue = OneOf<LocalSingleTimeUnit>.Or<UtcSingleTimeUnit>
    // Choice3.T1: LocalSingleTimeUnit { case year, quarter, month, … }

    /// Fluent DSL setting function for all the mutable `OneOf` properties of an instance that can be initialized with a raw value to another `OneOf` type
    @inlinable public subscript<Choice1: OneOfNType, Raw1: RawInitializable, Choice2: OneOfNType, Raw2: RawInitializable, Choice3: OneOfNType>(dynamicMember keyPath: WritableKeyPath<RawValue, Choice1?>) -> (Choice1.T1.RawValue.T1.RawValue.T1) -> (Self) where Choice1.T1 == Raw1, Raw1.RawValue == Choice2, Choice2.T1 == Raw2, Raw2.RawValue == Choice3 {
        { assigning(value: $0, to: keyPath, with: { .init(Raw1(rawValue: .init(Raw2(rawValue: .init($0))))) }) }
    }

    /// Fluent DSL setting function for all the mutable `OneOf` properties of an instance that can be initialized with a raw value to another `OneOf` type
    @inlinable public subscript<Choice1: OneOfNType, Raw1: RawInitializable, Choice2: OneOfNType, Raw2: RawInitializable, Choice3: OneOf2Type>(dynamicMember keyPath: WritableKeyPath<RawValue, Choice1?>) -> (Choice1.T1.RawValue.T1.RawValue.T2) -> (Self) where Choice1.T1 == Raw1, Raw1.RawValue == Choice2, Choice2.T1 == Raw2, Raw2.RawValue == Choice3 {
        { assigning(value: $0, to: keyPath, with: { .init(Raw1(rawValue: .init(Raw2(rawValue: .init($0))))) }) }
    }

    /// Fluent DSL setting function for all the mutable `OneOf` properties of an instance that can be initialized with a raw value to another `OneOf` type
    @inlinable public subscript<Choice1: OneOfNType, Raw1: RawInitializable, Choice2: OneOf2Type, Raw2: RawInitializable, Choice3: OneOfNType>(dynamicMember keyPath: WritableKeyPath<RawValue, Choice1?>) -> (Choice1.T1.RawValue.T2.RawValue.T1) -> (Self) where Choice1.T1 == Raw1, Raw1.RawValue == Choice2, Choice2.T2 == Raw2, Raw2.RawValue == Choice3 {
        { assigning(value: $0, to: keyPath, with: { .init(Raw1(rawValue: .init(Raw2(rawValue: .init($0))))) }) }
    }

    /// Fluent DSL setting function for all the mutable `OneOf` properties of an instance that can be initialized with a raw value to another `OneOf` type
    @inlinable public subscript<Choice1: OneOfNType, Raw1: RawInitializable, Choice2: OneOf2Type, Raw2: RawInitializable, Choice3: OneOf2Type>(dynamicMember keyPath: WritableKeyPath<RawValue, Choice1?>) -> (Choice1.T1.RawValue.T2.RawValue.T2) -> (Self) where Choice1.T1 == Raw1, Raw1.RawValue == Choice2, Choice2.T2 == Raw2, Raw2.RawValue == Choice3 {
        { assigning(value: $0, to: keyPath, with: { .init(Raw1(rawValue: .init(Raw2(rawValue: .init($0))))) }) }
    }


    /// Assigns the given  value to the keyPath using the specific transform function
    @usableFromInline func assigning<T, U>(value: T, to keyPath: WritableKeyPath<RawValue, U>, with transform: (T) throws -> (U)) rethrows -> Self {
        var this = self
        this.rawValue[keyPath: keyPath] = try transform(value)
        return this
    }
}
