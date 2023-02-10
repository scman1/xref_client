Rails.application.routes.draw do
  mount XrefClient::Engine => "/xref_client"
end
