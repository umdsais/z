require 'rails_helper'

describe 'moving urls to a group', js: true do
  before do
    @user = FactoryGirl.create(:user)
    sign_in(@user)

    @other_group = FactoryGirl.create(:group)
    @user.groups << @other_group
  end

  describe 'on the urls index page' do
    before do
      visit urls_path
    end

    describe 'with extra groups' do
      before do
        visit urls_path
      end

      describe 'without urls' do
        describe 'the table bulk actions button' do
          it 'should be disabled' do
            expect(page.find('.table-options')[:class]).to(
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
          describe 'the table buld actions button' do
            it 'should be disabled' do
              expect(page.find('.table-options')[:class]).to(
                have_content('disabled')
              )
            end
          end
        end

        describe 'selected' do
          before do
            find("#url-#{@url.id} .select-checkbox").click
          end

          describe 'the table bulk actions button' do
            it 'should be enabled' do
              expect(page.find('.table-options')[:class]).to_not(
                have_content('disabled')
              )
            end
          end

          describe 'clicking the move group button' do
            before {
              find('.table-options').click
              click_link 'Move to a different collection'
            }
            it 'should display the modal' do
              expect(page).to have_selector('#index-modal', visible: true)
            end

            describe 'filling out the form' do
              describe 'with valid information' do
                before do
                  find('.js-move-group-group button').click
                  find('.dropdown-menu.open li', text: @other_group.name).click
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
