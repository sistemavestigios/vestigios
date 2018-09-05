require 'rails_helper'

RSpec.describe Batale::Errortog, type: :model do
  describe 'validations' do
    it { is_expected.to have_many(:definitions) }
    it { is_expected.to validate_presence_of(:name) }

    it { is_expected.to accept_nested_attributes_for(:child_errortogs) }
    it { is_expected.to accept_nested_attributes_for(:definitions) }
  end

  describe 'methods' do
    before(:each) do
      @fonologico = create(:batale_errortog, :with_children)
      @segmental = @fonologico.child_errortogs.first
      @ortografico = create(:batale_errortog, name: 'Ortográfico')
      @contextual = @ortografico.child_errortogs.create(name: 'Contextual')
    end

    describe '.find' do
      it 'raises an error if no document is found' do
        expect do
          Batale::Errortog.find(0)
        end.to raise_error(Mongoid::Errors::DocumentNotFound)
      end

      context 'base classes' do
        it 'returns the requested objects' do
          expect(Batale::Errortog.find(@fonologico.id)).to eq(@fonologico)
          expect(Batale::Errortog.find(@ortografico.id)).to eq(@ortografico)
        end
      end

      context 'subclasses' do
        it 'returns the requested objects' do
          expect(Batale::Errortog.find(@segmental.id)).to eq(@segmental)
          expect(Batale::Errortog.find(@contextual.id)).to eq(@contextual)
        end
      end
    end

    describe '.get_all_errortogs' do
      it 'returns an array with all errortogs, including embedded' do
        expect(Batale::Errortog.get_all_errortogs).to eq([@fonologico, @segmental, @ortografico, @contextual])
      end

      context 'when Batale::Errortog is empty' do
        it 'returns an empty array' do
          Batale::Errortog.destroy_all
          expect(Batale::Errortog.get_all_errortogs).to eq([])
        end
      end
    end
  end
end
