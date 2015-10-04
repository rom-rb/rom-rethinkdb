module PrepareDB
  def create_database(database)
    rql.db_create(database).run(connection)
  end

  def drop_database(database)
    rql.db_drop(database).run(connection)
  end

  def create_table(database, table)
    if table_exist?(database, table)
      clean_table(database, table)
    else
      rql.db(database).table_create(table).run(connection)
    end
  end

  def clean_table(database, table)
    rql.db(database).table(table).delete.run(connection)
  rescue RethinkDB::RqlOpFailedError
  end

  def table_exist?(database, table)
    table_list(database).include?(table.to_s)
  end

  def table_list(database)
    rql.db(database).table_list.run(connection)
  end

  def rql
    @rql ||= ::RethinkDB::RQL.new
  end

  def connection
    @connection ||= rql.connect(db_options)
  end

  def db_options
    { host: 'localhost', port: '28015' }
  end
end
