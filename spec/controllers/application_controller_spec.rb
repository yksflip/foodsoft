# frozen_string_literal: true

require 'spec_helper'

describe ApplicationController, type: :controller do
  describe 'current' do
    it 'returns current ApplicationController' do
      ApplicationController.new.send(:store_controller)
      expect(ApplicationController.current).to be_instance_of ApplicationController
    end
  end
end
