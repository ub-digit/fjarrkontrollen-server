namespace :email_templates do
  desc "Add postition values"
  task add_position: :environment do
    puts "Add postition values"

	EmailTemplate.find_by_subject_sv('Komplettera').update_attribute(:position, 10)
  	EmailTemplate.find_by_subject_sv('Utlånat').update_attribute(:position, 20)
  	EmailTemplate.find_by_subject_sv('Utlånat - krävbart').update_attribute(:position, 30)
  	EmailTemplate.find_by_subject_sv('Stämmer ej').update_attribute(:position, 40)
  	EmailTemplate.find_by_subject_sv('Utlånas ej').update_attribute(:position, 50)
  	EmailTemplate.find_by_subject_sv('Kopior i stället för lån?').update_attribute(:position, 60)
  	EmailTemplate.find_by_subject_sv('Lån utanför Norden').update_attribute(:position, 70)
  	EmailTemplate.find_by_subject_sv('Kopior att hämta').update_attribute(:position, 80)
  	EmailTemplate.find_by_subject_sv('Fjärrlån att hämta').update_attribute(:position, 90)
  	EmailTemplate.find_by_subject_sv('Inköp').update_attribute(:position, 100)
  	EmailTemplate.find_by_subject_sv('Egna samlingar').update_attribute(:position, 110)
  	EmailTemplate.find_by_subject_sv('Pliktleverans').update_attribute(:position, 120)
  	EmailTemplate.find_by_subject_sv('Påminnelse').update_attribute(:position, 130)
  	EmailTemplate.find_by_subject_sv('Artikelbeställning').update_attribute(:position, 140)
  	EmailTemplate.find_by_subject_sv('Fri e-resurs').update_attribute(:position, 150)
  	EmailTemplate.find_by_subject_sv('Påminnelse: Fjärrlån att hämta').update_attribute(:position, 160)
    puts " All done!"
  end
end

