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
//        EPDeployment deployment = compileAndDeploy(
//                epRuntime,
//                "select istream spolka, kursOtwarcia - prev(1, kursOtwarcia) as roznica, data " +
//                        "from KursAkcji(spolka='Oracle').win:length(5) " +
//                        "having kursOtwarcia > prev(1, kursOtwarcia)"
//        );

        ///////////////////////////////////
        /////////// Cwiczenia 2 ///////////
        /////////// Esper – EPL ///////////
        ///////////////////////////////////

        // a. funkcja ta buforuje elementy przez określony okres czasu,
        // dopiero po uzyskaniu wiedzy że mamy już dane z 17.09 mogliśmy stwierdzić,
        // że minął tydzień  - zakończyło się okno
        // This window view buffers events (tumbling window)
        // and releases them every specified time interval in one update.

//        EPDeployment deployment = compileAndDeploy(
//                epRuntime,
//                "select irstream data, kursZamkniecia, max(kursZamkniecia) " +
//                        "from KursAkcji(spolka = 'Oracle').win:ext_timed(data.getTime(), 7 days)"
//        );

        // b. Brak istream 19, 20:
        // Funkcja ta czeka na zakończenie okien - otrzymanie informacji o dniu 11, 18, 25 (lub później)
        // Uzyskanie danych z 18.09 zamyka okno 11-18
        // i przekazuje dane ISTREAM z aktualnego okna, a na RSTREAM z poprzedniego (5-11).
        // Brak wiedzy o upływie kolejnego tygodnia (25.09)
        // uniemożliwia zamknięcie aktualnego okna i przekazanie brakujących danych na wyjście

//        EPDeployment deployment = compileAndDeploy(
//                epRuntime,
//                "select irstream data, kursZamkniecia, max(kursZamkniecia) " +
//                        "from KursAkcji(spolka = 'Oracle').win:ext_timed_batch(data.getTime(), 7 days)"
//        );

        // 5.
//        EPDeployment deployment = compileAndDeploy(
//                epRuntime,
//                "select istream data, kursZamkniecia, spolka, max(kursZamkniecia) - kursZamkniecia as roznica " +
//                        "from KursAkcji.win:ext_timed_batch(data.getTime(), 1 days)"
//        );

        // 6.
//        EPDeployment deployment = compileAndDeploy(
//                epRuntime,
//                "select istream data, kursZamkniecia, spolka, max(kursZamkniecia) - kursZamkniecia as roznica " +
//                        "from KursAkcji(spolka IN ('IBM', 'Honda', 'Microsoft')).win:ext_timed_batch(data.getTime(), 1 days)"
//        );

        // 7a.
//        EPDeployment deployment = compileAndDeploy(
//                epRuntime,
//                "select istream data, kursZamkniecia, spolka, kursOtwarcia " +
//                        "from KursAkcji(kursOtwarcia < kursZamkniecia).win:ext_timed(data.getTime(), 1 days)"
//        );

        // 7b.
//        EPDeployment deployment = compileAndDeploy(
//                epRuntime,
//                "select istream data, kursZamkniecia, spolka, kursOtwarcia " +
//                        "from KursAkcji(KursAkcji.roznicaKursow(kursOtwarcia, kursZamkniecia)).win:ext_timed(data.getTime(), 1 days)"
//        );

        // 8.
//        EPDeployment deployment = compileAndDeploy(
//                epRuntime,
//                "select istream data, kursZamkniecia, spolka, max(kursZamkniecia)-kursZamkniecia as roznica " +
//                        "from KursAkcji(spolka IN ('PepsiCo', 'CocaCola')).win:ext_timed(data.getTime(), 7 days)"
//        );

        // 9.
//        EPDeployment deployment = compileAndDeploy(
//                epRuntime,
//                "select istream data, kursZamkniecia, spolka " +
//                        "from KursAkcji(spolka IN ('PepsiCo', 'CocaCola')).win:ext_timed_batch(data.getTime(), 1 days) " +
//                        "having kursZamkniecia = max(kursZamkniecia)"
//        );

        // 10.
//        EPDeployment deployment = compileAndDeploy(
//                epRuntime,
//                "select max(kursZamkniecia) as maksimum " +
//                        "from KursAkcji.win:ext_timed_batch(data.getTime(), 7 days) "
//        );

        // 11.
//        EPDeployment deployment = compileAndDeploy(
//                epRuntime,
//                "select p.kursZamkniecia as kursPep, c.kursZamkniecia as kursCoc, p.data " +
//                        "from KursAkcji(spolka='PepsiCo').win:ext_timed(data.getTime(), 1 days) p " +
//                        "join KursAkcji(spolka='CocaCola').win:ext_timed(data.getTime(), 1 days) c " +
//                        "on p.data = c.data " +
//                        "where p.kursZamkniecia > c.kursZamkniecia"
//        );

        // 12.
//        EPDeployment deployment = compileAndDeploy(
//                epRuntime,
//                "select k.spolka, k.data, k.kursZamkniecia as kursBiezacy, k.kursZamkniecia - o.kursZamkniecia as roznica " +
//                        "from KursAkcji(spolka IN ('PepsiCo', 'CocaCola')).win:ext_timed(data.getTime(), 1 days) k " +
//                        "join KursAkcji(data.format('yyyy-MM-dd')='2001-09-05').win:ext_timed(data.getTime(), 1 days) o " +
//                        "on k.spolka = o.spolka"
//        );

        // 13.
//        EPDeployment deployment = compileAndDeploy(
//                epRuntime,
//                "select k.spolka, k.data, k.kursZamkniecia as kursBiezacy, k.kursZamkniecia - o.kursZamkniecia as roznica " +
//                        "from KursAkcji.win:ext_timed(data.getTime(), 1 days) k " +
//                        "join KursAkcji(data.format('yyyy-MM-dd')='2001-09-05').win:ext_timed(data.getTime(), 1 days) o " +
//                        "on k.spolka = o.spolka " +
//                        "where k.kursZamkniecia > o.kursZamkniecia"
//        );

        // 14.
//        EPDeployment deployment = compileAndDeploy(
//                epRuntime,
//                "select istream w.data as dataA, d.data as dataB, w.spolka, w.kursOtwarcia as kursA, d.kursOtwarcia as kursB " +
//                        "from KursAkcji.win:ext_timed(data.getTime(), 1 days) d " +
//                        "join KursAkcji.win:ext_timed(data.getTime(), 7 days) w " +
//                        "on w.spolka = d.spolka " +
//                        "where w.kursOtwarcia - d.kursOtwarcia > 3 or w.kursOtwarcia - d.kursOtwarcia < -3"
//
//        );

        // 15.
//        EPDeployment deployment = compileAndDeploy(
//                epRuntime,
//                "select spolka, data, obrot " +
//                        "from KursAkcji(market='NYSE').win:ext_timed_batch(data.getTime(), 7 days) " +
//                        "order by obrot desc " +
//                        "limit 3"
//        );
//
        // 16.
        EPDeployment deployment = compileAndDeploy(
                epRuntime,
                "select spolka, data, obrot " +
                        "from KursAkcji(market='NYSE').win:ext_timed_batch(data.getTime(), 7 days) " +
                        "order by obrot desc " +
                        "limit 1 offset 2"
        );

        ProstyListener prostyListener = new ProstyListener();

        for (EPStatement statement : deployment.getStatements()) {
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
