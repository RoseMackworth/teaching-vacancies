namespace :data do
  desc 'Migrate vacancy working pattern'
  namespace :working_pattern do
    task migrate: :environment do
      Rails.logger.debug("Running vacancy working pattern migration task in #{Rails.env}")

      Vacancy.where.not(working_pattern: nil)
             .each do |vacancy|
        vacancy.working_patterns = [vacancy.working_pattern]
        vacancy.working_pattern = nil

        # Needed to preserve behaviour for existing listings.
        vacancy.flexible_working = false if vacancy.flexible_working.nil?

        if vacancy.working_patterns == ['part_time']
          # Needed to preserve behaviour for existing listings.
          vacancy.pro_rata_salary = true

          vacancy.flexible_working = nil if vacancy.flexible_working == true
        end

        vacancy.skip_update_callbacks
        vacancy.save!(validate: false)
      end
    end
  end
end
