require File.dirname(__FILE__) + '/spec_helper'

describe Trakt do
  describe Trakt::Calendar do
    let(:trakt) do
      details = get_account_details
      Trakt.new(
        client_id: details['client_id'],
        client_secret: details['client_secret'],
        account_id: details['account_id'],
        token: details['token']
      )
    end
    context "shows" do
      it "fetches shows from calendar" do
        result = record(self) do
          trakt.calendar.shows('2024-01-01', 2)
        end
        result.first['show']['title'].should == "Example Show"
      end
    end

    context "premieres" do
      it "fetches premieres from calendar" do
        result = record(self) do
          trakt.calendar.premieres('2024-02-01', 1)
        end
        result.first['show']['title'].should == "Premiered Show"
      end
    end
  end
end
