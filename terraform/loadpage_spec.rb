# frozen_string_literal: true

# response.body.should have_content("Hello world")

require 'rails_helper'
require File.expand_path('../config/environment', __dir__)

describe ArticlesController do
  render_views

  describe "GET 'index'" do
    it 'returns http success' do
      get :index
      expect(response).to be_success
    end
  end
end
