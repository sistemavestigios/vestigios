User.destroy_all
puts '== Criando usuários =='
admin = User.create!(email: 'haga@vestigios.com', name: 'Heitor Almeida', password: 'abc123', role: Role.role_admin)

Batale::Text.destroy_all
puts "\n== Criando textos padrão=="
(1..12).each do |n|
  Batale::Text.create!(student_number: n, student_age: (n % 4) + 10, student_sex: 'm',
                      stratum_number: n, collection_number: 1, student_text_number: 1,
                      collection_year: 2001, type: 'tn', student_school: 'ba',
                      student_grade: '1s', student_class: 'a', original: Faker::Lorem.paragraph)
end

Batale::Errortog.destroy_all
puts "\n== Criando erros base =="
# Cria as classes de erros base
errortogs_base = Batale::Errortog
                 .create!([{ name: 'Fonográfico' },
                          { name: 'Ortográfico' },
                          { name: 'Fonológico' }])
fonografico, ortografico, fonologico = errortogs_base
puts "\n== Criando filhos de Fonográfico =="
# Fonográfico -> {Traçado, Sequenciamento, Inserção de letras/sílabas, Omissão de letras/sílabas}
fonografico
  .child_errortogs
  .create!([{ name: 'Traçado de Letra' },
           { name: 'Sequenciamento' },
           { name: 'Inserção de letras/sílabas' },
           { name: 'Omissão de letras/sílabas' }])
puts "\n== Criando filhos de Ortográfico =="
# Ortográfico -> {Contextual, Arbitrário}
ortografico
  .child_errortogs
  .create!([{ name: 'Contextual' },
           { name: 'Arbitrário' }])
# Contextual -> {Fricativa coronal, Nasal, Líquida, Plosiva dorsal}
ortografico
  .child_errortogs[0]
  .child_errortogs
  .create!([{ name: 'Fricativa coronal' },
           { name: 'Nasal' },
           { name: 'Líquida' },
           { name: 'Plosiva dorsal' }])
# Arbitrário -> {Fricativa coronal, Plosiva dorsal}
ortografico
  .child_errortogs[1]
  .child_errortogs
  .create!([{ name: 'Fricativa coronal' },
           { name: 'Plosiva dorsal' }])
puts "\n== Criando filhos de Ortográfico =="
# Fonológico -> {Segmental, Prosódico}
fonologico
  .child_errortogs
  .create!([{ name: 'Segmental' },
           { name: 'Prosódico' }])
# Segmental -> {Consoantes, Vogais, Semivogais}
fonologico
  .child_errortogs[0]
  .child_errortogs
  .create!([{ name: 'Consoante' },
           { name: 'Vogal' },
           { name: 'Semivogal' }])
# Consoantes -> {Obstruintes, Soantes}
fonologico
  .child_errortogs[0]
  .child_errortogs[0]
  .child_errortogs
  .create!([{ name: 'Obstruinte' },
           { name: 'Soante' }])
# Vogais -> {Átonas, Tônicas}
fonologico
  .child_errortogs[0]
  .child_errortogs[1]
  .child_errortogs
  .create!([{ name: 'Átona' },
           { name: 'Tônica' }])
# Átonas -> {Iniciais, Mediais, Finais, Clíticos}
fonologico
  .child_errortogs[0]
  .child_errortogs[1]
  .child_errortogs[0]
  .child_errortogs
  .create!([{ name: 'Inicial' },
           { name: 'Medial' },
           { name: 'Final' },
           { name: 'Clítico' }])
# Semivogais -> {Ditongo fonético, Ditongo fonológico, Ditongo morfológico}
fonologico
  .child_errortogs[0]
  .child_errortogs[2]
  .child_errortogs
  .create!([{ name: 'Ditongo fonético' },
           { name: 'Ditongo fonológico' },
           { name: 'Ditongo morfológico' }])

# Prosódico -> {Sílaba, Segmentação não convencional, Acentuação}
fonologico
  .child_errortogs[1]
  .child_errortogs
  .create!([{ name: 'Sílaba' },
           { name: 'Segmentação não-convencional' },
           { name: 'Acentuação' }])
