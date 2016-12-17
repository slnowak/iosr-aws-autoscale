package pl.edu.agh.aws.autoscale;

import com.fasterxml.jackson.annotation.JsonAutoDetect;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigInteger;
import java.security.SecureRandom;
import java.util.Collection;
import java.util.stream.Collectors;
import java.util.stream.Stream;

@RestController
public class RandomDataController {

    @RequestMapping(value = "/random", method = RequestMethod.GET)
    public Collection<SomeRandomData> generateRandomData() {
        return randomlyGeneratedDataOfSize(150_000);
    }

    private Collection<SomeRandomData> randomlyGeneratedDataOfSize(int n) {
        return Stream
                .generate(this::randomSample)
                .limit(n)
                .collect(Collectors.toList());
    }

    private SomeRandomData randomSample() {
        return new SomeRandomData(
                randomStringOfSize(256),
                randomStringOfSize(256)
        );
    }

    private String randomStringOfSize(int n) {
        final SecureRandom random = new SecureRandom();
        return new BigInteger(n, random).toString(32);
    }


    @JsonAutoDetect()
    static class SomeRandomData {
        private final String valueA;
        private final String valueB;

        SomeRandomData(String valueA, String valueB) {
            this.valueA = valueA;
            this.valueB = valueB;
        }

        public String getValueA() {
            return valueA;
        }

        public String getValueB() {
            return valueB;
        }
    }
}
