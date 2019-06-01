require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject

  def self.columns
    @columns ||= DBConnection.execute2("select * from #{table_name}")
    @columns.first.map { |ele| ele.to_sym }
  end

  def self.finalize!
    self.columns.each do |col|

      define_method("#{col}") do
        self.attributes[col]
      end

      define_method("#{col}=") do |val|
        self.attributes[col] = val
      end
    end
  end

  def self.table_name=(table_name)
    @table = table_name
  end

  def self.table_name
    @table ||= self.to_s.tableize
  end

  def self.all
    table = self.table_name
    result = DBConnection.execute("select * from #{table}")
    self.parse_all(result)
  end

  def self.parse_all(results)
    results.map do |ele|
      self.new(ele)
    end
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id)
      SELECT
        #{table_name}.id
      FROM
        #{table_name}
      WHERE
        #{table_name}.id = ?
    SQL

    self.parse_all(result).first
  end

  def initialize(params = {})
    obj = self.class
    params.each do |attr_name, v|
      if obj.columns.include?(attr_name.to_sym)
        send(attr_name.to_s + '=', v)
      else
        raise "unknown attribute '#{attr_name}'"
      end
    end

  end

  def attributes
    @attributes||= {}
  end

  def attribute_values
    # ...
  end

  def insert

  end

  def update
    # ...
  end

  def save
    # ...
  end
end
