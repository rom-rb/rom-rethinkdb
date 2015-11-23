shared_context 'db setup' do
  let(:gateway) { container.gateways[:default] }
  let(:configuration) { ROM::Configuration.new(:rethinkdb, db_options.merge(db: 'test_db')).use(:macros) }
  let(:container) { ROM.container(configuration) }
end
