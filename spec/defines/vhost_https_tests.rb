def vhost_https_tests(suffix = '')

  # HTTPS TESTS

  context 'with https (vhost)' do
    let(:params) {{
      :https            => true,
      :ssl_cert_content => 'foo',
      :ssl_key_content  => 'bar',
    }}

    it do
      should contain_file("/etc/nginx/sites-available/foobar#{suffix}") \
        .with_content(/^\s*ssl\s+on;$/) \
        .with_content(/^\s*ssl_certificate\s+\/etc\/nginx\/ssl\/foobar#{suffix}\.pem;$/) \
        .with_content(/^\s*ssl_certificate_key\s+\/etc\/nginx\/ssl\/foobar#{suffix}\.key;$/)
    end
  end

  context 'with https (certificate from content)' do
    let(:params) {{
      :https            => true,
      :ssl_cert_content => 'foo',
      :ssl_key_content  => 'bar',
    }}

    it do
      should contain_nginxpack__ssl__certificate("foobar#{suffix}").with(
        'ssl_cert_content' => 'foo',
        'ssl_key_content'  => 'bar',
        'ssl_cert_source'  => false,
        'ssl_key_source'   => false,
      )
    end
  end

  context 'with https (certificate from source)' do
    let(:params) {{
      :https           => true,
      :ssl_cert_source => 'foo',
      :ssl_key_source  => 'bar',
    }}

    it do
      should contain_nginxpack__ssl__certificate("foobar#{suffix}").with(
        'ssl_cert_content' => false,
        'ssl_key_content'  => false,
        'ssl_cert_source'  => 'foo',
        'ssl_key_source'   => 'bar',
      )
    end
  end
end
