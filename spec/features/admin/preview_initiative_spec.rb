# frozen_string_literal: true

require 'spec_helper'

describe 'User previews initiative', type: :feature do
  include_context 'initiative administration'

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_initiatives.initiatives_path
  end

  context 'Initiative preview' do
    before do
      page.find('.action-icon--preview').click
    end

    it 'shows the details of the given initiative' do
      within_window(page.driver.browser.window_handles.last) do
        within 'main' do
          expect(page).to have_content(translated(initiative.title, locale: :en))
          expect(page).to have_content(ActionView::Base.full_sanitizer.sanitize(translated(initiative.description, locale: :en), tags: []))
          expect(page).to have_content(translated(initiative.type.title, locale: :en))
          expect(page).to have_content(translated(initiative.scope.name, locale: :en))
          expect(page).to have_content(initiative.author_name)
          expect(page).to have_content(initiative.hashtag)
        end
      end
    end
  end
end