# Sílaba -> {Ataque complexo, Coda, Nasalidade}
fonologico
  .child_errortogs[1]
  .child_errortogs[0]
  .child_errortogs
  .create!([{ name: 'Ataque complexo' },
           { name: 'Coda' },
           { name: 'Nasalidade' }])
# Nasalidade -> {Final}
fonologico
  .child_errortogs[1]
  .child_errortogs[0]
  .child_errortogs[2]
  .child_errortogs
  .create!([{ name: 'Medial' },
           { name: 'Final' }])
# Segmentação não convencional -> {Hipossegmentação, Hipersegmentação, Híbrido}
fonologico
  .child_errortogs[1]
  .child_errortogs[1]
  .child_errortogs
  .create!([{ name: 'Hipossegmentação' },
           { name: 'Hipersegmentação' },
           { name: 'Híbrido' }])
# Acentuação -> {Ausência, Uso indevido}
fonologico
  .child_errortogs[1]
  .child_errortogs[2]
  .child_errortogs
  .create!([{ name: 'Ausência' },
           { name: 'Final' }])

puts "\n== Batale::Errortog populado com sucesso =="
# Fonográfico - Traçado de letra
fonografico
  .child_errortogs[0].definitions
  .create!([{ rule: 'm → n', example: 'nofo', target_word: 'mofo' },
           { rule: 'n → m', example: 'mada', target_word: 'nada' }])
puts "\n== Definitions Fonográfico =="
# Ortográfico - Contextual
ortografico
  .child_errortogs[0].definitions
  .create!([{ rule: 'rr → r', example: 'tera', target_word: 'terra' }])
# Ortográfico - Contextual - Fricativa coronal
ortografico
  .child_errortogs[0]
  .child_errortogs[0].definitions
  .create!([{ rule: 's → ss (depois de coda)', example: 'enssino', target_word: 'ensino' },
           { rule: 'ç → s', example: 'moso', target_word: 'moço' },
           { rule: 'c → s', example: 'masio', target_word: 'macio' },
           { rule: 'ss → s (depois de coda)', example: 'oso', target_word: 'osso' },
           { rule: 'j → g', example: 'vega', target_word: 'veja' },
           { rule: 'sç → s', example: 'nasa', target_word: 'nasça' },
           { rule: 'z → ss', example: 'crusses', target_word: 'cruzes' },
           { rule: 'z → c', example: 'cruces', target_word: 'cruzes' },
           { rule: 's → z', example: 'zapato', target_word: 'sapato' }])
# Ortográfico - Contextual - Nasal
ortografico
  .child_errortogs[0]
  .child_errortogs[1].definitions
  .create!([{ rule: 'n → m (em coda)', example: 'tamto', target_word: 'tanto' },
           { rule: 'm → n (em coda)', example: 'tanpa', target_word: 'tampa' }])
# Ortográfico - Contextual - Líquida
ortografico
  .child_errortogs[0]
  .child_errortogs[2].definitions
  .create!([{ rule: 'r → rr (depois de coda)', example: 'enrrolar', target_word: 'enrolar' }])
# Ortográfico - Contextual - Plosiva dorsal
ortografico
  .child_errortogs[0]
  .child_errortogs[3].definitions
  .create!([{ rule: 'qu → q', example: 'qeijo', target_word: 'queijo' },
           { rule: 'gui/e → gi/e', example: 'pregiça', target_word: 'preguiça' },
           { rule: 'g → j (antes de a, o, u)', example: 'majo', target_word: 'mago' }])
# Ortográfico - Arbitrário
ortografico
  .child_errortogs[1].definitions
  .create!([{ rule: 'h → ø', example: 'oje', target_word: 'hoje' }])
