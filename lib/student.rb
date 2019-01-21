require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  
  attr_accessor :name, :grade
  attr_reader :id
  
  def initialize(name, grade, id = nil)
    @name = name
    @grade = grade
    @id = id
  end
  
  def self.create_table
    sql = <<-SQL
              CREATE TABLE IF NOT EXISTS students(
                id INTEGER PRIMARY KEY,
                name TEXT,
                grade INTEGER);
              SQL
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    DB[:conn].execute("DROP TABLE students;")
  end
  
  def save
    # save the current instance to the database
    # sets the current instance's id attribute
    if self.id
      self.update
    else
      # this instance is not yet in the database
      sql = <<-SQL
                INSERT INTO students(name, grade)
                VALUES (?, ?);
              SQL
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students;")[0][0]
    end
    return self
  end
  
  def self.create(name, grade)
    new_student = new(name, grade)
    new_student.save
    return new_student
  end
  
  def self.new_from_db(db_row_arr)
    new(db_row_arr[1], db_row_arr[2], db_row_arr[0])
    # creates an instance with corresponding attribute values
  end
  
  def self.find_by_name(name)
    # returns an instance of student that matches the name from the DB
    sql = <<-SQL
              SELECT * FROM students
              WHERE name = ?;
            SQL
    new_from_db(DB[:conn].execute(sql, name)[0])
  end
  
  def update
    # updates the record associated with a given instance
    sql = <<-SQL
              UPDATE students
              SET name = ?, grade = ?
              WHERE id = ?;
            SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
    return self
  end

end
