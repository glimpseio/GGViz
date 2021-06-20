import GGSpec

public protocol SpecType : Codable {
    var name: String? { get set }
    var description: String? { get set }
//    var title: OneOf2<String, TitleParams>? { get set }
    /// The list of transforms applied to this layer's data
    var transform: [DataTransformation]? { get set }
}


public protocol TopLevelSpecType : SpecType {
    var schema: String? { get set }
    var config: ConfigTheme? { get set }
    //var usermeta: Dict? { get set }
}

/// A `ColorCode` or an `ExprRef`
public typealias ColorExprable = Exprable<ColorLiteral>

/// The different options for a `Param` definition
public typealias ParamChoice = OneOf<VariableParameter>.Or<TopLevelSelectionParameter> // ConfigTheme.ParamsItemChoice

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
    public var transform: [DataTransformation]?

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
    public var config: ConfigTheme? {
        get { _config?.wrappedValue }
        _modify {
            var cfg = _config?.wrappedValue
            yield &cfg
            _config = cfg.indirect()
        }
    }

    /// Storing `Config` as an indirect reduces the potential memory layout size, but more importantly, it seems to work around a crash on encoding that we were seeing
    private var _config: Indirect<ConfigTheme>?

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
    public var encoding: EncodingChannelMap? {
        get { _encoding?.wrappedValue }
        _modify {
            var cfg = _encoding?.wrappedValue
            yield &cfg
            _encoding = cfg.indirect()
        }
    }

    /// Storing `encoding` as an indirect reduces the potential memory layout size so it can load on background queues (with a 512KB stack limit)
    private var _encoding: Indirect<EncodingChannelMap>?

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

    @usableFromInline var concat: [SubSpec]? // ConcatSpec

    /// Layer or single view specifications to be layered.
    /// __Note__: Specifications inside `layer` cannot use `row` and `column` channels as layering facet specifications is not allowed.
    @usableFromInline var layer: [SubSpec]? // LayerSpec

    /// A list of views that should be concatenated and put into a column.
    @usableFromInline var vconcat: [SubSpec]? // VConcatSpec

    /// A list of views that should be concatenated and put into a row.
    @usableFromInline var hconcat: [SubSpec]? // HConcatSpec


    public init(id: LayerId? = .none, schema: String? = .none, align: AlignChoice? = .none, autosize: AutosizeChoice? = .none, background: ColorExprable? = .none, bounds: LiteralFullOrFlush? = .none, center: CenterChoice? = .none, columns: Double? = .none, config: ConfigTheme? = .none, data: VizDataSource? = .none, datasets: Datasets? = .none, description: String? = .none, encoding: EncodingChannelMap? = .none, height: TopLevelUnitSpec.HeightChoice? = .none, mark: AnyMark? = .none, name: String? = .none, padding: Padding? = .none, projection: Projection? = .none, resolve: Resolve? = .none, spacing: SpacingChoice? = .none, title: TitleChoice? = .none, transform: [DataTransformation]? = .none, params: [ParamChoice]? = .none, usermeta: Meta? = .none, view: ViewBackground? = .none, width: TopLevelUnitSpec.WidthChoice? = .none,
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

