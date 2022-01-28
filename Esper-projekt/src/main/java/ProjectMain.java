import com.espertech.esper.common.client.EPCompiled;
import com.espertech.esper.common.client.configuration.Configuration;
import com.espertech.esper.compiler.client.CompilerArguments;
import com.espertech.esper.compiler.client.EPCompileException;
import com.espertech.esper.compiler.client.EPCompilerProvider;
import com.espertech.esper.runtime.client.*;

import java.io.IOException;

public class ProjectMain {
    public static void main(String[] args) throws IOException {
        Configuration configuration = new Configuration();
        configuration.getCommon().addEventType(KursAkcji.class);
        EPRuntime epRuntime = EPRuntimeProvider.getDefaultRuntime(configuration);

        EPDeployment deployment = compileAndDeploy(epRuntime,

                // stmt-0
                "create schema KursyLicznik (kursZamkniecia Integer, liczba Integer, blad Integer); " +

                // stmt-1, stmt-2, stmt-3
                    "create const variable int rozmiarOkna = 50; " +
                    "create variable int dzienRoku = 365; " +
                    "create variable int przeszacowanie = 0; " +

                // stmt-4
                    "create window TopWindow.ext:sort(rozmiarOkna, liczba desc) as KursyLicznik; " +

                // stmt-5
                    "on TopWindow " + //((select count(*) from TopWindow)=rozmiarOkna)" +
                        "set przeszacowanie = (select coalesce(min(liczba),0) from TopWindow); " +

                // stmt-6
                    "on KursAkcji as ka " +
                        "merge TopWindow as tw " +
                        "where tw.kursZamkniecia = cast(ka.kursZamkniecia, int) " +
                        "when matched then " +
                            "update set tw.liczba = tw.liczba + 1 " +
                        "when not matched and (select count(*) from TopWindow)=rozmiarOkna then " +
                            "insert into TopWindow(kursZamkniecia, liczba, blad) " +
                                "select cast(ka.kursZamkniecia, int), przeszacowanie+1, przeszacowanie " +
                        "when not matched and (select count(*) from TopWindow)!=rozmiarOkna then " +
                            "insert into TopWindow (kursZamkniecia, liczba, blad) " +
                                "select cast(ka.kursZamkniecia, int), 1, 0;" +

                // stmt-7
                    "on KursAkcji " +
                        "set dzienRoku = KursAkcji.getDayOfYear(data); " +

                // stmt-8
                    "on KursAkcji(KursAkcji.getDayOfYear(data) < dzienRoku) as ka " +
                        "select ka.data, tw.kursZamkniecia, tw.liczba, tw.blad, przeszacowanie from TopWindow as tw limit 1;"
        );

        ProstyListener prostyListener = new ProstyListener();

        for (EPStatement statement : deployment.getStatements()) {
            if ("stmt-8".equals(statement.getName()))
                statement.addListener(prostyListener);
        }

        InputStream inputStream = new InputStream();
        inputStream.generuj(epRuntime.getEventService());
    }

    public static EPDeployment compileAndDeploy(EPRuntime epRuntime, String epl) {
        EPDeploymentService deploymentService = epRuntime.getDeploymentService();

        CompilerArguments args = new CompilerArguments(epRuntime.getConfigurationDeepCopy());
        EPDeployment deployment;
        try {
            EPCompiled epCompiled = EPCompilerProvider.getCompiler().compile(epl, args);
            deployment = deploymentService.deploy(epCompiled);
        } catch (EPCompileException e) {
            throw new RuntimeException(e);
        } catch (EPDeployException e) {
            throw new RuntimeException(e);
        }
        return deployment;
    }
}
