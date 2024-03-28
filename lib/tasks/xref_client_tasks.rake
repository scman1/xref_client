# desc "Explaining what the task does"
# task :xref_client do
#   # Task goes here
# end
#lib/task/some_task.rake
Rake::Task['db:seed'].enhance ['seed_mappings']
