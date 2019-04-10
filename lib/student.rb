require 'pry'
require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_accessor :name, :grade, :id


  def initialize(name, grade, id = nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    #creates the students table in the database
    DB[:conn].execute('CREATE TABLE students (id INTEGER PRIMARY KEY, name TEXT, grade INTEGER)')
  end

  def self.drop_table
    #drops the students table from the database
    DB[:conn].execute('DROP TABLE students')
  end

  def save
    # saves an instance of the Student class to the database and then sets the given students `id` attribute
    # updates a record if called on an object that is already persisted
    if self.id == nil
      a = DB[:conn].execute('INSERT INTO students (name, grade) VALUES (?,?)',self.name, self.grade)
      @id = DB[:conn].execute('SELECT id FROM students WHERE name = ? AND grade = ?',self.name, self.grade).flatten[0]
    else
      DB[:conn].execute('UPDATE students SET name = ?, grade = ? WHERE id = ?',self.name, self.grade, self.id)
    end
  end

  def self.create(name,grade)
    #takes in a hash of attributes and uses metaprogramming to create a new student object. Then it uses
    #the #save method to save that student to the database
    #returns the new object that it instantiated
    new_student = Student.new(name,grade)
    new_student.save
    new_student
  end

  def self.new_from_db(new_student)
    #creates an instance with corresponding attribute values
    Student.new(new_student[1],new_student[2],new_student[0])
  end

  def self.find_by_name(name)
    #returns an instance of student that matches the name from the DB
    Student.new_from_db(DB[:conn].execute('SELECT * FROM students WHERE name = (?)',name).flatten)
  end

  def update
    #updates the record associated with a given instance
    DB[:conn].execute('UPDATE students SET name = ?, grade = ? WHERE id = ?',self.name, self.grade, self.id)
  end

end
