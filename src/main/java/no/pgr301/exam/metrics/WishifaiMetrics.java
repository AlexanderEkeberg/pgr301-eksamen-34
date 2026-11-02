package no.pgr301.exam.metrics;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;
import org.springframework.stereotype.Component;

import java.util.function.Supplier;

@Component
public class WishifaiMetrics {

    private final Timer rekognitionTimer;
    private final Timer bedrockTimer;
    private final Counter imagesAnalyzed;
    private final Counter giftSuggestions;

    public WishifaiMetrics(MeterRegistry meterRegistry) {
        this.rekognitionTimer = Timer.builder("rekognition_duration")
                .description("Tid brukt på Rekognition-kallet")
                .register(meterRegistry);

        this.bedrockTimer = Timer.builder("bedrock_duration")
                .description("Tid brukt på Bedrock-kallet")
                .register(meterRegistry);

        this.imagesAnalyzed = Counter.builder("images_analyzed")
                .description("Antall bilder som er analysert")
                .register(meterRegistry);

        this.giftSuggestions = Counter.builder("gift_suggestions")
                .description("Antall gaveforslag som er generert")
                .register(meterRegistry);
    }

    public <Response> Response measureRekognition(Supplier<Response> awsCall) {
        return rekognitionTimer.record(awsCall);
    }

    public <Response> Response measureBedrock(Supplier<Response> awsCall) {
        return bedrockTimer.record(awsCall);
    }

    public void recordAnalysis(int suggestionCount) {
        imagesAnalyzed.increment();
        giftSuggestions.increment(suggestionCount);
    }
}