# desc "Add the mappings to the host app db"
task 'seed_mappings' do
  puts "seeding the DB"
  XrefClient::Engine.load_seed
end

