# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VotesHelper, type: :helper do
  describe 'oneregex' do
    it 'generates regex that matches all input codes' do
      codes = Array.new(10) { |_| generate :code }
      expect(codes).to all(
        match(Regexp.new(oneregex(codes), Regexp::IGNORECASE)),
      )
    end

    it 'matches variants' do
      codes = ['ABC-123']
      variants = [
        'ABC0123',
        'ABC-00123',
        'ABC_000123',
        'ABC 0000123',
      ]
      expect(variants).to all(
        match(Regexp.new(oneregex(codes), Regexp::IGNORECASE)),
      )
    end

    it 'doesn not match brackets' do
      codes = ['ABC-123']
      expect('(ABC)123').not_to match(
        Regexp.new(oneregex(codes), Regexp::IGNORECASE),
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
