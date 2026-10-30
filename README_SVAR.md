# PGR301 Eksamen 2026 – Kandidat 34

Forklarer hvorfor og hvordan jeg har tenkt når jeg løser oppgavene. 

## Oppgave 1A – Dockerfile

### Kjøre applikasjonen

AWS_ACCESS_KEY_ID og AWS_SECRET_ACCESS_KEY må være satt i terminalen, siden appen bruker S3, Rekognition og Bedrock.

```bash
docker build -t wishifai .
docker run --rm -p 9999:8080 -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_REGION=eu-west-1 wishifai
```

Test:
```bash
curl -F "image=@samples/sample_image.png" http://localhost:9999/api/analyze
```

Dockerfilen bygger JAR-filen med Maven og JDK i første steg, og kopierer bare JAR-filen over til et lite JRE-image, slik at det endelige imaget blir mindre og uten build-verktøy.