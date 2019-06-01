require 'rake'
require 'fileutils'

namespace :haenawa do
  namespace :scenario do

    desc '/data/haenawa/haenawa_db名/upload_store/プロジェクト番号/scenarios/で作成したhtmlのシナリオのデータ状態にシナリオのステップを戻します'
    namespace :steps do
      task :restore => :environment do
        puts 'プロジェクトのシナリオのステップを復旧中'
        projects = Project.where(:deleted => false)
        project_ids = projects.pluck(:id)
        scenarios = Scenario.where(:project_id => project_ids, :deleted => false)

        projects.each do |p|
          FileUtils.rm Dir.glob(File.join(p.feature_dir, 'step_definitions', '*'))
        end

        scenarios.each do |scenario|
          @scenario = scenario
          @scenario.transaction do
            @scenario.parsed_file.to_enum(:each_step).with_index do |step, i|
              s = scenario.steps.find_by(:steppable_id => @scenario.id, :step_no => i + 1)
              s.command = step[:command]
              s.target = step[:target]

              if s.should_mask?
                s.encrypted_value = s.encrypt_and_sign(step[:value])
                s.value = ''
              else
                s.value = step[:value]
                s.encrypted_value = ''
              end

              s.save!
            end
          end
          step_template = File.join('lib', 'selenium', 'features', 'step_definitions', 'selenium.rb.erb')
          step_file = File.join(Project.find(@scenario.project_id).feature_dir, 'step_definitions', "scenario_#{@scenario.id}.rb")
          File.write(step_file, ERB.new(File.read(step_template), 0, '-').result(binding))
        end

        puts 'シナリオのステップを復旧させました。'
      end
    end

  end
end
