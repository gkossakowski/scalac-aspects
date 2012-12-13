import java.util.StringTokenizer;
import scala.reflect.internal.Symbols.Symbol;
import scala.reflect.internal.util.Position;
import scala.reflect.internal.Names.Name;

aspect TraceSymbol {

  private int[] tracedIds;

  public TraceSymbol() {
    String idsStr = System.getProperty("traceSymbolIds", "");
    StringTokenizer tokenizer = new StringTokenizer(idsStr, ",");
    tracedIds = new int[tokenizer.countTokens()];
    System.out.print("Tracing the following Symbol ids: ");
    for (int i = 0; i < tracedIds.length; i++) {
      int id = Integer.parseInt(tokenizer.nextToken());
      tracedIds[i] = id;
      System.out.print(id + " ");
    }
    System.out.println();
  }

  private boolean shouldTrace(scala.reflect.internal.Symbols.Symbol s) {
     int id = s.id();
     for (int i = 0; i < tracedIds.length; i++) {
       if (tracedIds[i] == id)
         return true;
     }
     return false;
  }

  after(Symbol self, Symbol initOwner, Position initPos, Name initName): execution(Symbol.new(..)) && args(*, initOwner, initPos, initName) && this(self) {
    if (shouldTrace(self)) {
      System.out.printf("Created symbol %s#%d with initial owner %s and position %s\n",
        initName, self.id(), initOwner, initPos);
      java.lang.Thread.dumpStack();
    }
  }

}
