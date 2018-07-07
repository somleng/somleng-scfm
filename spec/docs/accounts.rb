module Docs
  module Accounts
    extend Dox::DSL::Syntax

    # define common resource data for each action
    document :api do
      resource "Accounts" do
        endpoint "/accounts"
        group "Accounts"
      end

      group "Accounts" do
        desc "The Accounts API is only accessible for super admins. A super admin account can manage other accounts."
      end
    end

    document :index do
      action "Get accounts"
    end

    document :show do
      action "Get an account"
    end

    document :create do
      action "Create an account"
    end

    document :update do
      action "Update an account"
    end

    document :destroy do
      action "Destroy an account"
    end
  end
end
