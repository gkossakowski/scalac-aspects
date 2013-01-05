import scala.tools.nsc.CompilationUnits.CompilationUnit;
import java.util.Map;
import scala.tools.nsc.Global.GlobalPhase;

aspect PerUnitTiming {

  private Map<CompilationUnit, Long> timings = new java.util.HashMap<CompilationUnit, Long>();

  void around(CompilationUnit unit): call(void GlobalPhase.applyPhase(..)) && args(unit) {
    long start = System.nanoTime();
    try {
      proceed(unit);
    } finally {
      long elapsed = System.nanoTime()-start;
      Long previous = timings.get(unit);
      if (previous == null)
        timings.put(unit, elapsed);
      else
        timings.put(unit, previous+elapsed);
    }
  }

  after(): execution(private void scala.tools.nsc.Global.Run.compileUnitsInternal(..)) {
    System.out.println("Per-file timings");
    for (Map.Entry<CompilationUnit, Long> entry : timings.entrySet()) {
      double milis = entry.getValue() / 1000000d;
      CompilationUnit unit = entry.getKey();
      System.out.printf("%s %.3f ms\n", unit.source().path(), milis);
    }
  }

}
