require "spec_helper"
require 'pry'

describe "Student" do 

  let(:josh) {Student.new("Josh", "9th")}

  before(:each) do 
    DB[:conn].execute("DROP TABLE IF EXISTS students")
    sql =  <<-SQL 
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY, 
        name TEXT, 
        grade TEXT
        )
    SQL
    DB[:conn].execute(sql) 
  end

  describe "attributes" do 
    it 'has a name and a grade' do 
      student = Student.new("Tiffany", "11th")
      expect(student.name).to eq("Tiffany")
      expect(student.grade).to eq("11th")
    end

    it 'has an id that defaults to `nil` on initialization' do 
      expect(josh.id).to eq(nil)
    end
  end

  describe ".create_table" do 
    it 'creates the students table in the database' do
      Student.create_table 
      table_check_sql = "SELECT tbl_name FROM sqlite_master WHERE type='table' AND tbl_name='students';"
      expect(DB[:conn].execute(table_check_sql)[0]).to eq(['students'])
    end
  end

  describe "#drop_table" do 
    it 'drops the students table from the database' do 
      Student.drop_table
      table_check_sql = "SELECT tbl_name FROM sqlite_master WHERE type='table' AND tbl_name='students';"
      expect(DB[:conn].execute(table_check_sql)[0]).to eq(nil)
    end
  end

  describe "#save" do 
    it 'saves an instance of the Student class to the database and then sets the given students `id` attribute' do 
      sarah = Student.new("Sarah", "9th")
      sarah.save
      expect(DB[:conn].execute("SELECT * FROM students")).to eq([[1, "Sarah", "9th"]])
      expect(sarah.id).to eq(1)
    end
  end

  describe "#create" do 
    it 'takes in a hash of attributes and uses metaprogramming to create a new student object. Then it uses the #save method to save that student to the database' do 
      Student.create(name: "Sally", grade: "10th")
      expect(DB[:conn].execute("SELECT * FROM students")).to eq([[1, "Sally", "10th"]])
    end
  end

  describe '#new_from_db' do
    it 'creates an instance with corresponding attribute values' do
      row = [1, "Pat", 12]
      pat = Student.new_from_db(row)

      expect(pat.id).to eq(row[0])
      expect(pat.name).to eq(row[1])
      expect(pat.grade).to eq(row[2])
    end
  end

  describe '#find_by_name' do
    it 'returns an instance of student that matches the name from the DB' do
      josh.save
      josh_from_db = Student.find_by_name("Josh")
      expect(josh_from_db.name).to eq("Josh")
      expect(josh_from_db).to be_an_instance_of(Student)
    end
  end

  describe '#update' do
    it 'updates the record associated with a given instance' do 
      josh.save
      josh.name = "Josh Jr."
      josh.update
      josh_jr = Student.find_by_name("Josh Jr.")
      expect(josh_jr.id).to eq(josh.id)
    end 
  end




end