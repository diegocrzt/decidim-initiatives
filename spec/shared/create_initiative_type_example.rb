# frozen_string_literal: true

shared_examples 'create an initiative type' do
  let(:organization) { create(:organization) }

  let(:form) do
    form_klass.from_params(
      form_params
    ).with_context(
      current_organization: organization,
      current_feature: nil
    )
  end

  describe 'call' do
    let(:form_params) do
      {
        title: Decidim::Faker::Localized.sentence(5),
        description: Decidim::Faker::Localized.sentence(25),
        supports_required: 1000
      }
    end

    let(:command) do
      described_class.new(form)
    end

    describe 'when the form is not valid' do
      before do
        expect(form).to receive(:invalid?).and_return(true)
      end

      it 'broadcasts invalid' do
        expect { command.call }.to broadcast(:invalid)
      end

      it "doesn't create an initiative type" do
        expect do
          command.call
        end.not_to change { Decidim::InitiativesType.count }
      end
    end

    describe 'when the form is valid' do
      it 'broadcasts ok' do
        expect { command.call }.to broadcast(:ok)
      end

      it 'creates a new initiative type' do
        expect do
          command.call
        end.to change { Decidim::InitiativesType.count }.by(1)
      end
    end
  end
end