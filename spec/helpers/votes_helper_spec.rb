require 'rails_helper'

RSpec.describe VotesHelper, type: :helper do
  describe 'oneregex' do
    it 'generates regex that matches all input codes' do
      codes = Array.new(10) { |_| generate :code }
      expect(codes).to all(
        match(Regexp.new(oneregex(codes), Regexp::IGNORECASE)),
      )
    end

    it 'handles speical format of FC2' do
      codes = ['FC2-PPV 012345']
      variants = [
        'FC2-PPV 012345',
        'FC2-PPV 12345',
        'FC2PPV 12345',
        'FC2 12345',
        'FC2-12345',
      ]
      expect(variants).to all(
        match(Regexp.new(oneregex(codes), Regexp::IGNORECASE)),
      )
    end

    it 'handles speical format of S-Cute' do
      codes = ['S-Cute 223_miho_01']
      variants = [
        'S-Cute 223_miho_01',
        'S-Cute #223 miho #1',
      ]
      expect(variants).to all(
        match(Regexp.new(oneregex(codes), Regexp::IGNORECASE)),
      )
    end
  end
end
