require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

    attr_reader :id
    attr_accessor :name, :grade

    def initialize(name, grade, id=nil)
      self.name = name
      self.grade = grade
      @id = id
    end

    def self.create_table
      sql = <<-SQL
        CREATE TABLE IF NOT EXISTS students(
          id INTEGER PRIMARY KEY,
          name TEXT,
          grade TEXT
        )
      SQL
      DB[:conn].execute(sql)
    end

    def self.drop_table
      DB[:conn].execute("DROP TABLE students")
    end

    def save
      if self.id
        DB[:conn].execute("UPDATE students SET name=?, grade=? WHERE id=?", self.name, self.grade, self.id)
      else
        DB[:conn].execute("INSERT INTO students(name, grade) VALUES (?, ?)", self.name, self.grade)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
      end
    end

    def self.create(name, grade)
      student = self.new(name, grade)
      student.save
      student
    end

    def self.new_from_db(row)
      id = row[0]
      name = row[1]
      grade = row[2]
      student = self.new(name, grade, id)
    end

    def self.find_by_name(name)
      rows = DB[:conn].execute("SELECT * FROM students WHERE name=? LIMIT 1", name)
      rows.map do |row|
        self.new_from_db(row)
      end.first
    end

    def update
      DB[:conn].execute("UPDATE students SET name=?, grade=? WHERE id=?", self.name, self.grade, self.id)
    end
end
