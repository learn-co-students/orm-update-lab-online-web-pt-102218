require_relative "../config/environment.rb"
require 'pry'
class Student

  attr_accessor :id, :name, :grade
  @@all = []

  def initialize (name, grade, id = nil)
    @id = id unless id == nil
    @name = name
    @grade = grade
    @@all << self
  end

  def self.create_table
    sql = <<-SQL
          CREATE TABLE IF NOT EXISTS students (
            id INTEGER PRIMARY KEY,
            name TEXT,
            grade INTEGER
          );
          SQL

      DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE students"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      update
    else
      sql = "INSERT INTO students (name, grade) VALUES (?, ?)"
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.create(name, grade)
    student = self.new(name, grade)
    student.save
    student
  end

  def self.new_from_db(row)
    out = self.new(row[1],row[2],row[0])
    out
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM students WHERE name = ?"
    out = DB[:conn].execute(sql, name)[0]
    # row.each do |i|
      self.new_from_db(out)
    #end
  end

end
