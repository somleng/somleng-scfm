// Entry point for the build script in your package.json
import * as bootstrap from "bootstrap"

import jquery from 'jquery'
window.jQuery = jquery
window.$ = jquery

require("@nathanvda/cocoon")
