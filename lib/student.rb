require_relative "../config/environment.rb"
require 'pry'
class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_accessor :name, :grade
  attr_reader :id
  def initialize(name,grade,id=nil)
    @name=name
    @grade=grade
    @id=id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end

  def save
    if @id == nil then 
      sql = <<-SQL
        INSERT INTO students (name, grade) 
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    else
      self.update
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM students WHERE name = ?
    SQL
    
    found = DB[:conn].execute(sql, name).map { |row|
      self.new_from_db(row)
    }.first
    #binding.pry
    found
  end

  def self.create(name,grade)
    new_student=Student.new(name,grade)
    new_student.save
  end

def self.new_from_db(row)
  # create a new Student object given a row from the database
  new_student = self.new(row[1],row[2],row[0])
  new_student
end

  def update
    sql = <<-SQL
    UPDATE students
    SET 
    name = ?,
    grade = ?
    WHERE id=?
  SQL
  
  DB[:conn].execute(sql,self.name,grade,self.id)
end

end
