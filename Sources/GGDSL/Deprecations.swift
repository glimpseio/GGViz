import GGSpec

/// The old alias for `FacetedEncoding` aliases to `EncodingChannelMap`
@available(*, deprecated, renamed: "EncodingChannelMap")
public typealias FacetedEncoding = EncodingChannelMap

public extension EncodingChannelMap {
    @available(*, deprecated, renamed: "AngleEncoding")
    typealias EncodingAngle = AngleEncoding
    @available(*, deprecated, renamed: "ColorEncoding")
    typealias EncodingColor = ColorEncoding
    @available(*, deprecated, renamed: "ColumnEncoding")
    typealias EncodingColumn = ColumnEncoding
    @available(*, deprecated, renamed: "DescriptionEncoding")
    typealias EncodingDescription = DescriptionEncoding
    @available(*, deprecated, renamed: "DetailEncoding")
    typealias EncodingDetail = DetailEncoding
    @available(*, deprecated, renamed: "FacetEncoding")
    typealias EncodingFacet = FacetEncoding
    @available(*, deprecated, renamed: "FillEncoding")
    typealias EncodingFill = FillEncoding
    @available(*, deprecated, renamed: "FillOpacityEncoding")
    typealias EncodingFillOpacity = FillOpacityEncoding
    @available(*, deprecated, renamed: "HrefEncoding")
    typealias EncodingHref = HrefEncoding
    @available(*, deprecated, renamed: "KeyEncoding")
    typealias EncodingKey = KeyEncoding
    @available(*, deprecated, renamed: "LatitudeEncoding")
    typealias EncodingLatitude = LatitudeEncoding
    @available(*, deprecated, renamed: "Latitude2Encoding")
    typealias EncodingLatitude2 = Latitude2Encoding
    @available(*, deprecated, renamed: "LongitudeEncoding")
    typealias EncodingLongitude = LongitudeEncoding
    @available(*, deprecated, renamed: "Longitude2Encoding")
    typealias EncodingLongitude2 = Longitude2Encoding
    @available(*, deprecated, renamed: "OpacityEncoding")
    typealias EncodingOpacity = OpacityEncoding
    @available(*, deprecated, renamed: "OrderEncoding")
    typealias EncodingOrder = OrderEncoding
    @available(*, deprecated, renamed: "RadiusEncoding")
    typealias EncodingRadius = RadiusEncoding
    @available(*, deprecated, renamed: "Radius2Encoding")
    typealias EncodingRadius2 = Radius2Encoding
    @available(*, deprecated, renamed: "RowEncoding")
    typealias EncodingRow = RowEncoding
    @available(*, deprecated, renamed: "ShapeEncoding")
    typealias EncodingShape = ShapeEncoding
    @available(*, deprecated, renamed: "SizeEncoding")
    typealias EncodingSize = SizeEncoding
    @available(*, deprecated, renamed: "StrokeEncoding")
    typealias EncodingStroke = StrokeEncoding
    @available(*, deprecated, renamed: "StrokeDashEncoding")
    typealias EncodingStrokeDash = StrokeDashEncoding
    @available(*, deprecated, renamed: "StrokeOpacityEncoding")
    typealias EncodingStrokeOpacity = StrokeOpacityEncoding
    @available(*, deprecated, renamed: "StrokeWidthEncoding")
    typealias EncodingStrokeWidth = StrokeWidthEncoding
    @available(*, deprecated, renamed: "TextEncoding")
    typealias EncodingText = TextEncoding
    @available(*, deprecated, renamed: "ThetaEncoding")
    typealias EncodingTheta = ThetaEncoding
    @available(*, deprecated, renamed: "Theta2Encoding")
    typealias EncodingTheta2 = Theta2Encoding
    @available(*, deprecated, renamed: "TooltipEncoding")
    typealias EncodingTooltip = TooltipEncoding
    @available(*, deprecated, renamed: "UrlEncoding")
    typealias EncodingUrl = UrlEncoding
    @available(*, deprecated, renamed: "XEncoding")
    typealias EncodingX = XEncoding
    @available(*, deprecated, renamed: "X2Encoding")
    typealias EncodingX2 = X2Encoding
    @available(*, deprecated, renamed: "XErrorEncoding")
    typealias EncodingXError = XErrorEncoding
    @available(*, deprecated, renamed: "XError2Encoding")
    typealias EncodingXError2 = XError2Encoding
    @available(*, deprecated, renamed: "YEncoding")
    typealias EncodingY = YEncoding
    @available(*, deprecated, renamed: "Y2Encoding")
    typealias EncodingY2 = Y2Encoding
    @available(*, deprecated, renamed: "YErrorEncoding")
    typealias EncodingYError = YErrorEncoding
    @available(*, deprecated, renamed: "YError2Encoding")
    typealias EncodingYError2 = YError2Encoding
}

/// The old alias for `Field` aliases to `SourceColumnRef`
@available(*, deprecated, renamed: "SourceColumnRef")
public typealias Field = SourceColumnRef

/// The old alias for `Transform`
@available(*, deprecated, renamed: "DataTransformation")
public typealias Transform = DataTransformation

/// The old alias for the `Config`
@available(*, deprecated, renamed: "ConfigTheme")
public typealias Config = ConfigTheme

/// The old alias for the PrimitiveMarkType
@available(*, deprecated, renamed: "PrimitiveMarkType")
public typealias Mark = PrimitiveMarkType

/// The old alias for the AxisDef
@available(*, deprecated, renamed: "AxisDef")
public typealias Axis = AxisDef

/// The old alias for the LegendDef
@available(*, deprecated, renamed: "LegendDef")
public typealias Legend = LegendDef

/// The old alias for the HeaderDef
@available(*, deprecated, renamed: "HeaderDef")
public typealias Header = HeaderDef

/// The old alias for the ScaleDef
@available(*, deprecated, renamed: "ScaleDef")
public typealias Scale = ScaleDef

/// The old alias for the TemporalUnit
@available(*, deprecated, renamed: "TemporalUnit")
public typealias Duration = TemporalUnit

/// The old alias for the ColorLiteral
@available(*, deprecated, renamed: "ColorLiteral")
public typealias ColorCode = ColorLiteral

@available(*, deprecated, renamed: "BoxPlotLiteral")
public typealias BoxPlot = BoxPlotLiteral

@available(*, deprecated, renamed: "ErrorBarLiteral")
public typealias ErrorBar = ErrorBarLiteral

@available(*, deprecated, renamed: "ErrorBandLiteral")
public typealias ErrorBand = ErrorBandLiteral

public extension LayerArrangement {
    @available(*, deprecated, renamed: "horizontal")
    static let hconcat = Self.horizontal
    @available(*, deprecated, renamed: "vertical")
    static let vconcat = Self.vertical
    @available(*, deprecated, renamed: "wrap")
    static let concat = Self.wrap
    @available(*, deprecated, renamed: "overlay")
    static let `repeat` = Self.overlay
}

