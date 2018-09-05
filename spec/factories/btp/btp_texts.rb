FactoryBot.define do
  factory :btp_text, class: 'Btp::Text' do
    year 2013
    teacher_number 1
    region 'O'
    full 'Minha concepção de alfabetização?\nHoje nosso aluno, na grande maioria já tem um vasto conhecimento informal aos 6 anos, mesmo que não domine /conheça o código.\nAlfabetização é um sistema notacional, pois tem regras que precisam compreender p/ apropriar-se da leitura e escrita.\nROSANE WIENANDTS'
    class_number 12
    acronym 'SEA'
  end
end
