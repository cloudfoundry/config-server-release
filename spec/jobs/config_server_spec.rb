require 'bosh/template/test'
require 'yaml'
require 'json'

describe 'config_server' do
  let(:release) { Bosh::Template::Test::ReleaseDir.new(File.join(File.dirname(__FILE__), '../..')) }
  let(:job) { release.job('config_server') }

  describe 'config/bpm.yml' do
    let(:template) { job.template('config/bpm.yml') }
    let(:rendered) { template.render({}) }
    let(:bpm) { YAML.safe_load(rendered) }
    let(:processes) { bpm.fetch('processes') }

    it 'defines exactly one process named config_server' do
      expect(processes.length).to eq(1)
      expect(processes.first['name']).to eq('config_server')
    end

    it 'runs the config-server binary' do
      expect(processes.first['executable']).to eq('/var/vcap/packages/config_server/bin/config-server')
    end

    it 'passes the absolute config.json path as its sole arg' do
      expect(processes.first['args']).to eq(['/var/vcap/jobs/config_server/config/config.json'])
    end
  end

  describe 'config/config.json' do
    let(:template) { job.template('config/config.json') }

    it 'still renders the memory store config by default' do
      config = JSON.parse(template.render({}))
      expect(config['store']).to eq('memory')
      expect(config['port']).to eq(8080)
    end

    it 'renders database store config when requested' do
      config = JSON.parse(template.render({ 'store' => 'database', 'db' => { 'password' => 'secret' } }))
      expect(config['store']).to eq('database')
      expect(config['database']['adapter']).to eq('postgres')
    end
  end
end
