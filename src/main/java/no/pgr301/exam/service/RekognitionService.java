package no.pgr301.exam.service;

import org.springframework.stereotype.Service;
import software.amazon.awssdk.core.SdkBytes;
import software.amazon.awssdk.services.rekognition.RekognitionClient;
import software.amazon.awssdk.services.rekognition.model.DetectLabelsRequest;
import software.amazon.awssdk.services.rekognition.model.DetectLabelsResponse;
import software.amazon.awssdk.services.rekognition.model.Image;
import software.amazon.awssdk.services.rekognition.model.Label;
import no.pgr301.exam.metrics.WishifaiMetrics;

import java.util.List;

@Service
public class RekognitionService {

    private final RekognitionClient client;
    private final WishifaiMetrics metrics;


    public RekognitionService(RekognitionClient client, WishifaiMetrics metrics) {
        this.client = client;
        this.metrics = metrics;
    }

    public List<String> detectLabels(byte[] bytes) {
        DetectLabelsResponse resp = metrics.measureRekognition(() -> client.detectLabels(DetectLabelsRequest.builder()
                .image(Image.builder().bytes(SdkBytes.fromByteArray(bytes)).build())
                .maxLabels(20)
                .minConfidence(70f)
                .build()));

        return resp.labels().stream().map(Label::name).toList();
    }
}
