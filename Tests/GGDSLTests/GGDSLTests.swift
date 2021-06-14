import XCTest
import GGDSL

final class GGDSLTests: XCTestCase {
    func testSimpleVizSpec() throws {
        _ = SimpleVizSpec()
    }

    func testSimpleBarChart() throws {
        _ = """
        {
          "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
          "description": "A simple bar chart with embedded data.",
          "data": {
            "values": [
              {"a": "A", "b": 28}, {"a": "B", "b": 55}, {"a": "C", "b": 43},
              {"a": "D", "b": 91}, {"a": "E", "b": 81}, {"a": "F", "b": 53},
              {"a": "G", "b": 19}, {"a": "H", "b": 87}, {"a": "I", "b": 52}
            ]
          },
          "mark": "bar",
          "encoding": {
            "x": {"field": "a", "type": "nominal", "axis": {"labelAngle": 0}},
            "y": {"field": "b", "type": "quantitative"}
          }
        }
        """

//        _ = VizMark(.bar, description: "A simple bar chart with embedded data.") {
//            VizEncode(.x, field: "a", type: .nominal)
//                .axis(labelAngle: 0)
//            VizEncode(.y, field: "b", type: .quantitative)
//        }
    }

    func testStackedBarChartwithRoundedCorners() throws {
        _ = """
        {
          "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
          "data": {"url": "data/seattle-weather.csv"},
          "mark": {"type": "bar", "cornerRadiusTopLeft": 3, "cornerRadiusTopRight": 3},
          "encoding": {
            "x": {"timeUnit": "month", "field": "date", "type": "ordinal"},
            "y": {"aggregate": "count"},
            "color": {"field": "weather"}
          }
        }
        """

//        _ = VizMark(.bar) {
//            VizEncode(.x, field: "date")
//                .measure(.ordinal)
//                .timeUnit(.month)
//            VizEncode(.y, aggregate: .count)
//            VizEncode(.color, field: "weather")
//        }
//        .cornerRadiusTopLeft(3)
//        .cornerRadiusTopRight(3)
    }

    func testLineChartWithHighlightedRectangles() {
        _ = """
        {
          "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
          "description": "The population of the German city of Falkensee over time",
          "width": 500,
          "data": {
            "values": [
              {"year": "1875", "population": 1309},
              {"year": "2014", "population": 41777}
            ],
            "format": {
              "parse": {"year": "date:'%Y'"}
            }
          },
          "layer": [
            {
              "mark": "rect",
              "data": {
                "values": [
                  {
                    "start": "1933",
                    "end": "1945",
                    "event": "Nazi Rule"
                  },
                  {
                    "start": "1948",
                    "end": "1989",
                    "event": "GDR (East Germany)"
                  }
                ],
                "format": {
                  "parse": {"start": "date:'%Y'", "end": "date:'%Y'"}
                }
              },
              "encoding": {
                "x": {
                  "field": "start",
                  "timeUnit": "year"
                },
                "x2": {
                  "field": "end",
                  "timeUnit": "year"
                },
                "color": {"field": "event", "type": "nominal"}
              }
            },
            {
              "mark": "line",
              "encoding": {
                "x": {
                  "field": "year",
                  "timeUnit": "year",
                  "title": "year (year)"
                },
                "y": {"field": "population", "type": "quantitative"},
                "color": {"value": "#333"}
              }
            },
            {
              "mark": "point",
              "encoding": {
                "x": {
                  "field": "year",
                  "timeUnit": "year"
                },
                "y": {"field": "population", "type": "quantitative"},
                "color": {"value": "#333"}
              }
            }
          ]
        }
        """

//        _ = Viz {
//            Layer(.overlay) {
//                Mark(.rect) {
//                    Source {
//                        [
//                            ["start": "1933", "end": "1945", "event": "Nazi Rule"],
//                            ["start": "1948", "end": "1989", "event": "GDR (East Germany)"],
//                        ]
//                    }
//                    Encode(.x, field: "start").timeUnit(.year)
//                    Encode(.x2, field: "end").timeUnit(.year)
//                    Encode(.color, field: "event").measure(.nominal)
//                }
//                Mark(.line) {
//                    Encode(.x, field: "year").timeUnit(.year).title("year (year)")
//                    Encode(.y, field: "population").measure(.quantitative)
//                    Encode(.color, value: "#333")
//                }
//                Mark(.point) {
//                    Encode(.x, field: "year").timeUnit(.year)
//                    Encode(.y, field: "population").measure(.quantitative)
//                    Encode(.color, value: "#333")
//                }
//            }
//        }
//        .arrangement(.overlay)
//        .width(500)

    }

