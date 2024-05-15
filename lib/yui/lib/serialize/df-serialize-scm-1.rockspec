rockspec_format = "3.0"
package = "df-serialize"
version = "scm-1"
source = {
    url = "git+https://git.doublefourteen.io/lua/df-serialize.git"
}
description = {
    summary = "A brainless Lua table serialization library",
    homepage = "https://git.doublefourteen.io/lua/df-serialize",
    maintainer = "The DoubleFourteen Code Forge <info@doublefourteen.io>",
    license = "zlib",
    labels = { "serialization", "debug", "love" }
}
dependencies = {
    "lua >= 5.2"
}
test_dependencies = {
    "busted"
}
build = {
    type = "builtin",
    modules = {
        ["df-serialize"] = "init.lua"
    }
}
test = {
    type = "busted"
}
