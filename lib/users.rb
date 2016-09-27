require 'sqlite3'
require 'singleton'
require_relative 'questions'
require_relative 'replies'
require_relative 'question_like'
require_relative 'question_follow'

class UserDBConnection < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class User
  attr_accessor :fname, :lname
  attr_reader :id

  def self.all
    data = UserDBConnection.instance.execute("SELECT * FROM users")
    data.map { |datum| User.new(datum) }
  end

  def self.find_by_id(id)
    users = UserDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
      SQL
      return nil unless users.length > 0

      User.new(users.first)
  end


  def self.find_by_name(fname, lname)
    users = UserDBConnection.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
      SQL
      return nil unless users.length > 0

      User.new(users.first)
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def authored_questions
    questions = Question.find_by_author_id(@id)
  end

  def authored_replies
    replies = Reply.find_by_author(@id)
  end


end
question = Question.find_by_id(1)
mike = User.find_by_name('Mike', 'Barile')
p question.author
