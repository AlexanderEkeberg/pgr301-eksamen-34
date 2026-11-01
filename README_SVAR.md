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


## Oppgave 1B – CI-pipeline

Workflow: `.github/workflows/ci.yml`

Grønn kjøring: https://github.com/AlexanderEkeberg/pgr301-eksamen-34/actions/runs/41057448896

ECR-repoet ble opprettet manuelt med:
```bash
aws ecr create-repository --repository-name wishifai-34 --region eu-west-1
```

### Tagging-strategi
Hvert image tagges med commit-SHA-en, slik at man alltid kan se nøyaktig hvilken versjon av koden som kjører, og enkelt rulle tilbake til en tidligere versjon.



## Oppgave 2A – ECS Express med Terraform

Terraform-kode: `infra/`

URL: https://wi-e93f0f7ffdc34ed1b0ae62a2d151e2cf.ecs.eu-west-1.on.aws

Test:
```bash
curl -F "image=@samples/sample_image.png" https://wi-e93f0f7ffdc34ed1b0ae62a2d151e2cf.ecs.eu-west-1.on.aws/api/analyze
```

Tjenesten bruker de eksisterende execution og infrastructure-rollene, og task-rollen wishifai-task-role-34 gir appen tilgang til S3, Rekognition og Bedrock. S3_BUCKET settes automatisk fra bucket-ressursen.


## Oppgave 2B – Remote state

State-nøkkel: wishifai/34/terraform.tfstate i bucketen pgr301-terraform-state

State lagres i S3 slik at pipelinen og andre utviklere bruker samme state.


## Oppgave 2C – Terraform i pipeline

Grønn kjøring: https://github.com/AlexanderEkeberg/pgr301-eksamen-34/actions/runs/41340040292

Terraform kjører etter build fordi den trenger den nye image-taggen, og imaget må ligge i ECR før ECS kan starte det.

Valgte å låse runner, Terraform og AWS-provideren slik at pipelinen gir samme resultat hver gang.