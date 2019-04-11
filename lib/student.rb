require 'pry'
require_relative "../config/environment.rb"

class Student

  attr_accessor :id, :name, :grade

  def initialize(id = nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    DB[:conn].execute('CREATE TABLE students(id INTEGER PRIMARY KEY, name TEXT, grade INTEGER)')
  end

  def self.drop_table
    DB[:conn].execute('DROP TABLE students')
  end

  # def save
  #   if self.id == nil
  #     DB[:conn].execute('INSERT INTO students(name, grade) VALUES(?, ?)', self.name, self.grade)
  #     @id = DB[:conn].execute('SELECT last_insert_rowid() FROM students')[0][0]
  #   else
  #     self.update
  #   end
  # end
  # # Remember, you can access your database connection anywhere in this class
  # #  with DB[:conn]
  # # def self.new_from_db(row)
  # #   new_student = Student.new(row[1], row[2])
  # #   new_student.id = row[0]
  # #   new_student
  # # end
  #
  #
  # def self.find_by_name(name)
  #   row_arr = DB[:conn].execute('SELECT * FROM students WHERE name = ? LIMIT 1', name)
  #
  #   row_arr.map do |row|
  #     self.new_from_db(row)
  #   end.first
  #
  #   # binding.pry
  # end
  #
  # def self.create(name, grade)
  #   new_student = Student.new(name,grade)
  #   new_student.save
  # end
  #
  #
  #
  # def update
  #   DB[:conn].execute('UPDATE students SET name = ? AND grade = ? WHERE id = ?', self.name, self.grade, self.id)
  #
  #   # binding.pry
  #   # 0
  # end
  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.grade)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end

  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    grade = row[2]
    self.new(id, name, grade)
  end

  def self.find_by_name(name)
    # find the student in the database given a name
    # return a new instance of the Student class
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql,name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

end
