Playground for instrumenting `scalac` using AspectJ.
====================================================

Examples
--------

### Tracing where Symbols get created (`TraceSymbol.aj`)

This example implements the functionality @JamesIry tried to implement
in scalac directly: https://github.com/scala/scala/pull/1756

To see it in action run

    ./scalac-aspects TraceSymbol.aj -DtraceSymbolIds=500,505 Foo.scala

### Per-file timings (`PerUnitTiming.aj`)

This example shows how to bring back `-Dscala.timings`. See this discussion:
https://groups.google.com/d/topic/scala-internals/ZCToaWda7tQ/discussion

To see it in action run

    ./scalac-aspects PerUnitTiming.aj Foo.scala

### Type completion timings (`TypeCompletionTiming.aj`)

This example shows how to measure how much time is spent on calculating given
type. The cool thing about it is that it also shows position in a file where
given type is referred.

Too see it in action run

    ./scalac-aspects TypeCompletionTiming.aj Foo.scala

The cool thing is that scalac options work as expected. Try:

    ./scalac-aspects TypeCompletionTiming.aj -Yshow-symkinds Foo.scala

### Typing timings (`TypingTimings.aj`)

The `TypingTimings.aj` has strictly more functionality (it collects more information)
than the `TypeCompletionTiming.aj` but it's not an example of the best code.

I include it because it's powerful enough to discover real problem with compilation times.
I used it for compiling Scala library and I discovered that some types take 0.25s to compute.
If you are wondering, that'ts _a lot_.

Too see it in action run

    ./scalac-aspects TypingTimings.aj Foo.scala

Also, check out the little tool I created for post-processing data printed by this tool:

https://gist.github.com/4543164

Maven support
-------------

François Armand ([@fanf](http://github.com/fanf)) has a blog
[post](http://blog.normation.com/en/2013/01/29/per-file-compilation-time-in-a-scala-maven-project/)
showing how to use aspects mentioned above with Maven projects.
