# GGViz

[![Build Status](https://github.com/glimpseio/GGViz/workflows/GGViz%20CI/badge.svg?branch=main)](https://github.com/glimpseio/GGViz/actions)
[![Swift Package Manager compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![Platform](https://img.shields.io/badge/Platforms-macOS%20|%20iOS%20|%20tvOS%20|%20Linux-lightgrey.svg)](https://github.com/glimpseio/GGSpec)
[![](https://tokei.rs/b1/github/glimpseio/GGViz)](https://github.com/glimpseio/GGViz)

Document format and visualization runtime for [GGSpec](https://github.com/glimpseio/GGSpec).

This project contains three sub-projects:

 * GGBundle: A document convention for self-contained data visualizations
 * GGViz: A JXKit-based runtime for rendering data visualizations
 * GGDSL: A Swift DSL for fluently creating data visualizations

# GGDSL

The GGDSL package exposes a native Swift DSL that succinctly describes a layered grammar of graphics inspired by Jacques Bertin's [Sémiologie graphique](https://fr.wikipedia.org/wiki/Sémiologie_graphique), and subsequent implementations: Leland Wilkinson’s [Grammar of Graphics](https://www.springer.com/gp/book/9780387245447), Hadley Wickham's [ggplot2](https://en.wikipedia.org/wiki/Ggplot2), Stanford's [Polaris](http://www.graphics.stanford.edu/projects/polaris/), and the [Vega](https://vega.github.io) projects (which is also used as the runtime for rendering visualizations in the [GGViz] package). 

# GGBundle

The directory structure of a `GGBundle` packages a stand-alone data visualization that can either be read and rendered using a tool, or served directly from the web. 

The format of the file is:

 - viz.json: the visualization specification (vega JSON)
 - data/: a folder that contains the raw data to be rendered
 - fonts/: a folder that can contain WOFF fonts for runtime support
 - index.html (optional): an index page that enables the visualization to be viewed interactively in web browsers
 - ext/: a folder containing runtime extensions and support files
    - ext/ggviz.js (optional): the local copy of the stand-alone visualization runtime








