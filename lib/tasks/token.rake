namespace :haenawa do
  namespace :token do
    desc 'APIトークンを取得します'
    task(get: :environment) do
      puts("APIトークン: #{HaenawaConst::API_TOKEN}")
    end
  end
end
