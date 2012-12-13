Playground for instrumenting `scalac` using AspectJ.
====================================================

Examples
--------

### Tracing where Symbols get created (`TraceSymbol.aj`)

This example implements the functionality @JamesIry tried to implement
in scalac directly: https://github.com/scala/scala/pull/1756

To see it in action run

    ./scalac-aspects TraceSymbol.aj -DtraceSymbolIds=500,505 Foo.scala

### Per-file timings

This example shows how to bring back `-Dscala.timings`. See this discussion:
https://groups.google.com/d/topic/scala-internals/ZCToaWda7tQ/discussion

To see it in action run

    ./scalac-aspects PerUnitTiming.aj Foo.scala
