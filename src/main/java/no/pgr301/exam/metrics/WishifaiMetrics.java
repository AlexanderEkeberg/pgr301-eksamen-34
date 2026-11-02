package no.pgr301.exam.metrics;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;
import io.micrometer.core.instrument.DistributionSummary;
import org.springframework.stereotype.Component;

import java.util.function.Supplier;


@Component
public class WishifaiMetrics {

    private final Timer rekognitionTimer;
    private final Timer bedrockTimer;
    private final DistributionSummary giftSuggestionsPerRequest;
    private final Counter bedrockParseFailures;

    public WishifaiMetrics(MeterRegistry meterRegistry) {
        this.rekognitionTimer = Timer.builder("rekognition_duration")
                .description("Tid brukt på Rekognition-kallet")
                .register(meterRegistry);

        this.bedrockTimer = Timer.builder("bedrock_duration")
                .description("Tid brukt på Bedrock-kallet")
                .register(meterRegistry);

        this.giftSuggestionsPerRequest = DistributionSummary.builder("gift_suggestions_per_request")
                .description("Antall gaveforslag per analysert bilde")
                .register(meterRegistry);

        this.bedrockParseFailures = Counter.builder("bedrock_parse_failures")
                .description("Antall Bedrock-svar som ikke kunne leses som JSON")
                .register(meterRegistry);
    }

    public <Response> Response measureRekognition(Supplier<Response> awsCall) {
        return rekognitionTimer.record(awsCall);
    }

    public <Response> Response measureBedrock(Supplier<Response> awsCall) {
        return bedrockTimer.record(awsCall);
    }

    public void recordAnalysis(int suggestionCount) {
        giftSuggestionsPerRequest.record(suggestionCount);
    }

    public void recordParseFailure() {
        bedrockParseFailures.increment();
    }
}