require 'rails_helper'

RSpec.describe "Dashboards", type: :request do
  describe "GET /1/dashboards" do
    it "works! (now write some real specs)" do
      get domain_dashboards_path(create(:domain))
      expect(response).to have_http_status(200)
    end
  end
end
