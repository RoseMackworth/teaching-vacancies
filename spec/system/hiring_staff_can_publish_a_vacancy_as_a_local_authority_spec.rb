require "rails_helper"

RSpec.describe "Creating a vacancy" do
  let(:school_group) { create(:local_authority) }
  let(:school_1) { create(:school, name: "First school") }
  let(:school_2) { create(:school, name: "Second school") }
  let(:session_id) { SecureRandom.uuid }

  before do
    allow(LocalAuthorityAccessFeature).to receive(:enabled?).and_return(true)
    SchoolGroupMembership.find_or_create_by(school_id: school_1.id, school_group_id: school_group.id)
    SchoolGroupMembership.find_or_create_by(school_id: school_2.id, school_group_id: school_group.id)
    allow(PublisherPreference).to receive(:find_by).and_return(instance_double(PublisherPreference))
    stub_hiring_staff_auth(la_code: school_group.local_authority_code, session_id: session_id)
  end

  context "when job is located at a single school in the local authority" do
    let(:vacancy) { build(:vacancy, :at_one_school, :complete) }

    describe "#job_location" do
      context "when no school is selected" do
        scenario "displays error message" do
          visit organisation_path
          click_on I18n.t("buttons.create_job")

          expect(page).to have_content(I18n.t("jobs.current_step", step: 1, total: 8))
          within("h2.govuk-heading-l") do
            expect(page).to have_content(I18n.t("jobs.job_location"))
          end

          fill_in_job_location_form_field(vacancy)
          click_on I18n.t("buttons.continue")

          expect(page).to have_content(I18n.t("jobs.current_step", step: 1, total: 8))
          within("h2.govuk-heading-l") do
            expect(page).to have_content(I18n.t("jobs.job_location"))
          end

          click_on I18n.t("buttons.continue")

          expect(page).to have_content(I18n.t("jobs.current_step", step: 1, total: 8))
          within("h2.govuk-heading-l") do
            expect(page).to have_content(I18n.t("jobs.job_location"))
          end
          within("div.govuk-error-summary") do
            expect(page).to have_content(I18n.t("schools_errors.organisation_ids.blank"))
          end
        end
      end

      context "when a school is selected" do
        scenario "redirects to job details when submitted successfully" do
          visit organisation_path
          click_on I18n.t("buttons.create_job")

          expect(page).to have_content(I18n.t("jobs.current_step", step: 1, total: 8))
          within("h2.govuk-heading-l") do
            expect(page).to have_content(I18n.t("jobs.job_location"))
          end

          fill_in_job_location_form_field(vacancy)
          click_on I18n.t("buttons.continue")

          expect(page).to have_content(I18n.t("jobs.current_step", step: 1, total: 8))
          within("h2.govuk-heading-l") do
            expect(page).to have_content(I18n.t("jobs.job_location"))
          end

          fill_in_school_form_field(school_1)
          click_on I18n.t("buttons.continue")

          expect(page).to have_content(I18n.t("jobs.current_step", step: 2, total: 8))
          within("h2.govuk-heading-l") do
            expect(page).to have_content(I18n.t("jobs.job_details"))
          end
        end
      end
    end
  end

  context "when job is located at multiple schools in the local authority" do
    let(:vacancy) { build(:vacancy, :at_multiple_schools, :complete) }

    describe "#job_location" do
      context "when only 1 school is selected" do
        scenario "displays error message" do
          visit organisation_path
          click_on I18n.t("buttons.create_job")

          expect(page).to have_content(I18n.t("jobs.current_step", step: 1, total: 8))
          within("h2.govuk-heading-l") do
            expect(page).to have_content(I18n.t("jobs.job_location"))
          end

          fill_in_job_location_form_field(vacancy)
          click_on I18n.t("buttons.continue")

          expect(page).to have_content(I18n.t("jobs.current_step", step: 1, total: 8))
          within("h2.govuk-heading-l") do
            expect(page).to have_content(I18n.t("jobs.job_location"))
          end

          check school_1.name, name: "schools_form[organisation_ids][]", visible: false
          click_on I18n.t("buttons.continue")

          expect(page).to have_content(I18n.t("jobs.current_step", step: 1, total: 8))
          within("h2.govuk-heading-l") do
            expect(page).to have_content(I18n.t("jobs.job_location"))
          end
          within("div.govuk-error-summary") do
            expect(page).to have_content(I18n.t("schools_errors.organisation_ids.invalid"))
          end
        end
      end

      context "when 2 schools are selected" do
        scenario "redirects to job details when submitted successfully" do
          visit organisation_path
          click_on I18n.t("buttons.create_job")

          expect(page).to have_content(I18n.t("jobs.current_step", step: 1, total: 8))
          within("h2.govuk-heading-l") do
            expect(page).to have_content(I18n.t("jobs.job_location"))
          end

          fill_in_job_location_form_field(vacancy)
          click_on I18n.t("buttons.continue")

          expect(page).to have_content(I18n.t("jobs.current_step", step: 1, total: 8))
          within("h2.govuk-heading-l") do
            expect(page).to have_content(I18n.t("jobs.job_location"))
          end

          check school_1.name, name: "schools_form[organisation_ids][]", visible: false
          check school_2.name, name: "schools_form[organisation_ids][]", visible: false
          click_on I18n.t("buttons.continue")

          expect(page).to have_content(I18n.t("jobs.current_step", step: 2, total: 8))
          within("h2.govuk-heading-l") do
            expect(page).to have_content(I18n.t("jobs.job_details"))
          end
        end
      end
    end
  end
end
