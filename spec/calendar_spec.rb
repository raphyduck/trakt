require File.dirname(__FILE__) + '/spec_helper'

describe Trakt::Calendar do
  subject(:calendar) { described_class.new(trakt) }

  let(:trakt) { Trakt::Trakt.new(account_id: 'account', client_id: 'client') }

  before do
    allow(calendar).to receive(:get_with_args).and_return([])
  end

  described_class::ROUTES.each do |method_name, (scope, segment)|
    describe "##{method_name}" do
      it "requests /calendars/#{scope}/#{segment}" do
        calendar.send(method_name, '2024-01-01', 3)

        expect(calendar).to have_received(:get_with_args).
          with("/calendars/#{scope}/#{segment}", '2024-01-01', 3)
      end
    end
  end

  describe '#my_movies' do
    it 'omits missing optional arguments' do
      calendar.my_movies('2024-02-02')

      expect(calendar).to have_received(:get_with_args).
        with('/calendars/my/movies', '2024-02-02')
    end
  end
end
