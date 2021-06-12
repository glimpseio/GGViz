//
//extension VizSpec {
//    @VizBuilder
//    static func simple() -> Self {
//        VizSpec(title: "Simple Bar Chart") {
//            Mark(.bar) {
//                Channel(.x, from: Field("COL_A"), type: .temporal).axis(false)
//                Channel(.y, from: Field("COL_B"), type: .ordinal)
//                Channel(.fill, from: Field("COL_C"), type: .nominal).legend(true)
//            }
//            .axis(true)
//            .legend(true)
//        }
//    }
//}
//
//@resultBuilder
//enum VizBuilder {
//    static func buildBlock(_ components: <#Component#>...) -> <#Component#> {
//        <#code#>
//    }
//
//}
//
//extension VizSpec {
//    init(title: String? = nil, _ makeChildren: () -> [VizSpec]) {
//        self.init()
//        if let title = title {
//            self.title = .init(.init(title))
//        }
//        for child in makeChildren {
//            self.sub
//        }
//    }
//}