    func testMultiSeriesLineChartWithRepeatOperator() throws {
        _ = """
        {
          "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
          "data": {
            "url": "data/movies.json"
          },
          "repeat": {
            "layer": ["US Gross", "Worldwide Gross"]
          },
          "spec": {
            "mark": "line",
            "encoding": {
              "x": {
                "bin": true,
                "field": "IMDB Rating",
                "type": "quantitative"
              },
              "y": {
                "aggregate": "mean",
                "field": {"repeat": "layer"},
                "type": "quantitative",
                "title": "Mean of US and Worldwide Gross"
              },
              "color": {
                "datum": {"repeat": "layer"},
                "type": "nominal"
              }
            }
          }
        }
        """

//        _ = ZRepeat(["US Gross", "Worldwide Gross"]) { repeatField in
//            Mark(.line) {
//                Encode(.x, field: "IMDB Rating")
//                    .measure(.quantitative)
//                    .bin(true)
//                Encode(.y, field: repeatField)
//                    .aggregate(.mean)
//                    .title("Mean of US and Worldwide Gross")
//                Encode(.color, datum: repeatField, type: .nominal)
//            }
//        }
//        .cornerRadiusTopLeft(3)
//        .cornerRadiusTopRight(3)

    }

    typealias SimpleViz = Viz<Bric.ObjType>

    func testSimpleSpec() throws {
        let viz = SimpleViz {
            //VizEncode(.color, field: FieldName("c"))//.measure(.ordinal)

            VizMark(.bar) {
                VizEncode(.x, field: FieldName("a")).measure(.nominal)
                VizEncode(.y, field: FieldName("b"))//.measure(.quantitative)
            }
            .cornerRadius(.init(10))
        }
        .title(.init(.init("Bar Chart")))
        .description("A simple bar chart with embedded data.")

        try check(viz: viz, againstJSON: """
        {
            "title": "Bar Chart",
            "description": "A simple bar chart with embedded data.",
            "mark": { "cornerRadius": 10, "type": "bar" },
            "encoding": {
                "x": { "field": "a" },
                "y": { "field":"b" }
            }
        }
        """)

//        try check(spec: spec, againstJSON: """
//        {
//          "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
//          "description": "A simple bar chart with embedded data.",
//          "data": {
//            "values": [
//              {"a": "A", "b": 28}, {"a": "B", "b": 55}, {"a": "C", "b": 43},
//              {"a": "D", "b": 91}, {"a": "E", "b": 81}, {"a": "F", "b": 53},
//              {"a": "G", "b": 19}, {"a": "H", "b": 87}, {"a": "I", "b": 52}
//            ]
//          },
//          "mark": "bar",
//          "encoding": {
//            "x": {"field": "a", "type": "nominal", "axis": {"labelAngle": 0}},
//            "y": {"field": "b", "type": "quantitative"}
//          }
//        }
//        """)
    }

    func check<M: VizSpecMeta>(viz: Viz<M>, againstJSON json: String) throws {
        let checkSpec = try VizSpec<M>.loadFromJSON(data: json.data(using: .utf8) ?? Data())
        XCTAssertEqual("\n" + viz.spec.jsonDebugDescription + "\n", "\n" + checkSpec.jsonDebugDescription + "\n")
        if viz.spec.jsonDebugDescription == checkSpec.jsonDebugDescription {
            XCTAssertEqual(viz.spec, checkSpec)
        }
    }

}

extension VizSpec {
//    static func sample() -> Self {
//        ZGroup {
//            Encode(.x, field: "a").axis(false)
//            Encode(.y, field: "b").axis(true)
//            VizMark(.bar) {
//                Encode(.color, field: "c").legend(true)
//                Encode(.tooltip, fields: ["d", "e"])
//            }
//            VizMark(.text) {
//                Encode(.text, value: "Fields")
//                Encode(.text, field: "c")
//                Encode(.text, field: "d")
//                Encode(.text, field: "e")
//                Encode(.color, value: .gray)
//            }
//        }
//    }

//    static func simple1() -> Self {
//        VizSpec(title: "Simple Bar Chart") {
//            ZLayer(fields: ["A", "B"]) { field in
//                Mark(.bar) {
//                    Channel(.x, from: Field("COL_A"), type: .temporal).axis(false)
//                    Channel(.y, from: Field("COL_B"), type: .ordinal)
//                    Channel(.fill, from: Field("COL_C"), type: .nominal).legend(true)
//                }
//                .axis(true)
//                .legend(true)
//
//                Mark(.text) {
//                    Channel(.x, from: Field("COL_A"), type: .temporal).axis(false)
//                    Channel(.y, from: Field("COL_B"), type: .ordinal)
//                    Channel(.fill, from: Field("COL_C"), type: .nominal).legend(true)
//                }
//                .axis(true)
//                .legend(true)
//            }
//            .arrangement(.overlay)
//        }
//    }
}

