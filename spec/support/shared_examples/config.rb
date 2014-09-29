shared_examples "config credentials" do
  let(:config) do
    {
      mk_denial_service_login: ENV['MK_DENIAL_SERVICE_LOGIN'],
      mk_denial_service_password: ENV['MK_DENIAL_SERVICE_PASSWD']
    }
  end
end
