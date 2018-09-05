require 'rails_helper'

RSpec.describe Batale::Word, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:wrong) }
    it { is_expected.to validate_presence_of(:right) }
    it { is_expected.to validate_presence_of(:text_id) }

    it { is_expected.to be_embedded_in(:definition) }
  end

  describe 'associations' do
    before(:each) do
      @text = create(:batale_text)
      @definition = create(:batale_definition)
    end

    it 'sets the correct association on text and definition' do
      word = @definition.words.create!(wrong: 'errada', right: 'correta', text_id: @text.id)
      expect(word.definition.texts).to eq([@text])
      expect(word.text.definitions).to eq([@definition])
    end
  end
end
