namespace :data do
  desc 'Convert subject fields to string array for vacancies without the new subject field'
  namespace :convert_subject_fields do
    task vacancies: :environment do
      updated_count = 0
      should_be_updated_count = Vacancy.where("subjects is NULL or subjects = '{}'").count

      Rails.logger.info(
        "Conversion of subject fields to string array has been started for #{should_be_updated_count} vacancies"
      )
      Rollbar.log(
        :info,
        "Conversion of subject fields to string array has been started for #{should_be_updated_count} vacancies"
      )

      Vacancy.where("subjects is NULL or subjects = '{}'").in_batches(of: 100).each_record do |vacancy|
        subject_name = vacancy.subject.present? ? vacancy.subject.name : nil
        first_subject_name = vacancy.first_supporting_subject.present? ? vacancy.first_supporting_subject.name : nil
        second_subject_name = vacancy.second_supporting_subject.present? ? vacancy.second_supporting_subject.name : nil

        subjects = [subject_name, first_subject_name, second_subject_name].reject(&:blank?)

        # rubocop:disable Rails/SkipsModelValidations
        vacancy.update_columns(subjects: subjects)
        # rubocop:enable Rails/SkipsModelValidations
        updated_count += 1
        Rails.logger.info("Updated vacancy: #{vacancy.job_title} with subjects: #{subjects}")
      end

      Rails.logger.info(
        "Conversion of subject fields to string arrays has been completed for #{updated_count} vacancies"
      )
      Rollbar.log(
        :info,
        "Conversion of subject fields to string arrays has been completed for #{updated_count} vacancies"
      )
    end
  end
end
