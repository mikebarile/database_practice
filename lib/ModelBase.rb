require 'sqlite3'
require 'singleton'
require 'active_support/inflector'

class UserDBConnection < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class ModelBase

  def self.table
    self.to_s.tableize
  end

  def self.options(opts)
    p opts
    return "AND #{opts}" if opts.is_a?(String)
    string = ""
    opts.each{|key, value| string << "AND #{key} = '#{value}' "}
    string
  end

  def self.all
    table = self.to_s.tableize
    data = UserDBConnection.instance.execute(<<-SQL)
    SELECT *
    FROM #{table}
    SQL
    data.map { |datum| self.new(datum) }
  end

  def self.find_by_id(id)
    data = UserDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table}
      WHERE
        id = ?
      SQL
      return nil unless data.length > 0

      self.new(data.first)
  end

  def self.where(opts)
    data = UserDBConnection.instance.execute(<<-SQL)
    SELECT *
    FROM #{table}
    WHERE 1=1 #{options(opts)}
    SQL
    data.map { |datum| self.new(datum) }
  end

  def self.method_missing(method_name, *args)
    method_name = method_name.to_s
    if method_name.start_with?("find_by_")
      text = method_name[("find_by_".length)..-1]
      text = text.split("_and_")
      unless text.length == args.length
        raise "unexpected # of arguments"
      end
      search_conditions = {}
      text.each_index do |i|
        search_conditions[text[i]] = args[i]
      end
      self.where(search_conditions)
    else
      super
    end
  end
end
