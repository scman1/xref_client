# desc "Add the mappings to the host app db"
task 'seed_mappings' do
  XrefClient::Engine.load_seed
end