protocol FacetOrient {
}

struct VFacetOrient : FacetOrient { }
struct HFacetOrient : FacetOrient { }
struct ZFacetOrient : FacetOrient { }
struct RFacetOrient : FacetOrient { }

struct FacetLayer<Field, O: FacetOrient> {
    init(fields: [Field]) {
    }
}

extension FacetLayer where Field == Never {
    init() {
    }
}

typealias VFacet<Field> = FacetLayer<Field, VFacetOrient>
typealias HFacet<Field> = FacetLayer<Field, HFacetOrient>
typealias ZFacet<Field> = FacetLayer<Field, ZFacetOrient>
typealias RFacet<Field> = FacetLayer<Field, RFacetOrient>


protocol VizMarkType {
    var anyMark: AnyMark { get }
    var encodings: FacetedEncoding { get }
}

protocol VizMarkDefType : Pure {
    var anyMark: AnyMark { get }
}

extension MarkDef : VizMarkDefType {
    var anyMark: AnyMark { .init(self) }
}

extension BoxPlotDef : VizMarkDefType {
    var anyMark: AnyMark { .init(.init(self)) }
}

extension ErrorBarDef : VizMarkDefType {
    var anyMark: AnyMark { .init(.init(self)) }
}

extension ErrorBandDef : VizMarkDefType {
    var anyMark: AnyMark { .init(.init(self)) }
}

@dynamicMemberLookup
struct VizMark<Def : VizMarkDefType> : VizMarkType, Equatable {
    var markDef: Def
    var encodings: FacetedEncoding = FacetedEncoding()
    var anyMark: AnyMark { markDef.anyMark }
}

extension VizMark {
    fileprivate mutating func addEncodings(_ newEncodings: [VizEncodeType]) {
        for enc in newEncodings {
            enc.addEncoding(to: &encodings)
        }
    }
}

extension VizMark where Def == MarkDef {
    init(_ primitiveMark: PrimitiveMarkType, @VizEncodeArrayBuilder makeEncodings: () -> [VizEncodeType]) {
        markDef = MarkDef(type: primitiveMark)
        addEncodings(makeEncodings())
    }
}

extension VizMark where Def == BoxPlotDef {
    init(_ boxPlot: BoxPlotLiteral, @VizEncodeArrayBuilder makeEncodings: () -> [VizEncodeType]) {
        markDef = BoxPlotDef(type: boxPlot)
        addEncodings(makeEncodings())
    }
}

extension VizMark where Def == ErrorBarDef {
    init(_ errorBar: ErrorBarLiteral, @VizEncodeArrayBuilder makeEncodings: () -> [VizEncodeType]) {
        markDef = ErrorBarDef(type: errorBar)
        addEncodings(makeEncodings())
    }
}

extension VizMark where Def == ErrorBandDef {
    init(_ errorBand: ErrorBandLiteral, @VizEncodeArrayBuilder makeEncodings: () -> [VizEncodeType]) {
        markDef = ErrorBandDef(type: errorBand)
        addEncodings(makeEncodings())
    }
}

protocol VizEncodeType {
    /// Adds this encoding information to the given `FacetedEncoding`
    func addEncoding(to encodings: inout FacetedEncoding)
}


protocol VizEncodingType : Pure {
    func addEncoding(to encodings: inout FacetedEncoding)
}

@dynamicMemberLookup
struct VizEncode<Encoding : VizEncodingType> : VizEncodeType, Equatable {
    var encoding: Encoding

    func addEncoding(to encodings: inout FacetedEncoding) {
        encoding.addEncoding(to: &encodings)
    }
}


@resultBuilder
enum VizArrayBuilder<T> {
    static func buildEither(first component: [T]) -> [T] {
        return component
    }

    static func buildEither(second component: [T]) -> [T] {
        return component
    }

    static func buildOptional(_ component: [T]?) -> [T] {
        return component ?? []
    }

    static func buildBlock(_ components: [T]...) -> [T] {
        return components.flatMap { $0 }
    }

    static func buildExpression(_ expression: T) -> [T] {
        return [expression]
    }

    static func buildExpression(_ expression: Void) -> [T] {
        return []
    }

//    @available(*, unavailable, message: "first statement of builder be an element")
//    static func buildBlock(_ components: VizChannel...) -> [VizChannel] {
//      fatalError()
//    }
}

