FactoryBot.define do
  factory :batale_text, class: 'Batale::Text' do
    student_number '0001'
    student_age '070220'
    student_sex 'M'
    stratum_number '01'
    collection_number '01'
    student_text_number '01'
    collection_year '2001'
    type 'TN'
    student_school 'BA'
    student_grade '1S'
    student_class 'B'
    original "\nu chicuben to ta\nsentado na causa da\nboto agua nas flor\ndi pois ele\nfocinbora\n"
    writing_type 'Escrita alfabética'

    trait :female do
      student_sex 'F'
    end
  end
end
