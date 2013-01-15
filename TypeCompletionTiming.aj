import scala.reflect.internal.Types.LazyType;
import scala.reflect.internal.Types.Type;
import scala.reflect.internal.Symbols.Symbol;
import java.util.Map;
import java.util.IdentityHashMap;
import scala.tools.nsc.Global;
import scala.tools.nsc.reporters.Reporter;
import java.util.List;
import java.util.ArrayList;
import scala.reflect.api.Position;

/** 
 * Collects information about how much time has been spent calculating given type.
 * We do this by intercepting calls to LazyType.complete(..) method.
 *
 * All times are reported in microseconds.
 *
 * NOTE: The goal here wasn't to create very sophisticated profiling tool for
 * type-checker but measure specifically how much time is spent in calculating types.
 * The other goal was to keep code small enough so it fits one (large) screen.
 */
aspect TypeCompletionTiming {
  public static class Trace {
    public final Symbol sym;
    public final long startTime;
    public final long duration;
    // Class instance representing a particular class inheriting from LazyType that
    // generated the trace
    public final Class lazyTpe;
    public Trace(Symbol sym, long startTime, long duration, Class lazyTpe) {
      this.sym = sym;
      this.startTime = startTime;
      this.duration = duration;
      this.lazyTpe = lazyTpe;
    }
  }

  public final long globalStartTime = System.nanoTime();
  public List<Trace> traces = new java.util.ArrayList<Trace>();

  /** IdentityHashMap (that is used as IdentityHashSet) that allows us to detect recursive
    * calls to LazyType.complete(..) and avoid double bookkeeping. */
  private Map<LazyType, Object> currentlyCompleted = new IdentityHashMap<LazyType, Object>();

  void around(LazyType lazyTpe, Symbol sym): call(void Type.complete(..)) && 
    target(lazyTpe) && args(sym) {
    if (!currentlyCompleted.containsKey(lazyTpe)) {
      Class lazyTpeClass = lazyTpe.getClass();
      currentlyCompleted.put(lazyTpe, null);
      long start = System.nanoTime();
      try {
        proceed(lazyTpe, sym);
      } finally {
        long duration = System.nanoTime()-start;
        Trace trace = new Trace(sym, start, duration, lazyTpeClass);
        traces.add(trace);
        currentlyCompleted.remove(lazyTpe);
      }
    } else {
      proceed(lazyTpe, sym);
    }
  }

  after(Global.Run run): execution(private void scala.tools.nsc.Global.Run.compileUnitsInternal(..)) && this(run) {
    Global global = run.$outer;
    Reporter reporter = global.reporter();
    StringBuilder buf = new StringBuilder();
    buf.append(String.format("Per-symbol lazy type completion timings (time-stamps in micro seconds normalized against globalStartTime), globalStartTime = %d", globalStartTime));
    buf.append("\n");
    for (Trace trace : traces) {
      long durationMicro = trace.duration / 1000;
      long startTimeMicro = (trace.startTime-globalStartTime) / 1000;
      final Position pos = trace.sym.pos();
      final String lazyTpeName = trace.lazyTpe.getSimpleName();
      // startTime has 10 characters reserved, which gives us max compilation running time 10^-6*10^10 = 10^4 seconds ~ 166 minutes
      // duration has 8 characters reserved, which gives us max duration of type completion to be 10^-6*10^8 = 10^2 seconds
      buf.append(String.format("%10d\t%8d\t%-16s\t%-80s\t%s\t", startTimeMicro, durationMicro, lazyTpeName,
        trace.sym.fullNameString(), pos.toString()));
      buf.append("\n");
    }
    reporter.echo(buf.toString());
  }

}
