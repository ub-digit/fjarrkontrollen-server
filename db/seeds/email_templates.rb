EmailTemplate.create(
{
  body_sv: 'Hej,

Uppgifterna stämmer ej - var vänlig kontrollera referenserna.

Med vänlig hälsning

X biblioteket',

  body_en: 'Hi,

The information you have given is not correct - Please check the references again.

Best regards

X Library',
  subject_sv: 'Stämmer ej',
  subject_en: 'Incorrect information'
})



EmailTemplate.create(
{
  body_sv: 'Hej,

Uppgifterna är inte tillräckliga - var vänlig komplettera med:

Med vänlig hälsning

X biblioteket',

  body_en: 'Hi,

The information is not sufficient - please add:

Kind regards

X Library',
  subject_sv: 'Komplettera',
  subject_en: 'Not enough information'
})



EmailTemplate.create(
{
  body_sv: 'Hej,

Det du beställt är utlånat. Vill du ställa dig i kö?

Med vänlig hälsning

X biblioteket',
  body_en: 'Hi,

The item you ordered is not available.

Do you want to make a reservation?

Best regards

X Library',
  subject_sv: 'Utlånat',
  subject_en: 'Not available'
})



EmailTemplate.create(
{
  body_sv: 'Hej,

Det du beställt är utlånat och kan inte krävas förrän den (datum).

Vill du ställa dig i kö?

Med vänlig hälsning

X biblioteket',

  body_en: 'Hi,

The item you ordered is checked out and due (date).

Would you like to make a reservation?

Best regards

X Library',

  subject_sv: 'Utlånat - krävbart',
  subject_en: 'Not available - due'
})



EmailTemplate.create(
{
  body_sv: 'Hej,

Det du beställt har kommit men är inte till hemlån och kan endast läsas i biblioteket.

Med vänlig hälsning

X biblioteket',

  body_en: 'Hi,

The item you ordered has arrived but may only be used in the library.

Best regards

X Library',

  subject_sv: 'Utlånas ej',
  subject_en: 'For library use only'
})



EmailTemplate.create(
{
  body_sv: 'Hej,

Beställt material lånas inte ut. Vill du beställa kopior?  Kostar (X) kr

Med vänlig hälsning

X biblioteket',

  body_en: 'Hi,

The item you ordered can not be borrowed.

Do you want to order copies instead? The cost is SEK (X)

Best regards',

  subject_sv: 'Kopior i stället för lån?',
  subject_en: 'Copies instead of loan?'
})



EmailTemplate.create(
{
  body_sv: 'Hej,

Det du beställt finns inte i Norden. Vill du beställa lån från något bibliotek utanför Norden?

Det kostar 200 kr.

Med vänlig hälsning

X biblioteket',

  body_en: 'Hi,

What you ordered can not be borrowed from any Nordic

country. Would you like to order from a library outside the Nordic countries?

The cost will be (X) SEK.

Best regards

X Library',

  subject_sv: 'Lån utanför Norden',
  subject_en: 'Ordered item not available in any Nordic country'
})



EmailTemplate.create(
{
  body_sv: 'Beställda kopior finns nu att hämta på biblioteket. Kostar (X) Kr.

Endast kortbetalning.

Med vänlig hälsning

X biblioteket',

  body_en: 'Ordered copies may now be collected the Library. The cost will be (X) SEK.

Credit card payment only.

Best regards

X Library',

  subject_sv: 'Kopior att hämta',
  subject_en: 'Copies to collect'
})


EmailTemplate.create(
{
  body_sv: 'Beställt fjärrlån finns nu att hämta på biblioteket.

Kostar (X) Kr. Lånetiden utgår den (datum)

Lånet kommer att skickas tillbaka detta datum, om du inte hämtar det dessförinnan!

Med vänlig hälsning

X biblioteket',

  body_en: 'The item you ordered has arrived to the library as an interlibrary loan.

The cost will be (X) SEK.

Loan period (date)

It will be sent back if you don’t collect it before that date.

Best regards

X Library',

  subject_sv: 'Fjärrlån att hämta',
  subject_en: 'Interlibrary loan'
})



EmailTemplate.create(
{
  body_sv: 'Vi har valt att köpa in boken istället för att fjärrlåna.

Du blir meddelad när den finns att hämta på biblioteket.

Med vänlig hälsning

X biblioteket',

  body_en: 'We decided to purchase the book.

You will get a message when the book is ready for pickup at the library.

Best regards

X Library',

  subject_sv: 'Inköp',
  subject_en: 'Aquisition'
})


EmailTemplate.create(
{
  body_sv: 'Detta material finns i våra egna samlingar och fjärrlånas därför inte.

Med vänlig hälsning

X biblioteket',

  body_en: 'The item you ordered is held by the library and therefore can not be provided through interlibrary loan.

Best regards

X Library',

  subject_sv: 'Egna samlingar',
  subject_en: 'Gothenburg University Library holding'
})


EmailTemplate.create(
{
  body_sv: 'Materialet är nytt och kommer att levereras till biblioteket med pliktleverans.

Vi fjärrlånar inte då utan du ställs i kö och vi meddelar när det kan hämtas.

Eftersom materialet är nytt har det ännu inte levererats till biblioteket.

Du ställs i kö och vi meddelar när det kan hämtas.

Med vänlig hälsning

X biblioteket',

  body_en: 'The material is new and a legal deposit copy will be sent to the library. Therefore we will not make an

interlibrary loan.

You will be put on hold and get a message when the book is ready for pickup.

Best regards

X Library',

  subject_sv: 'Pliktleverans',
  subject_en: 'Legal deposit'
})


EmailTemplate.create(
{
  body_sv: 'Detta är en påminnelse om ej avhämtat fjärrlån / kopior. Fjärrlånat material ligger bakom disken.

Vänligen fråga personalen om hjälp.

Med vänlig hälsning

X biblioteket',

  body_en: 'This is a reminder that you have an interlibrary loan / copies to collect.

The material is placed behind the circulation desk.

Please ask the librarian for help.

Best regards

X Library',

  subject_sv: 'Påminnelse',
  subject_en: 'Reminder'
})


EmailTemplate.create(
{
  body_sv: 'Tidskriften finns i vår tidskriftslista med artikeln i fulltext (länk till tidskriftslistan)’

Med vänlig hälsning

X biblioteket',

  body_en: 'The title can be found in our journal list and contains the article in full text.(länk till tidskriftslistan)

Best regards

X Library',

  subject_sv: 'Artikelbeställning',
  subject_en: 'Article order'
})


EmailTemplate.create(
{
  body_sv: 'Materialet finns som fri e-resurs.(länk)

Med vänlig hälsning

X biblioteket',

  body_en: 'The material can be found as a free electronic resource.(länk)

Best regards

X Library',

  subject_sv: 'Fri e-resurs',
  subject_en: 'Free electronic resource'
})


EmailTemplate.create(
{
  body_sv: 'Du har ett fjärrlån att hämta på biblioteket. Hämta materialet i informationsdisken. Vänligen be personalen om hjälp.

Om du inte hämtar materialet inom sju dagar kommer det att skickas tillbaka.

Med vänlig hälsning

X biblioteket',

  body_en: 'You have an interlibrary loan for pickup at the library. Pick up the material from the information desk. Please ask the staff for assistance.

If you don\'t pick up the material within seven days it will be returned.

Best regards

X Library',

  subject_sv: 'Påminnelse: Fjärrlån att hämta',
  subject_en: 'Reminder: Interlibrary loan'
})