typealias VizMarkArrayBuilder = VizArrayBuilder<VizMarkType>
typealias VizEncodeArrayBuilder = VizArrayBuilder<VizEncodeType>


@dynamicMemberLookup
struct Viz<M: VizSpecMeta> : Equatable {
    var spec: VizSpec<M>

    init(@VizMarkArrayBuilder _ makeMarks: () -> [VizMarkType]) {
        self.spec = VizSpec()

        let marks = makeMarks()
        if marks.count == 0 {

        } else if marks.count == 1 {
            for mark in marks {
                self.spec.mark = mark.anyMark
                self.spec.encoding = mark.encodings
            }
        } else {
            for mark in marks {
                var layer = VizSpec<M>(mark: mark.anyMark)
                layer.encoding = mark.encodings
                self.spec.sublayers.append(layer)
            }
        }
    }
}

extension Viz {
    /// Creates a setter function for the given dynamic keypath, allowing a fluent API for all the properties
    public subscript<U>(dynamicMember keyPath: WritableKeyPath<VizSpec<M>, U>) -> (U) -> (Self) {
        setting(path: (\Self.spec).appending(path: keyPath))
    }
}

extension VizMark {
    /// Creates a setter function for the given dynamic keypath, allowing a fluent API for all the properties
    public subscript<U>(dynamicMember keyPath: WritableKeyPath<Def, U>) -> (U) -> (Self) {
        setting(path: (\Self.markDef).appending(path: keyPath))
    }
}

extension VizEncode {
    /// Creates a setter function for the given dynamic keypath, allowing a fluent API for all the properties
    public subscript<U>(dynamicMember keyPath: WritableKeyPath<Encoding, U>) -> (U) -> (Self) {
        setting(path: (\Self.encoding).appending(path: keyPath))
    }
}

extension VizEncode {
    public func measure(_ measure: StandardMeasureType) -> Self {
        var this = self
        return this
    }
}


