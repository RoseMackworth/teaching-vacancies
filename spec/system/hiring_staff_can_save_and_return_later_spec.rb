require "rails_helper"

RSpec.describe "Hiring staff can save and return later" do
  let(:school) { create(:school) }
  let(:oid) { SecureRandom.uuid }

  before do
    stub_publishers_auth(urn: school.urn, oid: oid)
    @vacancy = VacancyPresenter.new(build(:vacancy, :draft))
  end

  context "Create a job journey" do
    describe "#job_details" do
      scenario "can save and return later" do
        visit organisation_path
        click_on I18n.t("buttons.create_job")

        expect(page.current_path).to eql(organisation_job_build_path(Vacancy.last.id, :job_details))
        expect(page).to have_content(I18n.t("jobs.create_a_job_title_no_org"))
        expect(page).to have_content(I18n.t("jobs.current_step", step: 1, total: 7))
        within("h2.govuk-heading-l") do
          expect(page).to have_content(I18n.t("jobs.job_details"))
        end

        fill_in "job_details_form[job_title]", with: @vacancy.job_title
        click_on I18n.t("buttons.save_and_return_later")
        created_vacancy = Vacancy.find_by(job_title: @vacancy.job_title)

        expect(page.current_path).to eql(jobs_with_type_organisation_path("draft"))
        expect(page.body).to include(I18n.t("messages.jobs.draft_saved_html", job_title: @vacancy.job_title))

        click_on "Edit"

        expect(page.current_path).to eql(organisation_job_build_path(created_vacancy.id, :job_details))
        expect(find_field("job_details_form[job_title]").value).to eql(@vacancy.job_title)
      end
    end

    describe "#pay_package" do
      scenario "can save and return later" do
        visit organisation_path
        click_on I18n.t("buttons.create_job")

        fill_in_job_details_form_fields(@vacancy)
        click_on I18n.t("buttons.continue")
        created_vacancy = Vacancy.find_by(job_title: @vacancy.job_title)

        expect(page.current_path).to eql(organisation_job_build_path(created_vacancy.id, :pay_package))

        fill_in "pay_package_form[benefits]", with: @vacancy.benefits
        click_on I18n.t("buttons.save_and_return_later")

        expect(page.current_path).to eql(jobs_with_type_organisation_path("draft"))
        expect(page.body).to include(I18n.t("messages.jobs.draft_saved_html", job_title: @vacancy.job_title))

        click_on "Edit"

        expect(page.current_path).to eql(organisation_job_build_path(created_vacancy.id, :pay_package))
        expect(find_field("pay_package_form[benefits]").value).to eql(@vacancy.benefits)
      end
    end

    describe "#important_dates" do
      scenario "can save and return later" do
        visit organisation_path
        click_on I18n.t("buttons.create_job")

        fill_in_job_details_form_fields(@vacancy)
        click_on I18n.t("buttons.continue")
        created_vacancy = Vacancy.find_by(job_title: @vacancy.job_title)

        fill_in_pay_package_form_fields(@vacancy)
        click_on I18n.t("buttons.continue")

        expect(page.current_path).to eql(organisation_job_build_path(created_vacancy.id, :important_dates))

        fill_in "important_dates_form[publish_on(3i)]", with: "12"
        fill_in "important_dates_form[publish_on(2i)]", with: "01"
        fill_in "important_dates_form[publish_on(1i)]", with: "2010"
        click_on I18n.t("buttons.save_and_return_later")

        expect(page.current_path).to eql(jobs_with_type_organisation_path("draft"))
        expect(page.body).to include(I18n.t("messages.jobs.draft_saved_html", job_title: @vacancy.job_title))

        click_on "Edit"

        expect(page.current_path).to eql(organisation_job_build_path(created_vacancy.id, :important_dates))
        expect(find_field("important_dates_form[publish_on(3i)]").value).to eql("12")
        expect(find_field("important_dates_form[publish_on(2i)]").value).to eql("1")
        expect(find_field("important_dates_form[publish_on(1i)]").value).to eql("2010")
      end

      scenario "redirected to important_dates if not valid" do
        visit organisation_path
        click_on I18n.t("buttons.create_job")

        fill_in_job_details_form_fields(@vacancy)
        click_on I18n.t("buttons.continue")
        created_vacancy = Vacancy.find_by(job_title: @vacancy.job_title)

        fill_in_pay_package_form_fields(@vacancy)
        click_on I18n.t("buttons.continue")

        expect(page.current_path).to eql(organisation_job_build_path(created_vacancy.id, :important_dates))

        fill_in_important_dates_fields(@vacancy)
        fill_in "important_dates_form[publish_on(3i)]", with: "12"
        fill_in "important_dates_form[publish_on(2i)]", with: "01"
        fill_in "important_dates_form[publish_on(1i)]", with: "2010"
        click_on I18n.t("buttons.save_and_return_later")

        expect(page.current_path).to eql(jobs_with_type_organisation_path("draft"))
        expect(page.body).to include(I18n.t("messages.jobs.draft_saved_html", job_title: @vacancy.job_title))

        click_on "Edit"

        expect(page.current_path).to eql(organisation_job_build_path(created_vacancy.id, :important_dates))
        expect(find_field("important_dates_form[publish_on(3i)]").value).to eql("12")
        expect(find_field("important_dates_form[publish_on(2i)]").value).to eql("1")
        expect(find_field("important_dates_form[publish_on(1i)]").value).to eql("2010")
      end
    end

    describe "#supporting_documents" do
      scenario "can save and return later" do
        visit organisation_path
        click_on I18n.t("buttons.create_job")

        fill_in_job_details_form_fields(@vacancy)
        click_on I18n.t("buttons.continue")
        created_vacancy = Vacancy.find_by(job_title: @vacancy.job_title)

        fill_in_pay_package_form_fields(@vacancy)
        click_on I18n.t("buttons.continue")

        fill_in_important_dates_fields(@vacancy)
        click_on I18n.t("buttons.continue")

        expect(page.current_path).to eql(organisation_job_build_path(created_vacancy.id, :supporting_documents))

        click_on I18n.t("buttons.save_and_return_later")

        expect(page.current_path).to eql(jobs_with_type_organisation_path("draft"))
        expect(page.body).to include(I18n.t("messages.jobs.draft_saved_html", job_title: @vacancy.job_title))

        click_on "Edit"

        expect(page.current_path).to eql(organisation_job_build_path(created_vacancy.id, :supporting_documents))
        expect(find_field("supporting-documents-form-supporting-documents-yes-field").checked?).to eql(false)
        expect(find_field("supporting-documents-form-supporting-documents-no-field").checked?).to eql(false)
      end
    end

    describe "#applying_for_the_job" do
      scenario "can save and return later" do
        visit organisation_path
        click_on I18n.t("buttons.create_job")

        fill_in_job_details_form_fields(@vacancy)
        click_on I18n.t("buttons.continue")
        created_vacancy = Vacancy.find_by(job_title: @vacancy.job_title)

        fill_in_pay_package_form_fields(@vacancy)
        click_on I18n.t("buttons.continue")

        fill_in_important_dates_fields(@vacancy)
        click_on I18n.t("buttons.continue")

        select_no_for_supporting_documents
        click_on I18n.t("buttons.continue")

        expect(page.current_path).to eql(organisation_job_build_path(created_vacancy.id, :applying_for_the_job))

        fill_in "applying_for_the_job_form[application_link]", with: "some link"
        click_on I18n.t("buttons.save_and_return_later")

        expect(page.current_path).to eql(jobs_with_type_organisation_path("draft"))
        expect(page.body).to include(I18n.t("messages.jobs.draft_saved_html", job_title: @vacancy.job_title))

        click_on "Edit"

        expect(page.current_path).to eql(organisation_job_build_path(created_vacancy.id, :applying_for_the_job))
        expect(find_field("applying_for_the_job_form[application_link]").value).to eql("some link")
      end
    end

    describe "#job_summary" do
      scenario "can save and return later" do
        visit organisation_path
        click_on I18n.t("buttons.create_job")

        fill_in_job_details_form_fields(@vacancy)
        click_on I18n.t("buttons.continue")
        created_vacancy = Vacancy.find_by(job_title: @vacancy.job_title)

        fill_in_pay_package_form_fields(@vacancy)
        click_on I18n.t("buttons.continue")

        fill_in_important_dates_fields(@vacancy)
        click_on I18n.t("buttons.continue")

        select_no_for_supporting_documents
        click_on I18n.t("buttons.continue")

        fill_in_applying_for_the_job_form_fields(@vacancy)
        click_on I18n.t("buttons.continue")

        expect(page.current_path).to eql(organisation_job_build_path(created_vacancy.id, :job_summary))

        fill_in "job_summary_form[job_summary]", with: ""
        fill_in "job_summary_form[about_school]", with: @vacancy.about_school
        click_on I18n.t("buttons.save_and_return_later")

        expect(page.current_path).to eql(jobs_with_type_organisation_path("draft"))
        expect(page.body).to include(I18n.t("messages.jobs.draft_saved_html", job_title: @vacancy.job_title))

        click_on "Edit"

        expect(page.current_path).to eql(organisation_job_build_path(created_vacancy.id, :job_summary))
        expect(find_field("job_summary_form[job_summary]").value).to eql("")
        expect(find_field("job_summary_form[about_school]").value).to eql(@vacancy.about_school)
      end
    end
  end
end
