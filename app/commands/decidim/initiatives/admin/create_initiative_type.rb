# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # A command with all the business logic that creates a new initiative type
      class CreateInitiativeType < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form)
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?
          initiative_type = create_initiative_type

          if initiative_type.persisted?
            broadcast(:ok, initiative_type)
          else
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form

        def create_initiative_type
          initiative_type = InitiativesType.new(
            organization: form.current_organization,
            title: form.title,
            description: form.description,
            supports_required: form.supports_required
          )

          return initiative_type unless initiative_type.valid?

          initiative_type.save
          initiative_type
        end
      end
    end
  end
end