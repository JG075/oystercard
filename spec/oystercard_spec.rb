require 'oystercard'


describe OysterCard do
  subject(:card) { described_class.new }
  let(:card_topped_up) { described_class.new(90, 1) }
  let(:entry_station) { double :station }
  let(:exit_station) { double :station }

  describe "#top_up" do
    context "when top_up is given a value" do
      it 'adds top-up to balance' do
        card.top_up(0)
        expect(card.balance).to eq 0
      end
    end

    context "when given a balance more than 90" do
      it 'raises an error' do
        card.top_up(90)
        expect {card.top_up(5)}.to raise_error "balance cannot exceed #{OysterCard::MAX_LIMIT} pounds"
      end
    end
  end

  describe "#touch_in" do
    context "when balance is less than fare" do
      it "raises an error" do
        expect{card.touch_in(entry_station)}.to raise_error "do not have enough money"
      end
    end

    context "check entry station is saved" do
      it "station is saved" do
        card_topped_up.touch_in(entry_station)
        expect(card_topped_up.journey_log.journey.entry_station).not_to be nil
      end
    end
  end

  describe "#touch_out" do
    context "when card touches out" do
      before :each do
        card_topped_up.touch_in(entry_station)
        card_topped_up.touch_out(exit_station)
      end
    end

    context 'when already touched out' do
      it "deducts the minimum fare from the balance" do
        entry_station = Station.new("waterloo", 1)
        exit_station = Station.new("liverpool", 1)
        card_topped_up.touch_in(entry_station)
        expect {card_topped_up.touch_out(exit_station)}.to change{card_topped_up.balance}.by(-(OysterCard::MIN_FARE))
      end
    end
  end

  describe "#in_journey?" do
    context "when card is initialized" do
      it "it is not in journey" do
        expect(card.journey_log.journey.in_journey?).to be false
      end
    end
  end


end
