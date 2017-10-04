# frozen_string_literal: true

require 'spec_helper'

module Decidim
  module Initiatives
    describe InitiativeVotesController, type: :controller do
      routes { Decidim::Initiatives::Engine.routes }

      let(:organization) { create(:organization) }
      let(:initiative) { create(:initiative, organization: organization) }

      before do
        @request.env['decidim.current_organization'] = organization
      end

      context 'POST create' do
        context 'Authorized users' do
          before do
            initiative.author.confirm
            sign_in initiative.author
          end

          it 'Authorized users can vote' do
            expect do
              post :create, params: { initiative_id: initiative.to_param, format: :js }
            end.to change { InitiativesVote.count }.by(1)
          end
        end

        context 'Non authorized users' do
          let(:user) { create(:user, organization: initiative.organization) }

          before do
            user.confirm
            sign_in user
          end

          it 'raise an exception' do
            post :create, params: { initiative_id: initiative.to_param, format: :js }
            expect(flash[:alert]).not_to be_empty
            expect(response).to have_http_status(302)
          end

          it 'do not register the vote' do
            expect do
              post :create, params: { initiative_id: initiative.to_param, format: :js }
            end.not_to change { InitiativesVote.count }
          end
        end

        context 'Guest users' do
          it 'receives unauthorized response' do
            post :create, params: { initiative_id: initiative.to_param, format: :js }
            expect(response).to have_http_status(401)
          end

          it 'do not register the vote' do
            expect do
              post :create, params: { initiative_id: initiative.to_param, format: :js }
            end.not_to change { InitiativesVote.count }
          end
        end
      end

      context 'DELETE destroy' do
        let!(:vote) { create(:initiative_user_vote, initiative: initiative, author: initiative.author) }

        context 'Authorized users' do
          before do
            initiative.author.confirm
            sign_in initiative.author
          end

          it 'Authorized users can unvote' do
            expect(vote).not_to be_nil

            expect do
              delete :destroy, params: { initiative_id: initiative.to_param, format: :js }
            end.to change { InitiativesVote.count }.by(-1)
          end
        end
      end
    end
  end
end