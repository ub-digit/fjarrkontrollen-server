namespace :email_templates do
  desc "Add postition values"
  task add_position: :environment do
    puts "Add postition values"

    EmailTemplate.find_by_subject_sv('Komplettera').try(:update_attributes, {position:10})
  	EmailTemplate.find_by_subject_sv('Utlånat').try(:update_attributes, {position:20})
  	EmailTemplate.find_by_subject_sv('Stämmer ej').try(:update_attributes, {position:30})
  	EmailTemplate.find_by_subject_sv('Utlånas ej').try(:update_attributes, {position:40})
  	EmailTemplate.find_by_subject_sv('Kopior i stället för lån?').try(:update_attributes, {position:50})
  	EmailTemplate.find_by_subject_sv('Lån utanför Norden').try(:update_attributes, {position:60})
  	EmailTemplate.find_by_label('copies_to_collect').try(:update_attributes, {position:70})
  	EmailTemplate.find_by_subject_sv('Inköp').try(:update_attributes, {position:80})
  	EmailTemplate.find_by_subject_sv('Egna samlingar').try(:update_attributes, {position:90})
  	EmailTemplate.find_by_subject_sv('Pliktleverans').try(:update_attributes, {position:100})
  	EmailTemplate.find_by_subject_sv('Artikelbeställning').try(:update_attributes, {position:110})
  	EmailTemplate.find_by_subject_sv('Fri e-resurs').try(:update_attributes, {position:120})
  	EmailTemplate.find_by_subject_sv('Påminnelse: Fjärrlån att hämta').try(:update_attributes, {position:130})

    EmailTemplate.find_by_subject_sv('Utlånat - krävbart').try(:destroy)
    EmailTemplate.find_by_subject_sv('Fjärrlån att hämta').try(:destroy)
    EmailTemplate.find_by_subject_sv('Påminnelse').try(:destroy)


    @template = EmailTemplate.find_by_subject_sv('Stämmer ej')
    if @template 
      EmailTemplate.find_by_subject_sv('Stämmer ej').update_attribute(:body_sv, 'Hej,

Uppgifterna stämmer ej - var vänlig kontrollera referenserna.

Med vänlig hälsning,
Fjärrlån

Göteborgs universitetsbibliotek');


      EmailTemplate.find_by_subject_sv('Stämmer ej').update_attribute(:body_en, 'Hello,

The information you’ve submitted is incorrect - please check the references again so we can complete your order.

Best regards
Interlibrary loans department

Gothenburg University Library');
    end


    @template = EmailTemplate.find_by_subject_sv('Komplettera')
    if @template 
      EmailTemplate.find_by_subject_sv('Komplettera').update_attribute(:body_sv, 'Hej,

Uppgifterna är inte tillräckliga - var vänlig komplettera med:

Med vänlig hälsning,
Fjärrlån

Göteborgs universitetsbibliotek');

      EmailTemplate.find_by_subject_sv('Komplettera').update_attribute(:body_en, 'Hello,

The information you’ve submitted is not sufficient - please add:

Best regards
Interlibrary loans department

Gothenburg University Library');

      EmailTemplate.find_by_subject_sv('Komplettera').update_attribute(:subject_en, 'Insufficient information');
    end


    @template = EmailTemplate.find_by_subject_sv('Utlånat')
    if @template 
      EmailTemplate.find_by_subject_sv('Utlånat').update_attribute(:body_sv, 'Hej,

Materialet du beställt är utlånat. Vill du ställa dig i kö?

Med vänlig hälsning,
Fjärrlån

Göteborgs universitetsbibliotek');


      EmailTemplate.find_by_subject_sv('Utlånat').update_attribute(:body_en, 'Hello,

The item you’ve ordered is currently checked out.

Would you like to make a reservation?

Best regards
Interlibrary loans department

Gothenburg University Library');

      EmailTemplate.find_by_subject_sv('Utlånat').update_attribute(:subject_en, 'Checked out');
    end


    @template = EmailTemplate.find_by_subject_sv('Utlånas ej')
    if @template 
      EmailTemplate.find_by_subject_sv('Utlånas ej').update_attribute(:body_sv, 'Hej,

Materialet du beställt finns att hämta, men är inte till hemlån och kan endast läsas i biblioteket.

Med vänlig hälsning,
Fjärrlån

Göteborgs universitetsbibliotek');


      EmailTemplate.find_by_subject_sv('Utlånas ej').update_attribute(:body_en, 'Hello,

The item you ordered is now available for pickup, but may only be used in the library.

Best regards
Interlibrary loans department

Gothenburg University Library');

      EmailTemplate.find_by_subject_sv('Utlånas ej').update_attribute(:subject_en, 'Material to be collected: for library use only');
      EmailTemplate.find_by_subject_sv('Utlånas ej').update_attribute(:subject_sv, 'Inkommet läsesalslån');
    end

    @template = EmailTemplate.find_by_subject_sv('Kopior i stället för lån?')
    if @template 
      EmailTemplate.find_by_subject_sv('Kopior i stället för lån?').update_attribute(:body_sv, 'Hej,

Materialet du beställt kan inte fjärrlånas. Vill du beställa kopior? Det kostar (X) kr.

Med vänlig hälsning,
Fjärrlån

Göteborgs universitetsbibliotek');


      EmailTemplate.find_by_subject_sv('Kopior i stället för lån?').update_attribute(:body_en, 'Hello,

The item you’ve ordered is not available as an interlibrary loan.

Would you like to order copies instead? The cost is (X) SEK.

Best regards
Interlibrary loans department

Gothenburg University Library');
    end

    @template = EmailTemplate.find_by_subject_sv('Lån utanför Norden')
    if @template 
      EmailTemplate.find_by_subject_sv('Lån utanför Norden').update_attribute(:body_sv, 'Hej,

Materialet du beställt finns inte inom Norden.

Vill du beställa ett utomnordiskt lån? Det kostar 200 kr.

Med vänlig hälsning,
Fjärrlån

Göteborgs universitetsbibliotek');


      EmailTemplate.find_by_subject_sv('Lån utanför Norden').update_attribute(:body_en, 'Hello,

The item you’ve ordered is not available within any Nordic country.

Would you like to order from a library outside the Nordic countries?

The cost is 200 SEK.

Best regards
Interlibrary loans department

Gothenburg University Library');

      EmailTemplate.find_by_subject_sv('Lån utanför Norden').update_attribute(:subject_en, 'Item not available in any Nordic country');
    end

    @template = EmailTemplate.find_by_label('copies_to_collect')
    if @template
      EmailTemplate.find_by_label('copies_to_collect').update_attribute(:body_sv, 'Hej,

Beställda kopior finns nu att hämta på biblioteket.

Med vänlig hälsning,
Fjärrlån

X biblioteket');

      EmailTemplate.find_by_label('copies_to_collect').update_attribute(:body_en, 'Hello,

Ordered copies may now be collected at the Library.

Best regards
Interlibrary loans department

X Library');
    end


    @template = EmailTemplate.find_by_subject_sv('Inköp')
    if @template
      EmailTemplate.find_by_subject_sv('Inköp').update_attribute(:body_sv, 'Hej,

Vi har valt att köpa in boken istället för att fjärrlåna.

Du ställs i kö och vi meddelar när den finns att hämta på biblioteket.

Med vänlig hälsning,
Fjärrlån

Göteborgs universitetsbibliotek');

      EmailTemplate.find_by_subject_sv('Inköp').update_attribute(:body_en, 'Hello,

We have decided to purchase the book instead of proceeding with an interlibrary loan.

It will be reserved for you and you’ll be notified when the book is ready for pickup at the library.

Best regards
Interlibrary loans department

Gothenburg University Library');
    end


    @template = EmailTemplate.find_by_subject_sv('Egna samlingar')
    if @template

      EmailTemplate.find_by_subject_sv('Egna samlingar').update_attribute(:body_sv, 'Hej,

Detta material finns i våra egna samlingar och fjärrlånas därför inte.

Se vår katalog: (länk)

Med vänlig hälsning,
Fjärrlån

Göteborgs universitetsbibliotek');

      EmailTemplate.find_by_subject_sv('Egna samlingar').update_attribute(:body_en, 'Hello,

The item you’ve ordered is already held by the library and therefore cannot be provided through an interlibrary loan.

Please consult our catalogue: (link)

Best regards
Interlibrary loans department

Gothenburg University Library');
    end


    @template = EmailTemplate.find_by_subject_sv('Pliktleverans')
    if @template

    EmailTemplate.find_by_subject_sv('Pliktleverans').update_attribute(:body_sv, 'Hej,

Beställt material är nytt och kommer att levereras till biblioteket med pliktleverans.

Du ställs i kö och vi meddelar när materialet har inkommit.

Med vänlig hälsning,
Fjärrlån

Göteborgs universitetsbibliotek');

    EmailTemplate.find_by_subject_sv('Pliktleverans').update_attribute(:body_en, 'Hello,

The material is new and a legal deposit copy will be sent to the library. Therefore it will not be provided through an interlibrary loan.

It will be reserved for you and you’ll be notified when the book is ready for pickup.

Best regards
Interlibrary loans department

Gothenburg University Library');
    end


    @template = EmailTemplate.find_by_subject_sv('Påminnelse: Fjärrlån att hämta')
    if @template

      EmailTemplate.find_by_subject_sv('Påminnelse: Fjärrlån att hämta').update_attribute(:body_sv, 'Hej,

Du har ett fjärrlån att hämta på biblioteket. Vänligen vänd dig till informationsdisken.

Om du inte hämtar materialet inom sju dagar kommer det att skickas tillbaka.

Med vänlig hälsning,
Fjärrlån

Göteborgs universitetsbibliotek');


      EmailTemplate.find_by_subject_sv('Påminnelse: Fjärrlån att hämta').update_attribute(:body_en, 'Hello,

This is a reminder that you have an interlibrary loan or copies to collect.

Please consult our staff by the circulation desk.

If the material is not collected within 7 days it will be returned.

Best regards
Interlibrary loans department

Gothenburg University Library');
      end


    @template = EmailTemplate.find_by_subject_sv('Artikelbeställning')
    if @template
      EmailTemplate.find_by_subject_sv('Artikelbeställning').update_attribute(:body_sv, 'Hej,

Tidskriften finns i vår tidskriftslista med artikeln i fulltext.

Se denna länk: (länk till tidskriftslistan)

Med vänlig hälsning,
Fjärrlån

Göteborgs universitetsbibliotek');

      EmailTemplate.find_by_subject_sv('Artikelbeställning').update_attribute(:body_en, 'Hello,

The title can be found in our list of journals and it’s available in full text: (länk till tidskriftslistan)

Best regards
Interlibrary loans department

Gothenburg University Library');


      EmailTemplate.find_by_subject_sv('Artikelbeställning').update_attribute(:subject_en, 'Regarding your article order');
      EmailTemplate.find_by_subject_sv('Artikelbeställning').update_attribute(:subject_sv, 'Artikelbeställning – egen samling');

    end


    @template = EmailTemplate.find_by_subject_sv('Fri e-resurs')
    if @template
      EmailTemplate.find_by_subject_sv('Fri e-resurs').update_attribute(:body_sv, 'Hej,

Materialet finns som fri e-resurs. Se länk:

Med vänlig hälsning,
Fjärrlån

Göteborgs universitetsbibliotek');



      EmailTemplate.find_by_subject_sv('Fri e-resurs').update_attribute(:body_en, 'Hello,

The material is available as a free electronic resource: (länk)

Best regards
Interlibrary loans department

Gothenburg University Library');
    end


    EmailTemplate.find_or_create_by(subject_sv: "Egen samling: utlånat") do | template |
      template.subject_en = "Egen samling: utlånat" 
      template.body_sv = "Hej,
Vi gör inga fjärrlån på material som vi har i våra egna samlingar, trots att det är utlånat.
Du är dock välkommen att ställa dig i kö.
Se vår katalog: (länk)
 
Med vänlig hälsning,
Fjärrlån
Göteborgs universitetsbibliotek"; 
      template.body_en = "Hej,
Vi gör inga fjärrlån på material som vi har i våra egna samlingar, trots att det är utlånat.
Du är dock välkommen att ställa dig i kö.
Se vår katalog: (länk)
 
Med vänlig hälsning,
Fjärrlån
Göteborgs universitetsbibliotek"; 
      template.label = "Egen samling: utlånat" 
      template.disabled = false 
      template.position = 150
    end


    @template = EmailTemplate.find_by_label('delivered_status_set_for_copies_to_collect')
    if @template
      EmailTemplate.find_by_label('delivered_status_set_for_copies_to_collect').update_attribute(:body_sv, 'Beställda kopior finns nu att hämta på [pickup_location.name_sv].

Med vänlig hälsning

Göteborgs universitetsbibliotek

["Ordernummer: " order_number]
["Låntagare: " name]
["Titel: " title]
["Författare: " authors]
["Tidskriftstitel: " journal_title]
');

      EmailTemplate.find_by_label('delivered_status_set_for_copies_to_collect').update_attribute(:body_en, 'Ordered copies may now be collected at [pickup_location.name_en].

Best regards

Gothenburg University Library  

["Ordernumber: " order_number]
["Patron: " name]
["Title: " title]
["Author: " authors]
["Journal title: " journal_title]
');
    end

    puts " All done!"
  end
end

