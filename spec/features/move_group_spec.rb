require 'rails_helper'

describe 'urls index page' do
  before do
    @user = FactoryGirl.create(:user)
    sign_in(@user)
  end

  describe 'moving urls to a group', js: true do
    before do
      visit urls_path
    end

    describe 'with no extra groups' do
      describe 'the move group button' do
        it 'should not be visible' do
          expect(page).to_not have_link 'Move to group'
        end
      end
    end
    describe 'with extra groups' do
      before do
        @other_group = FactoryGirl.create(:group)
        @user.groups << @other_group
        visit urls_path
      end

      describe 'without urls' do
        describe 'the move group button' do
          it 'should be visible' do
            expect(page).to have_link 'Move to group'
          end
          it 'should be disabled' do
            expect(page.find_link('Move to group')[:class]).to(
              have_content('disabled')
            )
          end
        end
      end

      describe 'with urls' do
        before do
          @url = FactoryGirl.create(:url, group: @user.context_group)
          visit urls_path
        end

        describe 'none selected' do
          describe 'the move group button' do
            it 'should be visible' do
              expect(page).to have_link 'Move to group'
            end
            it 'should be disabled' do
              expect(page.find_link('Move to group')[:class]).to(
                have_content('disabled')
              )
            end
          end
        end

        describe 'selected' do
          before do
            find("#url-#{@url.id} > .select-checkbox").click
          end

          describe 'the move group button' do
            it 'should be enabled' do
              expect(page.find_link('Move to group')[:class]).to_not(
                have_content('disabled')
              )
            end
          end

          describe 'clicking the move group button' do
            before { click_link 'Move to group' }
            it 'should display the modal' do
              expect(page).to have_selector('#index-modal', visible: true)
            end

            describe 'filling out the form' do
              describe 'with valid information' do
                before do
                  find('.js-move-group-group').set @other_group.id
                end
                it 'should move url immediately' do
                  expect do
                    find('#move_group  input[type="submit"]').click
                    click_button 'Confirm'
                    wait_for_ajax
                    @url.reload
                  end.to change(@url, :group_id).to(@other_group.id)
                end
              end
            end
          end
        end
      end
    end
  end
end