extension Equatable {
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



// MARK: VizEncodingType Boilerplate

extension FacetedEncoding.EncodingAngle : VizEncodingType {
    func addEncoding(to encodings: inout FacetedEncoding) {
        encodings.angle = self
    }
}

extension FacetedEncoding.EncodingColor : VizEncodingType {
    func addEncoding(to encodings: inout FacetedEncoding) {
        encodings.color = self
    }
}

extension FacetedEncoding.EncodingColumn : VizEncodingType {
    func addEncoding(to encodings: inout FacetedEncoding) {
        encodings.column = self
    }
}

extension FacetedEncoding.EncodingDescription : VizEncodingType {
    func addEncoding(to encodings: inout FacetedEncoding) {
        encodings.description = self
    }
}

extension FacetedEncoding.EncodingDetail : VizEncodingType {
    func addEncoding(to encodings: inout FacetedEncoding) {
        encodings.detail = self
    }
}

extension FacetedEncoding.EncodingFacet : VizEncodingType {
    func addEncoding(to encodings: inout FacetedEncoding) {
        encodings.facet = self
    }
}

extension FacetedEncoding.EncodingFill : VizEncodingType {
    func addEncoding(to encodings: inout FacetedEncoding) {
        encodings.fill = self
    }
}

extension FacetedEncoding.EncodingFillOpacity : VizEncodingType {
    func addEncoding(to encodings: inout FacetedEncoding) {
        encodings.fillOpacity = self
    }
}

extension FacetedEncoding.EncodingHref : VizEncodingType {
    func addEncoding(to encodings: inout FacetedEncoding) {
        encodings.href = self
    }
}

extension FacetedEncoding.EncodingKey : VizEncodingType {
    func addEncoding(to encodings: inout FacetedEncoding) {
        encodings.key = self
    }
}

extension FacetedEncoding.EncodingLatitude : VizEncodingType {
    func addEncoding(to encodings: inout FacetedEncoding) {
        encodings.latitude = self
    }
}

extension FacetedEncoding.EncodingLatitude2 : VizEncodingType {
    func addEncoding(to encodings: inout FacetedEncoding) {
        encodings.latitude2 = self
    }
}

extension FacetedEncoding.EncodingLongitude : VizEncodingType {
    func addEncoding(to encodings: inout FacetedEncoding) {
        encodings.longitude = self
    }
}

extension FacetedEncoding.EncodingLongitude2 : VizEncodingType {
    func addEncoding(to encodings: inout FacetedEncoding) {
        encodings.longitude2 = self
    }
}

extension FacetedEncoding.EncodingOpacity : VizEncodingType {
    func addEncoding(to encodings: inout FacetedEncoding) {
        encodings.opacity = self
    }
}

extension FacetedEncoding.EncodingOrder : VizEncodingType {
    func addEncoding(to encodings: inout FacetedEncoding) {
        encodings.order = self
    }
}

extension FacetedEncoding.EncodingRadius : VizEncodingType {
    func addEncoding(to encodings: inout FacetedEncoding) {
        encodings.radius = self
    }
}

extension FacetedEncoding.EncodingRadius2 : VizEncodingType {
    func addEncoding(to encodings: inout FacetedEncoding) {
        encodings.radius2 = self
    }
}

extension FacetedEncoding.EncodingRow : VizEncodingType {
    func addEncoding(to encodings: inout FacetedEncoding) {
        encodings.row = self
    }
}

extension FacetedEncoding.EncodingShape : VizEncodingType {
    func addEncoding(to encodings: inout FacetedEncoding) {
        encodings.shape = self
    }
}

extension FacetedEncoding.EncodingSize : VizEncodingType {
    func addEncoding(to encodings: inout FacetedEncoding) {
        encodings.size = self
    }
}

extension FacetedEncoding.EncodingStroke : VizEncodingType {
    func addEncoding(to encodings: inout FacetedEncoding) {
        encodings.stroke = self
    }
}

extension FacetedEncoding.EncodingStrokeDash : VizEncodingType {
    func addEncoding(to encodings: inout FacetedEncoding) {
        encodings.strokeDash = self
    }
}

extension FacetedEncoding.EncodingStrokeOpacity : VizEncodingType {
    func addEncoding(to encodings: inout FacetedEncoding) {
        encodings.strokeOpacity = self
    }
}

extension FacetedEncoding.EncodingStrokeWidth : VizEncodingType {
    func addEncoding(to encodings: inout FacetedEncoding) {
        encodings.strokeWidth = self
    }
}

extension FacetedEncoding.EncodingText : VizEncodingType {
    func addEncoding(to encodings: inout FacetedEncoding) {
        encodings.text = self
    }
}

extension FacetedEncoding.EncodingTheta : VizEncodingType {
    func addEncoding(to encodings: inout FacetedEncoding) {
        encodings.theta = self
    }
}

extension FacetedEncoding.EncodingTheta2 : VizEncodingType {
    func addEncoding(to encodings: inout FacetedEncoding) {
        encodings.theta2 = self
    }
}

extension FacetedEncoding.EncodingTooltip : VizEncodingType {
    func addEncoding(to encodings: inout FacetedEncoding) {
        encodings.tooltip = self
    }
}

extension FacetedEncoding.EncodingUrl : VizEncodingType {
    func addEncoding(to encodings: inout FacetedEncoding) {
        encodings.url = self
    }
}

extension FacetedEncoding.EncodingX : VizEncodingType {
    func addEncoding(to encodings: inout FacetedEncoding) {
        encodings.x = self
    }
}

extension FacetedEncoding.EncodingX2 : VizEncodingType {
    func addEncoding(to encodings: inout FacetedEncoding) {
        encodings.x2 = self
    }
}

extension FacetedEncoding.EncodingXError : VizEncodingType {
    func addEncoding(to encodings: inout FacetedEncoding) {
        encodings.xError = self
    }
}

extension FacetedEncoding.EncodingXError2 : VizEncodingType {
    func addEncoding(to encodings: inout FacetedEncoding) {
        encodings.xError2 = self
    }
}

extension FacetedEncoding.EncodingY : VizEncodingType {
    func addEncoding(to encodings: inout FacetedEncoding) {
        encodings.y = self
    }
}

extension FacetedEncoding.EncodingY2 : VizEncodingType {
    func addEncoding(to encodings: inout FacetedEncoding) {
        encodings.y2 = self
    }
}

extension FacetedEncoding.EncodingYError : VizEncodingType {
    func addEncoding(to encodings: inout FacetedEncoding) {
        encodings.yError = self
    }
}

extension FacetedEncoding.EncodingYError2 : VizEncodingType {
    func addEncoding(to encodings: inout FacetedEncoding) {
        encodings.yError2 = self
    }
}

extension VizEncode where Encoding == FacetedEncoding.EncodingX {
    enum EncodingXType { case x }

    init(_ x: EncodingXType, field: FieldName) {
        self.encoding = .init(.init(.init(field: .init(field))))
    }
}

extension VizEncode where Encoding == FacetedEncoding.EncodingY {
    enum EncodingYType { case y }

    init(_ y: EncodingYType, field: FieldName) {
        self.encoding = .init(.init(.init(field: .init(field))))
    }
}

