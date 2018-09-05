require 'pdf-reader'
DIR = 'script/todos os arquivos - digitação/'.freeze

$regexp_code = Regexp.new(/\d+_[\d_a-z\?]+\n/i) # 01493_070505_M_08_03_01_2014_TA_PL_1A_A12
$regexp_name = Regexp.new(/#?nome:[ a-zâãáêéíôõóúÂÃÁÊÉÍÔÕÓÚ]+/i)

def same_size?(names, codes, texts)
  same = names == codes
  same &&= names == texts
  same &&= codes == texts
  same
end

def add_texts(names, text_codes, texts, file)
  names.count.times do |i|
    student_number, student_age, student_sex, stratum_number, collection_number,
    student_text_number, collection_year, type, student_school, student_grade,
    student_class = text_codes[i].chop.split('_')
    student_class = Batale::Text.last.student_class unless student_class.present?
    text = Batale::Text.create_with(
      student_name: names[i],
      student_number: student_number,
      student_age: student_age,
      student_sex: student_sex,
      stratum_number: stratum_number,
      collection_number: collection_number,
      student_text_number: student_text_number,
      collection_year: collection_year,
      type: type,
      student_school: student_school,
      student_grade: student_grade,
      student_class: student_class,
      original: texts[i],
      normalized: texts[i]
    ).find_or_create_by(code: text_codes[i])
    if text.valid?
      text.save!
    else
      puts file, text.errors.messages, text_codes[i]
    end
  end
end

exclude = [
  # códigos iguais
  'script/todos os arquivos - digitação/Digitação 01_09_2004_BA_1S_B_22.pdf',
  'script/todos os arquivos - digitação/digitação 01_04_2002_SM_2S_B_14.pdf',
  'script/todos os arquivos - digitação/digitação 01_06_2003_BA_1S_A_12.pdf',
  'script/todos os arquivos - digitação/digitação 04_01_2009_MM_2A_A_20.pdf',
  'script/todos os arquivos - digitação/digitação 04_01_2009_MM_2A_C_22.pdf',
  'script/todos os arquivos - digitação/digitação 04_01_2009_MM_2A_F_23.pdf',
  'script/todos os arquivos - digitação/digitação 07_01_2015_OB_3A_3A_21.pdf',
  'script/todos os arquivos - digitação/digitação 07_03_2013_CMP_2A_A_14.pdf',
  'script/todos os arquivos - digitação/digitação 07_03_2013_CMP_3A_B_17.pdf',
  'script/todos os arquivos - digitação/digitação 08_02_2014_GIM_2A_A23_19.pdf',
  'script/todos os arquivos - digitação/digitação 08_03_2014_PL_1A_A11_16.pdf',
  'script/todos os arquivos - digitação/digitação 01_02_2001_SM_3S_A_15.pdf',
  'script/todos os arquivos - digitação/digitação 01_04_2002_SM_3S_A_23.pdf',
  'script/todos os arquivos - digitação/digitação 07_01_2015_CMP_5A_5B_26.pdf',
  'script/todos os arquivos - digitação/digitação 01_05_2003_BA_3S_A_21.pdf',
  'script/todos os arquivos - digitação/digitação 01_06_2003_BA_4S_A_17.pdf',
  # nome: no meio do texto
  'script/todos os arquivos - digitação/digitação 01_05_2003_SM_3S_B_16.pdf',
  'script/todos os arquivos - digitação/digitação 01_05_2003_SM_4S_B_25.pdf',
  'script/todos os arquivos - digitação/digitação 07_01_2014_CMP_2A_B_22.pdf',
  'script/todos os arquivos - digitação/digitação 07_01_2014_CMP_3A_D_10.pdf',
  'script/todos os arquivos - digitação/digitação 07_01_2014_CMP_4A_B_23.pdf',
  'script/todos os arquivos - digitação/digitação 07_02_2013_CMP_4A_D_24.pdf',
  'script/todos os arquivos - digitação/digitação 07_03_2013_CMP_1A_B_09.pdf',
  'script/todos os arquivos - digitação/digitação 07_03_2014_CMP_2A_B_20.pdf',
  'script/todos os arquivos - digitação/digitação 07_03_2014_CMP_4A_B_22.pdf',
  'script/todos os arquivos - digitação/digitação 01_05_2003_BA_4S_B_26.pdf',
  'script/todos os arquivos - digitação/digitação 07_01_2014_CMP_5A_B_21.pdf'
]

text_count_from_filename = 0

def only_name(name)
  splitted_name = name.split
  splitted_name.delete_at(0) if splitted_name[0] =~ /nome/i
  splitted_name.delete_at(splitted_name.count - 1) if splitted_name[splitted_name.count - 1] =~ /revisado/i
  splitted_name.join(' ')
end

def process_file(file)
  names = []
  text_codes = []
  texts = []
  while file != ''
    _before, name, file = file.partition($regexp_name)
    next if name.include?('#')
    names << only_name(name) unless name.empty?
    _before, code, file = file.partition($regexp_code)
    text_codes << code unless code.empty?
    text = file.partition($regexp_name)[0]
    # se próximos caracteres não são código, texto tem 'nome:' no meio
    unless file.partition($regexp_name)[2][0..100] =~ $regexp_code
      text, text_with_name, file = file.partition($regexp_name)
      if text_with_name.include?('#')
        texts << text.strip
        next
      end
      text += text_with_name
      text += file.partition($regexp_name)[0]
      file = file.partition($regexp_name)[1] + file.partition($regexp_name)[2]
    end
    texts << text.strip unless text.empty?
  end
  [names, text_codes, texts]
end

Dir.glob(DIR + '*').sort.each do |file|
  reader = PDF::Reader.new(file)
  current_file = ''

  reader.pages.each do |page|
    current_file += page.text
    current_file += "\n"
  end

  text_count_from_filename += file.split(' ').last.split('.').first.split('_').last.to_i
  names, text_codes, texts = process_file(current_file)

  if same_size?(names.count, text_codes.count, texts.count)
    add_texts(names, text_codes, texts, file)
  else
    p file
  end
end
p text_count_from_filename
