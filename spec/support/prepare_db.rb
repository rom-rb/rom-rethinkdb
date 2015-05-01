module PrepareDB
  def create_database(database)
    drop_database(database)

    rql.db_create(database).run(connection)
  end

  def drop_database(database)
    database_exist?(database) && rql.db_drop(database).run(connection)
  end

  def database_exist?(database)
    database_list.include?(database.to_s)
  end

  def database_list
    rql.db_list.run(connection)
  end

  def create_table(database, table)
    drop_table(database, table)
    rql.db(database).table_create(table).run(connection)
  end

  def drop_table(database, table)
    if table_exist?(database, table)
      rql.db(database).table_drop(table).run(connection)
    end
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
