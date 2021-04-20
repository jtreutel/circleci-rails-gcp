# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'articles/index.html.erb', type: :view do
  it "displays the index page" do
    render

    rendered.should include("Lorem ipsum")
    #response.body.should have_content("Lorem ipsum")
  end
end
