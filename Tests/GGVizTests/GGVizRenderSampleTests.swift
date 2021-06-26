import GGViz
import Judo
import GGSamples
import GGSources
import XCTest

#if canImport(CoreGraphics)
/// Attempts to render all of the viz samples
final class GGVizRenderSampleTests: XCTestCase {

    static let sharedEngine = Result { try VizEngine() }

    func render(sample: GGSample, verifySVG: Bool = true) throws {
        guard let url = sample.resourceURL else {
            throw XCTSkip("missing resource for: \(sample)")
        }

        let spec = try SimpleVizSpec.loadJSON(url: url)
        //let layer = try LayerCanvas(size: CGSize(width: 800, height: 400))
        let layer = try PDFCanvas(size: CGSize(width: 800, height: 400))

        // changing background color helps identify when tests have changes the output
        //layer.backgroundColor = wip(NSColor(hue: CGFloat.random(in: 0...1), saturation: 0.3, brightness: 0.7, alpha: 1.0).cgColor)

        let _ = try Self.sharedEngine.get().renderViz(spec: spec, canvas: layer)
        //let png = layer.createPNGData()
        let pdf = layer.finishPDF()
        if verifySVG {
            let dir = URL(fileURLWithPath: "GGVizRenderSampleTests", relativeTo: URL(fileURLWithPath: NSTemporaryDirectory()))
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)

            let outputBase = dir.appendingPathComponent(sample.rawValue)

            let pdfOutput = outputBase.appendingPathExtension("pdf")

            dbg("rendered sample \(sample) with pdf size:", pdf.count, "to:", pdfOutput.path)
            try pdf.write(to: pdfOutput)

            let rendered = try Self.sharedEngine.get().renderViz(spec: spec, returnSVG: true)

            // also save the SVG next to the PDF so we can compare the rendered results
            let svgOutput = outputBase.appendingPathExtension("svg")
            if let svg = rendered[VizEngine.RenderResponseKey.svg.rawValue].stringValue {
                try svg.write(to: svgOutput, atomically: false, encoding: .utf8)

                guard let referenceSVG = Bundle.module.url(forResource: svgOutput.lastPathComponent, withExtension: nil, subdirectory: "TestResources/SVG/") else {
                    throw XCTSkip("no reference svg for \(sample)")
                }

                let refSVG = (try? String(contentsOf: referenceSVG)) ?? ""

                // check for samples that we know have inconsistent renderings (possibly due to a random, locale, or temporal input); all other samples should be identical to the rendered output
                switch sample {
                case .area_horizon,
                        .rect_heatmap,
                        .selection_translate_scatterplot_drag,
                        .geo_choropleth,
                        .joinaggregate_residual_graph,
                        .interactive_splom,
                        .interactive_area_brush,
                        .interactive_layered_crossfilter,
                        .geo_repeat,
                        .selection_heatmap,
                        .rect_heatmap_weather,
                        .interactive_brush,
                        .geo_trellis,
                        .brush_table,
                        .isotype_grid,
                        .joinaggregate_mean_difference_by_year,
                        .concat_marginal_histograms,
                        .interactive_bin_extent,
                        .layer_bar_fruit,
                        .interactive_overview_detail,
                        .interactive_seattle_weather,
                        .interactive_concat_layer,
                        .rect_lasagna,
                        .rect_binned_heatmap,
                        .circle_bubble_health_income,
                        .layer_text_heatmap,
                        .selection_layer_bar_month,
                        .bar_count_minimap,
                        .trail_comet:
                    break
                default:
                    XCTAssertTrue(svg == refSVG, "SVG mismatch for \(sample): \(svg.count) vs \(refSVG.count); manually resolve by copying \(svgOutput.path) \(referenceSVG.path)")
                }
            }

        }
    }
    
    func test_bar() throws {
        try render(sample: .bar)
    }

    func test_arc_donut() throws {
        try render(sample: .arc_donut)
    }

    func test_arc_pie() throws {
        try render(sample: .arc_pie)
    }

    func test_arc_pie_pyramid() throws {
        try render(sample: .arc_pie_pyramid)
    }

    func test_arc_radial() throws {
        try render(sample: .arc_radial)
    }

    func test_area() throws {
        try render(sample: .area)
    }

    func test_area_cumulative_freq() throws {
        try render(sample: .area_cumulative_freq)
    }

    func test_area_density() throws {
        try render(sample: .area_density)
    }

    func test_area_density_facet() throws {
        try render(sample: .area_density_facet)
    }

    func test_area_density_stacked() throws {
        try render(sample: .area_density_stacked)
    }

    func test_line_monotone() throws {
        try render(sample: .line_monotone)
    }

    func test_layer_line_rolling_mean_point_raw() throws {
        try render(sample: .layer_line_rolling_mean_point_raw)
    }

    func test_line_overlay() throws {
        try render(sample: .line_overlay)
    }

    func test_area_horizon() throws {
        try render(sample: .area_horizon)
    }

    func test_bar_size_responsive() throws {
        try render(sample: .bar_size_responsive)
    }

    func test_line() throws {
        try render(sample: .line)
    }

    func test_line_color() throws {
        try render(sample: .line_color)
    }

    func test_line_strokedash() throws {
        try render(sample: .line_strokedash)
    }

    func test_point_bubble() throws {
        try render(sample: .point_bubble)
    }

    func test_trellis_scatter() throws {
        try render(sample: .trellis_scatter)
    }

    func test_trellis_stacked_bar() throws {
        try render(sample: .trellis_stacked_bar)
    }

    func test_area_overlay() throws {
        try render(sample: .area_overlay)
    }

    func test_tick_dot() throws {
        try render(sample: .tick_dot)
    }

    func test_circle() throws {
        try render(sample: .circle)
    }

    func test_tick_strip() throws {
        try render(sample: .tick_strip)
    }

    func test_point_2d() throws {
        try render(sample: .point_2d)
    }

    func test_stacked_bar_count_corner_radius_mark() throws {
        try render(sample: .stacked_bar_count_corner_radius_mark)
    }

    func test_stacked_bar_h() throws {
        try render(sample: .stacked_bar_h)
    }

    func test_bar_argmax() throws {
        try render(sample: .bar_argmax)
    }

    func test_histogram() throws {
        try render(sample: .histogram)
    }

    func test_histogram_log() throws {
        try render(sample: .histogram_log)
    }

    func test_layer_bar_labels() throws {
        try render(sample: .layer_bar_labels)
    }

    func test_layer_bar_labels_grey() throws {
        try render(sample: .layer_bar_labels_grey)
    }

    func test_layer_histogram_global_mean() throws {
        try render(sample: .layer_histogram_global_mean)
    }

    func test_layer_line_mean_point_raw() throws {
        try render(sample: .layer_line_mean_point_raw)
    }

    func test_line_dashed_part() throws {
        try render(sample: .line_dashed_part)
    }

    func test_layer_point_errorbar_stdev() throws {
        try render(sample: .layer_point_errorbar_stdev)
    }

    func test_layer_point_errorbar_ci() throws {
        try render(sample: .layer_point_errorbar_ci)
    }

    func test_layer_precipitation_mean() throws {
        try render(sample: .layer_precipitation_mean)
    }

    func test_line_skip_invalid_mid_overlay() throws {
        try render(sample: .line_skip_invalid_mid_overlay)
    }

    func test_line_slope() throws {
        try render(sample: .line_slope)
    }

    func test_line_step() throws {
        try render(sample: .line_step)
    }

    func test_lookup() throws {
        try render(sample: .lookup)
    }

    func test_point_href() throws {
        try render(sample: .point_href)
    }

    func test_stacked_area() throws {
        try render(sample: .stacked_area)
    }

    func test_stacked_area_stream() throws {
        try render(sample: .stacked_area_stream)
    }

    func test_point_color_with_shape() throws {
        try render(sample: .point_color_with_shape)
    }

    func test_point_invalid_color() throws {
        try render(sample: .point_invalid_color)
    }

    func test_rect_heatmap() throws {
        try render(sample: .rect_heatmap)
    }

    func test_rect_heatmap_weather() throws {
        try render(sample: .rect_heatmap_weather)
    }

    func test_repeat_layer() throws {
        try render(sample: .repeat_layer)
    }

    func test_scatter_image() throws {
        try render(sample: .scatter_image)
    }

    func test_sequence_line_fold() throws {
        try render(sample: .sequence_line_fold)
    }

    func test_line_overlay_stroked() throws {
        try render(sample: .line_overlay_stroked)
    }

    func test_airport_connections() throws {
        try render(sample: .airport_connections)
    }

    func test_stacked_area_normalize() throws {
        try render(sample: .stacked_area_normalize)
    }

    func test_stacked_bar_normalize() throws {
        try render(sample: .stacked_bar_normalize)
    }

    func test_stacked_bar_weather() throws {
        try render(sample: .stacked_bar_weather)
    }

    func test_text_scatterplot_colored() throws {
        try render(sample: .text_scatterplot_colored)
    }

    func test_trail_color() throws {
        try render(sample: .trail_color)
    }

    func test_trail_comet() throws {
        try render(sample: .trail_comet)
    }

    func test_trellis_anscombe() throws {
        try render(sample: .trellis_anscombe)
    }

    func test_trellis_area() throws {
        try render(sample: .trellis_area)
    }

    func test_trellis_area_seattle() throws {
        try render(sample: .trellis_area_seattle)
    }

    func test_trellis_bar() throws {
        try render(sample: .trellis_bar)
    }

    func test_trellis_bar_histogram() throws {
        try render(sample: .trellis_bar_histogram)
    }

    func test_trellis_barley() throws {
        try render(sample: .trellis_barley)
    }

    func test_vconcat_weather() throws {
        try render(sample: .vconcat_weather)
    }

    func test_interactive_brush() throws {
        try render(sample: .interactive_brush)
    }

    func test_interactive_paintbrush() throws {
        try render(sample: .interactive_paintbrush)
    }

    func test_selection_heatmap() throws {
        try render(sample: .selection_heatmap)
    }

    func test_selection_layer_bar_month() throws {
        try render(sample: .selection_layer_bar_month)
    }

    func test_selection_translate_scatterplot_drag() throws {
        try render(sample: .selection_translate_scatterplot_drag)
    }

    func test_bar_aggregate() throws {
        try render(sample: .bar_aggregate)
    }

    func test_bar_aggregate_sort_by_encoding() throws {
        try render(sample: .bar_aggregate_sort_by_encoding)
    }

    func test_bar_axis_space_saving() throws {
        try render(sample: .bar_axis_space_saving)
    }

    func test_bar_binned_data() throws {
        try render(sample: .bar_binned_data)
    }

    func test_bar_color_disabled_scale() throws {
        try render(sample: .bar_color_disabled_scale)
    }

    func test_bar_count_minimap() throws {
        try render(sample: .bar_count_minimap)
    }

    func test_bar_diverging_stack_population_pyramid() throws {
        try render(sample: .bar_diverging_stack_population_pyramid)
    }

    func test_bar_diverging_stack_transform() throws {
        try render(sample: .bar_diverging_stack_transform)
    }

    func test_bar_gantt() throws {
        try render(sample: .bar_gantt)
    }

    func test_bar_grouped() throws {
        try render(sample: .bar_grouped)
    }

    func test_bar_layered_transparent() throws {
        try render(sample: .bar_layered_transparent)
    }

    func test_bar_layered_weather() throws {
        try render(sample: .bar_layered_weather)
    }

    func test_bar_month_temporal_initial() throws {
        try render(sample: .bar_month_temporal_initial)
    }

    func test_bar_negative() throws {
        try render(sample: .bar_negative)
    }

    func test_bar_negative_horizontal_label() throws {
        try render(sample: .bar_negative_horizontal_label)
    }

    func test_boxplot_2D_vertical() throws {
        try render(sample: .boxplot_2D_vertical)
    }

    func test_boxplot_minmax_2D_vertical() throws {
        try render(sample: .boxplot_minmax_2D_vertical)
    }

    func test_boxplot_preaggregated() throws {
        try render(sample: .boxplot_preaggregated)
    }

    func test_brush_table() throws {
        try render(sample: .brush_table)
    }

    func test_circle_binned() throws {
        try render(sample: .circle_binned)
    }

    func test_circle_bubble_health_income() throws {
        try render(sample: .circle_bubble_health_income)
    }

    func test_circle_custom_tick_labels() throws {
        try render(sample: .circle_custom_tick_labels)
    }

    func test_circle_github_punchcard() throws {
        try render(sample: .circle_github_punchcard)
    }

    func test_circle_natural_disasters() throws {
        try render(sample: .circle_natural_disasters)
    }

    func test_circle_wilkinson_dotplot() throws {
        try render(sample: .circle_wilkinson_dotplot)
    }

    func test_concat_bar_scales_discretize() throws {
        try render(sample: .concat_bar_scales_discretize)
    }

    func test_concat_layer_voyager_result() throws {
        try render(sample: .concat_layer_voyager_result)
    }

    func test_concat_marginal_histograms() throws {
        try render(sample: .concat_marginal_histograms)
    }

    func test_concat_population_pyramid() throws {
        try render(sample: .concat_population_pyramid)
    }

    func test_connected_scatterplot() throws {
        try render(sample: .connected_scatterplot)
    }

    func test_facet_bullet() throws {
        try render(sample: .facet_bullet)
    }

    func test_facet_grid_bar() throws {
        try render(sample: .facet_grid_bar)
    }

    func test_geo_choropleth() throws {
        try render(sample: .geo_choropleth)
    }

    func test_geo_circle() throws {
        try render(sample: .geo_circle)
    }

    func test_geo_layer() throws {
        try render(sample: .geo_layer)
    }

    func test_geo_layer_line_london() throws {
        try render(sample: .geo_layer_line_london)
    }

    func test_geo_line() throws {
        try render(sample: .geo_line)
    }

    func test_geo_params_projections() throws {
        try render(sample: .geo_params_projections)
    }

    func test_geo_repeat() throws {
        try render(sample: .geo_repeat)
    }

    func test_geo_rule() throws {
        try render(sample: .geo_rule)
    }

    func test_geo_text() throws {
        try render(sample: .geo_text)
    }

    func test_geo_trellis() throws {
        try render(sample: .geo_trellis)
    }

    func test_histogram_rel_freq() throws {
        try render(sample: .histogram_rel_freq)
    }

    func test_interactive_area_brush() throws {
        try render(sample: .interactive_area_brush)
    }

    func test_interactive_bar_select_highlight() throws {
        try render(sample: .interactive_bar_select_highlight)
    }

    func test_interactive_bin_extent() throws {
        try render(sample: .interactive_bin_extent)
    }

    func test_interactive_concat_layer() throws {
        try render(sample: .interactive_concat_layer)
    }

    func test_interactive_global_development() throws {
        try render(sample: .interactive_global_development)
    }

    func test_interactive_index_chart() throws {
        try render(sample: .interactive_index_chart)
    }

    func test_interactive_layered_crossfilter() throws {
        try render(sample: .interactive_layered_crossfilter)
    }

    func test_interactive_legend() throws {
        try render(sample: .interactive_legend)
    }

    func test_interactive_line_hover() throws {
        try render(sample: .interactive_line_hover)
    }

    func test_interactive_multi_line_label() throws {
        try render(sample: .interactive_multi_line_label)
    }

    func test_interactive_multi_line_pivot_tooltip() throws {
        try render(sample: .interactive_multi_line_pivot_tooltip)
    }

    func test_interactive_multi_line_tooltip() throws {
        try render(sample: .interactive_multi_line_tooltip)
    }

    func test_interactive_overview_detail() throws {
        try render(sample: .interactive_overview_detail)
    }

    func test_interactive_query_widgets() throws {
        try render(sample: .interactive_query_widgets)
    }

    func test_interactive_seattle_weather() throws {
        try render(sample: .interactive_seattle_weather)
    }

    func test_interactive_splom() throws {
        try render(sample: .interactive_splom)
    }

    func test_isotype_bar_chart() throws {
        try render(sample: .isotype_bar_chart)
    }

    func test_isotype_bar_chart_emoji() throws {
        try render(sample: .isotype_bar_chart_emoji)
    }

    func test_isotype_grid() throws {
        try render(sample: .isotype_grid)
    }

    func test_joinaggregate_mean_difference() throws {
        try render(sample: .joinaggregate_mean_difference)
    }

    func test_joinaggregate_mean_difference_by_year() throws {
        try render(sample: .joinaggregate_mean_difference_by_year)
    }

    func test_joinaggregate_residual_graph() throws {
        try render(sample: .joinaggregate_residual_graph)
    }

    func test_layer_arc_label() throws {
        try render(sample: .layer_arc_label)
    }

    func test_layer_bar_annotations() throws {
        try render(sample: .layer_bar_annotations)
    }

    func test_layer_bar_fruit() throws {
        try render(sample: .layer_bar_fruit)
    }

    func test_layer_candlestick() throws {
        try render(sample: .layer_candlestick)
    }

    func test_layer_cumulative_histogram() throws {
        try render(sample: .layer_cumulative_histogram)
    }

    func test_layer_dual_axis() throws {
        try render(sample: .layer_dual_axis)
    }

    func test_layer_falkensee() throws {
        try render(sample: .layer_falkensee)
    }

    func test_layer_likert() throws {
        try render(sample: .layer_likert)
    }

    func test_layer_line_co2_concentration() throws {
        try render(sample: .layer_line_co2_concentration)
    }

    func test_layer_line_errorband_ci() throws {
        try render(sample: .layer_line_errorband_ci)
    }

    func test_layer_line_window() throws {
        try render(sample: .layer_line_window)
    }

    func test_layer_point_line_loess() throws {
        try render(sample: .layer_point_line_loess)
    }

    func test_layer_point_line_regression() throws {
        try render(sample: .layer_point_line_regression)
    }

    func test_layer_ranged_dot() throws {
        try render(sample: .layer_ranged_dot)
    }

    func test_layer_scatter_errorband_1D_stdev_global_mean() throws {
        try render(sample: .layer_scatter_errorband_1D_stdev_global_mean)
    }

    func test_layer_text_heatmap() throws {
        try render(sample: .layer_text_heatmap)
    }

    func test_line_bump() throws {
        try render(sample: .line_bump)
    }

    func test_line_color_halo() throws {
        try render(sample: .line_color_halo)
    }

    func test_line_conditional_axis() throws {
        try render(sample: .line_conditional_axis)
    }

    func test_nested_concat_align() throws {
        try render(sample: .nested_concat_align)
    }

    func test_parallel_coordinate() throws {
        try render(sample: .parallel_coordinate)
    }

    func test_point_angle_windvector() throws {
        try render(sample: .point_angle_windvector)
    }

    func test_point_quantile_quantile() throws {
        try render(sample: .point_quantile_quantile)
    }

    func test_rect_binned_heatmap() throws {
        try render(sample: .rect_binned_heatmap)
    }

    func test_rect_lasagna() throws {
        try render(sample: .rect_lasagna)
    }

    func test_rect_mosaic_labelled_with_offset() throws {
        try render(sample: .rect_mosaic_labelled_with_offset)
    }

    func test_waterfall_chart() throws {
        try render(sample: .waterfall_chart)
    }

    func test_wheat_wages() throws {
        try render(sample: .wheat_wages)
    }

    func test_window_percent_of_total() throws {
        try render(sample: .window_percent_of_total)
    }

    func test_window_rank() throws {
        try render(sample: .window_rank)
    }

    func test_window_top_k() throws {
        try render(sample: .window_top_k)
    }

    func test_window_top_k_others() throws {
        try render(sample: .window_top_k_others)
    }

    func test_area_gradient() throws {
        try render(sample: .area_gradient)
    }

    func test_repeat_histogram() throws {
        try render(sample: .repeat_histogram)
    }
}
#endif