# Ortográfico - Arbitrário - Fricativa coronal
ortografico
  .child_errortogs[1]
  .child_errortogs[0].definitions
  .create!([{ rule: 'ç → ss', example: 'pessa', target_word: 'peça' },
           { rule: 's → ç', example: 'pença', target_word: 'pensa' },
           { rule: 'ss → c', example: 'ece', target_word: 'esse' },
           { rule: 's → c', example: 'cemente', target_word: 'semente' },
           { rule: 's → z', example: 'vazo', target_word: 'vaso' },
           { rule: 'z → s', example: 'voses', target_word: 'vozes' },
           { rule: 'c → s', example: 'senoura', target_word: 'cenoura' },
           { rule: 'c → ss', example: 'massio', target_word: 'macio' },
           { rule: 'c → sc', example: 'fasce', target_word: 'face' },
           { rule: 'sc → c', example: 'nace', target_word: 'nasce' },
           { rule: 'ç → s', example: 'pansa', target_word: 'pança' },
           { rule: 'x → s', example: 'esperiência', target_word: 'experiência' },
           { rule: 'x → ch', example: 'vechame', target_word: 'vexame' },
           { rule: 'ch → x', example: 'caxo', target_word: 'cacho' },
           { rule: 'g → j', example: 'jente', target_word: 'gente' },
           { rule: 'j → g', example: 'geito', target_word: 'jeito' }])
# Ortográfico - Arbitrário - Plosiva dorsal
ortografico
  .child_errortogs[1]
  .child_errortogs[1].definitions
  .create!([{ rule: 'qu → cu (antes de a, o, u)', example: 'cuando', target_word: 'quando' },
           { rule: 'g → gui (em coda)', example: 'maliguina', target_word: 'maligna' }])

puts "\n== Definitions Ortográfico =="
# Fonológico - Segmental - Consoante - Obstruinte
fonologico
  .child_errortogs[0]
  .child_errortogs[0]
  .child_errortogs[0].definitions
  .create!([{ rule: 'Sonorização', example: 'breto', target_word: 'preto' },
           { rule: 'Dessonorização', example: 'pranco', target_word: 'branco' }])
# Fonológico - Segmental - Consoante - Soante
fonologico
  .child_errortogs[0]
  .child_errortogs[0]
  .child_errortogs[1].definitions
  .create!([{ rule: 'nh → n', example: 'cana', target_word: 'canha' },
           { rule: 'lh → l', example: 'cala', target_word: 'calha' },
           { rule: 'lh → li', example: 'paliaço', target_word: 'palhaço' }])
# Fonológico - Segmental - Vogal - Átona - Inicial
fonologico
  .child_errortogs[0]
  .child_errortogs[1]
  .child_errortogs[0]
  .child_errortogs[0].definitions
  .create!([{ rule: 'e → i', example: 'insino', target_word: 'ensino' }])
# Fonológico - Segmental - Vogal - Átona - Medial
fonologico
  .child_errortogs[0]
  .child_errortogs[1]
  .child_errortogs[0]
  .child_errortogs[1].definitions
  .create!([{ rule: 'e → i', example: 'minino', target_word: 'menino' },
           { rule: 'o → u', example: 'buneca', target_word: 'boneca' }])
# Fonológico - Segmental - Vogal - Átona - Final
fonologico
  .child_errortogs[0]
  .child_errortogs[1]
  .child_errortogs[0]
  .child_errortogs[2].definitions
  .create!([{ rule: 'o → u', example: 'meninu', target_word: 'menino' },
           { rule: 'u → o (nome)', example: 'museo', target_word: 'museu' }])
# Fonológico - Segmental - Vogal - Átona - Clítico
fonologico
  .child_errortogs[0]
  .child_errortogs[1]
  .child_errortogs[0]
  .child_errortogs[3].definitions
  .create!([{ rule: 'e → i', example: 'mi', target_word: 'me' }])
# Fonológico - Segmental - Vogal - Tônica
fonologico
  .child_errortogs[0]
  .child_errortogs[1]
  .child_errortogs[1].definitions
  .create!([{ rule: 'Alteração da tônica', example: 'prito', target_word: 'preto' }])
# Fonológico - Segmental - Semivogal - Ditongo fonético
fonologico
  .child_errortogs[0]
  .child_errortogs[2]
  .child_errortogs[0].definitions
  .create!([{ rule: '-ei → e', example: 'pexe', target_word: 'peixe' },
           { rule: '-ou → o', example: 'poco', target_word: 'pouco' },
           { rule: 'ᴓ → i', example: 'feis', target_word: 'fez' },
           { rule: '-ei', example: 'peira', target_word: 'pêra' },
           { rule: '-ou', example: 'bouto', target_word: 'boto' }])
