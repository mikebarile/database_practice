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

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end

  def authored_questions
    questions = Question.find_by_author_id(@id)
  end

  def authored_replies
    replies = Reply.find_by_author(@id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(user_id)
  end

  def average_karma(id = @id)
    karma = UserDBConnection.instance.execute(<<-SQL, id)
      WITH total_likes as (
        SELECT question_id, count(liker_id) total_likes
        FROM question_likes
        WHERE author_id = ?
        GROUP BY 1
      )
      SELECT avg(ql.total_likes)
      FROM total_likes ql
    SQL
    return nil unless karma.length > 0

    karma[0].values[0]
  end

  def create
    raise "#{self} already in database" if @id
    UserDBConnection.instance.execute(<<-SQL, @fname, @lname, @id)
      INSERT INTO
        users (fname, lname, id)
      VALUES
        (?, ?, ?)
    SQL
    @id = UserDBConnection.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    UserDBConnection.instance.execute(<<-SQL, @fname, @lname, @id)
      UPDATE
        users
      SET
        fname = ?, lname = ?
      WHERE
        id = ?
    SQL
  end
end

mike = User.new({'id' => 9, 'fname' => 'donald', 'lname' => 'duck'})
mike.create
