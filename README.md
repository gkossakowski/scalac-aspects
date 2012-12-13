Playground for instrumenting `scalac` using AspectJ.
====================================================

Examples
--------

### Tracing where Symbols get created (`TraceSymbol.aj`)

This example implements the functionality @JamesIry tried to implement
in scalac directly: https://github.com/scala/scala/pull/1756

To see it in action run

    ./scalac-aspects TraceSymbol.aj -DtraceSymbolIds=500,505 Foo.scala
