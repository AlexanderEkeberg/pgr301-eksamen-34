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

Hvert image tagges med commit-SHA-en, slik at man alltid kan se nøyaktig hvilken versjon av koden som kjører, og enkelt rulle tilbake til en tidligere versjon.



## Oppgave 2A – ECS Express med Terraform

Terraform-kode: `infra/`

URL: https://wi-e93f0f7ffdc34ed1b0ae62a2d151e2cf.ecs.eu-west-1.on.aws

Helsesjekk: https://wi-e93f0f7ffdc34ed1b0ae62a2d151e2cf.ecs.eu-west-1.on.aws/api/health

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

![Pipeline](media/pipeline.png)

Terraform kjører etter build fordi den trenger den nye image-taggen, og imaget må ligge i ECR før ECS kan starte det.

Valgte å låse runner, Terraform og AWS-provideren slik at pipelinen gir samme resultat hver gang.


## Oppgave 3A – Metrikker

Metrikkene ligger i WishifaiMetrics.java og sendes til CloudWatch i namespace wishifai-34.

- `rekognition_duration` (Timer) måler tiden Rekognition-kallet tar.
- `bedrock_duration` (Timer) måler tiden Bedrock-kallet tar.
- `gift_suggestions_per_request` (DistributionSummary) er business-metrikken og viser hvor mange gaveforslag hvert bilde gir, i tillegg til totalt antall forslag og antall bilder analysert.
- `bedrock_parse_failures` (Counter) teller hvor ofte Bedrock svarer i et format appen ikke kan lese, som sier noe om kvaliteten på LLM-svarene.

Målingene viste at Bedrock tar rundt 15 sekunder mens Rekognition tar under 1 sekund, så det er Bedrock som gjør tjenesten treg.


## Oppgave 3B – Dashboard og alarm

Dashboard: wishifai-34 i CloudWatch

Her ligger Terraform-kode: infra/dashboard.tf og infra/alarm.tf

![Dashboard](media/dashboard.png)

- Business: gift_suggestions_per_request viser hvor mange gaveforslag hvert bilde gir.
- Infrastruktur: CPU og minne for ECS-tjenesten, for å se om containeren har nok ressurser.
- Applikasjon: process.cpu.usage fra Spring Boot Actuator viser hvor mye CPU selve appen bruker.
- I tillegg vises bedrock_duration og rekognition_duration side om side, slik at man ser hvor tiden går.


### Alarm
wishifai-34-bedrock-slow går hvis Bedrock bruker mer enn 30 sekunder i snitt i 3 minutter på rad. Bedrock tar normalt rundt 15 sekunder og er den tregeste delen av tjenesten, så 30 sekunder betyr at noe er galt. Kravet om 3 perioder gjør at ett enkelt tregt kall ikke utløser alarmen.


## Oppgave 4 – Drøfting 

Testing er noe som vil bli vanskeligere siden GenAi modeller ofte ikke gir samme svar hver gang. Da kan vi ikke teste med vanlige tester som sjekker 
ett bestemt svar. jeg sjekket dette ved å sende inn samme bilde sample_image tre ganger fikk jeg fem forslag innen interiør hver gang og noen merker
gikk igjen, men ingen av svarene var like. jeg tenker da i stedet for å teste nøyaktige svar må man derfor teste rundt svaret, med strenge regler 
for hva som er lov. For Wishifai kan det være at svaret alltid er gyldig JSON, har maks fem forslag, passer til typen rom og ikke inneholder gaver 
fra en forbudt-liste, for eksempel kniver for et barnerom. Disse reglene kan kjøres i pipelinen før deploy men ulempe er at de bare fanger feil man 
har tenkt på på forhånd, så de reduserer risikoen, men fjerner den ikke.

Med GenAI er det ikke bare koden som deployes men også prompten og modellen. I Wishifai ligger prompten i BedrockService.java, så den er versjonert 
i Git, følger commit-SHA-en og er lett å spore og rulle tilbake. Modellen kommer derimot fra en ekstern leverandør. Wishifai bruker en låst versjon, 
claude-sonnet-4-5-20250929, men leverandøren kan fase den ut, og jeg har aldri full innsikt i hvordan den oppfører seg. Hvis man bytter modell via 
BEDROCK_MODEL_ID kan det i tillegg endre alle svarene uten at pipelinen merker noe. jeg mener at hvis man ønsker full kontroll får man det bare ved 
å kjøre modellen lokalt, men det krever egen drift og gir ofte dårligere svar fordi open source modeller ofte ikke er like gode.

Dette med overvåking er enda viktigere når det gjelder GenAI. Overvåkingen jeg la til i oppgave 3 viser at tjenesten kjører, men ikke om svarene er 
gode. Alarmen går bare av hvis Bedrock bruker over 30 sekunder, men et upassende gaveforslag til et barn ville gitt normal svartid og ingen alarm. 
Metrikken bedrock_parse_failures sier noe om kvaliteten, men bare om formatet på svaret, ikke om innholdet. Det jeg tenker er viktigst i produksjon, 
er en enkel måte for brukere å rapportere dårlige svar på, kanskje stikkprøver av svarene og en måte å følge med på tokenforbruket. hvis svarlengden 
eller kostnadene øker mye, kan det være et tegn på at modellen oppfører seg annerledes men, det er ikke en garanti dette heller da. 

For Wishifai er det greit å deploye automatisk og rette feil etter hvert som de oppdages i produksjon, fordi et dårlig gaveforslag ikke er så 
farlig. Men hvis vi ser på en bank eller et sykehus, er en feil mye mer alvorlig. Der tenker jeg at et menneske bør godkjenne endringer før de går i 
produksjon, og at AI-en bare bør foreslå. Jeg tenker at jo større konsekvenser en feil kan ha, desto strengere bør man være med å automatisere ting.
