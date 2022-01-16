import com.espertech.esper.common.client.EPCompiled;
import com.espertech.esper.common.client.configuration.Configuration;
import com.espertech.esper.compiler.client.CompilerArguments;
import com.espertech.esper.compiler.client.EPCompileException;
import com.espertech.esper.compiler.client.EPCompilerProvider;
import com.espertech.esper.runtime.client.*;

import java.io.IOException;

public class Main {
    public static void main(String[] args) throws IOException {
        Configuration configuration = new Configuration();
        configuration.getCommon().addEventType(KursAkcji.class);
        EPRuntime epRuntime = EPRuntimeProvider.getDefaultRuntime(configuration);

        // 23.
//        EPDeployment deployment = compileAndDeploy(
//                epRuntime,
//                "select irstream spolka as X, kursOtwarcia as Y " +
//                        "from KursAkcji.win:length(3)"
//        );

        // 24. Dlaczego w odróżnieniu od poprzedniego przypadku bezpośrednio po pierwszym zdarzeniu w strumieniu zdarzeń wstawianych pojawiły zdarzenia w strumieniu zdarzeń usuwanych?
        // Ze względu na selektywność, kolejne dane dotyczace oracle znajduja sie w kolejnym oknie, przez co dane z poprzedniego okna są natychmiast usuwane.
        // Filtrowanie odbywa się po otrzymaniu 3 danych z okna
//        EPDeployment deployment = compileAndDeploy(
//                epRuntime,
//                "select irstream spolka as X, kursOtwarcia as Y " +
//                        "from KursAkcji.win:length(3) " +
//                        "where spolka='Oracle'"
//        );

        // 25.
//        EPDeployment deployment = compileAndDeploy(
//                epRuntime,
//                "select irstream spolka, kursOtwarcia, data " +
//                        "from KursAkcji.win:length(3) " +
//                        "where spolka='Oracle'"
//        );

        // 26.
//        EPDeployment deployment = compileAndDeploy(
//                epRuntime,
//                "select irstream spolka, kursOtwarcia, data " +
//                        "from KursAkcji(spolka='Oracle').win:length(3) "
//        );

        // 27.
//        EPDeployment deployment = compileAndDeploy(
//                epRuntime,
//                "select istream spolka, kursOtwarcia, data " +
//                        "from KursAkcji(spolka='Oracle').win:length(3) "
//        );

        // 28.
//        EPDeployment deployment = compileAndDeploy(
//                epRuntime,
//                "select istream spolka, max(kursOtwarcia), data " +
//                        "from KursAkcji(spolka='Oracle').win:length(5) "
//        );

        // 29.
        // Max wyciaga najwieksza wartość danego parametru z danych z okna
        // Jest to niejako grupowanie danych na podstawie okien a nie na podstawie kolumny jak w SQL
//        EPDeployment deployment = compileAndDeploy(
//                epRuntime,
//                "select istream spolka, kursOtwarcia-max(kursOtwarcia) as roznica, data " +
//                        "from KursAkcji(spolka='Oracle').win:length(5) "
//        );

        // 30.
        EPDeployment deployment = compileAndDeploy(
                epRuntime,
                "select istream spolka, kursOtwarcia - prev(1, kursOtwarcia) as roznica, data " +
                        "from KursAkcji(spolka='Oracle').win:length(5) " +
                        "having kursOtwarcia > prev(1, kursOtwarcia)"
        );

        ProstyListener prostyListener = new ProstyListener();

        for (EPStatement statement: deployment.getStatements()) {
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
