import scala.tools.nsc.CompilationUnits.CompilationUnit;
import java.util.Map;
import scala.tools.nsc.Global;
import scala.tools.nsc.Global.GlobalPhase;
import scala.reflect.internal.Phase;
import java.io.StringWriter;
import java.io.PrintWriter;

aspect PerUnitTiming {

  private Map<CompilationUnit, Map<Phase, Long>> timings = new java.util.HashMap<CompilationUnit, Map<Phase, Long>>();

  void around(CompilationUnit unit, Phase phase): call(void GlobalPhase.applyPhase(..)) && args(unit) && target(phase) {
    Map<Phase, Long> perPhase = timings.get(unit);
    if (perPhase == null) {
      perPhase = new java.util.HashMap<Phase, Long>();
      timings.put(unit, perPhase);
    }
    long start = System.nanoTime();
    try {
      proceed(unit, phase);
    } finally {
      long elapsed = System.nanoTime()-start;
      Long previous = perPhase.get(phase);
      if (previous == null)
        perPhase.put(phase, elapsed);
      else
        perPhase.put(phase, previous+elapsed);
    }
  }

  after(Phase firstPhase): execution(private void Global.Run.compileUnitsInternal(..)) && args(.., firstPhase) {
    // extract all phases
    java.util.List<Phase> phases = new java.util.ArrayList<Phase>();
    { 
      Phase curPhase = firstPhase;
      do {
        phases.add(curPhase);
        curPhase = curPhase.next();
      } while (curPhase.hasNext());
    }
    System.out.println("Per-file timings (all times are in micro seconds)");
    for (Map.Entry<CompilationUnit, Map<Phase, Long>> perUnitEntry : timings.entrySet()) {
      // we are using writer as a buffer so the whole line is printed at once
      StringWriter phaseWriter = new StringWriter();
      PrintWriter printPhaseWriter = new PrintWriter(phaseWriter);
      CompilationUnit unit = perUnitEntry.getKey();
      Map<Phase, Long> perPhase = perUnitEntry.getValue();
      long totalMicros = 0;
      for (Phase phase : phases) {
        // this check is needed because for some phases (like jvm) we do not capture
        // the timing information
        if (perPhase.containsKey(phase)) {
          long micros = perPhase.get(phase) / 1000;
          totalMicros += micros;
          printPhaseWriter.printf("\t%-25s %d\n", phase.name(), micros);
        }
      }
      printPhaseWriter.close();
      String header = unit.source().path() + " " + totalMicros + "\n";
      System.out.println(header + phaseWriter.toString());
    }
  }

}
