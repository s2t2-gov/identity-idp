require 'rails_helper'

feature 'Visitor signs up with email address' do
  scenario 'visitor can sign up with valid email address' do
    email = 'test@example.com'
    sign_up_with(email)

    expect(page).to have_content t('notices.signed_up_but_unconfirmed.first_paragraph_start')
    expect(page).to have_content t('notices.signed_up_but_unconfirmed.first_paragraph_end')
    expect(page).
      to have_content t('notices.signed_up_but_unconfirmed.no_email_sent_explanation_start')
    expect(page).to have_content email
    expect(page).to have_link(t('links.resend'), href: new_user_confirmation_path)
  end

  scenario 'visitor cannot sign up with invalid email address' do
    sign_up_with('bogus')
    expect(page).to have_content t('valid_email.validations.email.invalid')
  end

  scenario 'visitor cannot sign up with empty email address', js: true do
    sign_up_with('')

    expect(page).to have_content('Please fill in this field')
  end

  scenario 'visitor cannot sign up with email with invalid domain name' do
    invalid_addresses = [
      'foo@bar.com',
      'foo@example.com'
    ]
    allow(ValidateEmail).to receive(:mx_valid?).and_return(false)

    invalid_addresses.each do |email|
      sign_up_with(email)
      expect(page).to have_content t('valid_email.validations.email.invalid')
    end
  end

  scenario 'visitor cannot sign up with empty email address' do
    sign_up_with('')

    expect(page).to have_content(invalid_email_message)
  end

  context 'user signs up and sets password, tries to sign up again' do
    it 'sends email saying someone tried to sign up with their email address' do
      user = create(:user)

      expect { sign_up_with(user.email) }.
        to change { ActionMailer::Base.deliveries.count }.by(1)

      expect(last_email.html_part.body).to have_content(
        t('user_mailer.signup_with_your_email.intro', app: APP_NAME)
      )
    end
  end
end