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


    func testSimpleSpec() throws {
        VizMark(.bar) {
//                VizEncode(.x, field: FieldName("a")).measure(.nominal)
//                VizEncode(.y, field: FieldName("b")).measure(.quantitative)
        }


        let viz = SimpleViz {
            VizMark(.bar) {

            }
            .cornerRadius(.init(10))
        }
        .description("A simple bar chart with embedded data.")
        //.title(.init(.init("xxx")))

        try check(viz: viz, againstJSON: """
        {
          "description": "A simple bar chart with embedded data.",
          "mark": {"cornerRadius":10,"type":"bar"},
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
}

protocol VizMarkDefType {
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
struct VizMark<Def : VizMarkDefType> : VizMarkType {
    var markDef: Def
    var anyMark: AnyMark { markDef.anyMark }
}

extension VizMark where Def == MarkDef {
    init(_ primitiveMark: PrimitiveMarkType, @VizEncodeArrayBuilder makeEncodings: () -> [VizEncode]) {
        markDef = MarkDef(type: primitiveMark)
    }
}

extension VizMark where Def == BoxPlotDef {
    init(_ boxPlot: BoxPlotLiteral, @VizEncodeArrayBuilder makeEncodings: () -> [VizEncode]) {
        markDef = BoxPlotDef(type: boxPlot)
    }
}

extension VizMark where Def == ErrorBarDef {
    init(_ errorBar: ErrorBarLiteral, @VizEncodeArrayBuilder makeEncodings: () -> [VizEncode]) {
        markDef = ErrorBarDef(type: errorBar)
    }
}

extension VizMark where Def == ErrorBandDef {
    init(_ errorBand: ErrorBandLiteral, @VizEncodeArrayBuilder makeEncodings: () -> [VizEncode]) {
        markDef = ErrorBandDef(type: errorBand)
    }
}

struct VizEncode {

    init(_ encodeType: EncodingChannel, field: FieldName) {
    }
}

extension VizEncode {
    func measure(_ measureType: StandardMeasureType) -> Self {
        self
    }
}

extension Equatable {
    /// Fluent-style API for setting a value on a reference type and returning the type
    /// - Parameter keyPath: the path to assign
    /// - Parameter value: the value to set
    func setting<T>(path keyPath: WritableKeyPath<Self, T>, to value: T) -> Self {
        var this = self
        this[keyPath: keyPath] = value
        return this
    }
}

//protocol VizMark {
//    static var markType: MarkType { get }
//}

//struct BarMark : VizMark {
//    static let markType: MarkType = .bar
//}
//
//struct TextMark : VizMark {
//    static let markType: MarkType = .text
//}
//
//protocol VizChannel {
//    static var channelType: EncodingChannel { get }
//}


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
typealias VizEncodeArrayBuilder = VizArrayBuilder<VizEncode>

@resultBuilder
enum VizMarkArrayBuilderOLD {
    static func buildEither(first component: [VizMarkType]) -> [VizMarkType] {
        return component
    }

    static func buildEither(second component: [VizMarkType]) -> [VizMarkType] {
        return component
    }

    static func buildOptional(_ component: [VizMarkType]?) -> [VizMarkType] {
        return component ?? []
    }

    static func buildBlock(_ components: [VizMarkType]...) -> [VizMarkType] {
        return components.flatMap { $0 }
    }

    static func buildExpression(_ expression: VizMarkType) -> [VizMarkType] {
        return [expression]
    }

    static func buildExpression(_ expression: Void) -> [VizMarkType] {
        return []
    }

//    @available(*, unavailable, message: "first statement of builder be an element")
//    static func buildBlock(_ components: VizChannel...) -> [VizChannel] {
//      fatalError()
//    }
}

typealias SimpleViz = Viz<Bric.ObjType>

@dynamicMemberLookup
struct Viz<M: VizSpecMeta> : Equatable {
    var spec: VizSpec<M>

    init(spec: VizSpec<M> = VizSpec(), @VizMarkArrayBuilder _ makeMarks: () -> [VizMarkType]) {
        self.spec = spec

        let marks = makeMarks()
        if marks.count == 0 {

        } else if marks.count == 1 {
            for mark in marks {
                self.spec.mark = mark.anyMark
            }
        } else {
            for mark in marks {
                self.spec.sublayers.append(VizSpec(mark: mark.anyMark))
            }
        }
    }
}

extension Viz {
    /// Creates a setter function for the given dynamic keypath
    public subscript<U>(dynamicMember keyPath: WritableKeyPath<VizSpec<M>, U>) -> (U) -> (Self) {
        get {
            { newValue in
                var spec = self.spec
                spec[keyPath: keyPath] = newValue
                return Viz(spec: spec) { }
            }
        }
    }

}

extension VizMark {
    /// Creates a setter function for the given dynamic keypath
    public subscript<U>(dynamicMember keyPath: WritableKeyPath<Def, U>) -> (U) -> (Self) {
        get {
            { newValue in
                var def = self.markDef
                def[keyPath: keyPath] = newValue
                return VizMark(markDef: def)
            }
        }
    }

}