# Fonológico - Segmental - Semivogal - Ditongo fonológico
fonologico
  .child_errortogs[0]
  .child_errortogs[2]
  .child_errortogs[1].definitions
  .create!([{ rule: 'l → u', example: 'sau', target_word: 'sal' },
           { rule: 'u → l (nome)', example: 'cél', target_word: 'céu' },
           { rule: 'Omissão', example: 'fata', target_word: 'falta' }])
# Fonológico - Segmental - Semivogal - Ditongo morfológico
fonologico
  .child_errortogs[0]
  .child_errortogs[2]
  .child_errortogs[2].definitions
  .create!([{ rule: '-ou → o', example: 'conto', target_word: 'contou' },
           { rule: 'u → l (verbo)', example: 'tranformol', target_word: 'transformou' },
           { rule: 'u → o; e → i (verbo)', example: 'saio - vae', target_word: 'saiu - vai' }])
# Fonológico - Prosódico - Sílaba - Ataque complexo
fonologico
  .child_errortogs[1]
  .child_errortogs[0]
  .child_errortogs[0].definitions
  .create!([{ rule: 'Metátese intrassilábica', example: 'creto', target_word: 'certo' },
           { rule: 'Metátese intersilábica', example: 'dagrão', target_word: 'dragão' },
           { rule: 'Omissão da líquida', example: 'peto', target_word: 'preto' },
           { rule: 'Epêntese', example: 'parato', target_word: 'prato' }])
# Fonológico - Prosódico - Sílaba - Coda
fonologico
  .child_errortogs[1]
  .child_errortogs[0]
  .child_errortogs[1].definitions
  .create!([{ rule: 'Líquida -r', example: 'pota', target_word: 'porta' },
           { rule: 'Fricativa', example: 'pata', target_word: 'pasta' }])
# Fonológico - Prosódico - Sílaba - Nasalidade - Medial
fonologico
  .child_errortogs[1]
  .child_errortogs[0]
  .child_errortogs[2]
  .child_errortogs[0].definitions
  .create!([{ rule: '-i → in', example: 'muinto', target_word: 'muito' }])
# Fonológico - Prosódico - Sílaba - Nasalidade - Final
fonologico
  .child_errortogs[1]
  .child_errortogs[0]
  .child_errortogs[2]
  .child_errortogs[1].definitions
  .create!([{ rule: '-am → ão', example: 'falão', target_word: 'falam' },
           { rule: '-em → ei', example: 'vei', target_word: 'vem' },
           { rule: '-ões → õis', example: 'balõis', target_word: 'balões' },
           { rule: 'ão → am', example: 'sabam', target_word: 'sabão' }])
# Segmentação não convencional -> {Hipossegmentação, Hipersegmentação, Híbrido}
fonologico
  .child_errortogs[1]
  .child_errortogs[1]
  .child_errortogs[0].definitions
  .create!([{ rule: 'Hipossegmentação', example: 'ticome', target_word: 'te comer' }])
fonologico
  .child_errortogs[1]
  .child_errortogs[1]
  .child_errortogs[1].definitions
  .create!([{ rule: 'Hipersegmentação', example: 'de pois', target_word: 'depois' }])
fonologico
  .child_errortogs[1]
  .child_errortogs[1]
  .child_errortogs[2].definitions
  .create!([{ rule: 'Híbrido', example: 'foice em bora', target_word: 'foi-se embora' }])
# Acentuação -> {Ausência, Uso indevido}
fonologico
  .child_errortogs[1]
  .child_errortogs[2]
  .child_errortogs[0].definitions
  .create!([{ rule: 'Ausência', example: 'agua', target_word: 'água' }])
fonologico
  .child_errortogs[1]
  .child_errortogs[2]
  .child_errortogs[1].definitions
  .create!([{ rule: 'Uso indevido', example: 'panéla', target_word: 'panela' }])
puts "\n== Definitions Fonológico =="
