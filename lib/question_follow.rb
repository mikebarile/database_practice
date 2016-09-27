require 'sqlite3'
require 'singleton'

class QuestionFollowDBConnection < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class QuestionFollow
  attr_accessor :title, :body, :author_id
  attr_reader :id

  def self.all
    data = QuestionFollowDBConnection.instance.execute("SELECT * FROM questions")
    data.map { |datum| QuestionFollow.new(datum) }
  end

  def self.most_followed_questions(n)
    questions = QuestionFollowDBConnection.instance.execute(<<-SQL, n)
      WITH great_questions as (
        SELECT qf.question_id, count(qf.question_id)
        FROM  question_follows qf
        GROUP BY 1
        ORDER BY 2 desc
      )
      SELECT q.id, q.title, q.body, q.author_id
      FROM great_questions gq
      JOIN questions q on gq.question_id = q.id
      LIMIT ?
    SQL
    return nil unless questions.length > 0

    questions.map { |datum| Question.new(datum) }
  end


  def self.find_by_question_id(id)
    question = QuestionFollowDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        question_id = ?
      SQL
      return nil unless question.length > 0

      question.map { |datum| QuestionFollow.new(datum) }
  end

  def self.find_by_follower_id(id)
    question = QuestionFollowDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        follower_id = ?
      SQL
      return nil unless question.length > 0

      question.map { |datum| QuestionFollow.new(datum) }
  end

  def self.find_by_author_id(author_id)
    question = QuestionFollowDBConnection.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        author_id = ?
      SQL
      return nil unless question.length > 0

      question.map { |datum| QuestionFollow.new(datum) }
  end

  def self.followers_for_question_id(question_id)
    users = QuestionFollowDBConnection.instance.execute(<<-SQL, question_id)
      SELECT u.id, u.fname, u.lname
      FROM question_follows qf
      JOIN users u on qf.author_id = u.id
      WHERE qf.question_id = ?
    SQL
    return nil unless users.length > 0

    users.map { |datum| QuestionFollow.new(datum) }
  end

  def self.followers_for_user_id(user_id)
    users = QuestionFollowDBConnection.instance.execute(<<-SQL, user_id)
      SELECT u.id, u.fname, u.lname
      FROM question_follows qf
      JOIN users u on qf.author_id = u.id
      WHERE qf.author_id = ?
    SQL
    return nil unless users.length > 0

    users.map { |datum| QuestionFollow.new(datum) }
  end

  def self.followed_questions_for_user_id(user_id)
    users = QuestionFollowDBConnection.instance.execute(<<-SQL, user_id)
      SELECT q.id, q.title, q.body, q.author_id
      FROM question_follows qf
      JOIN questions q on q.id = qf.question_id
      WHERE qf.follower_id = ?
    SQL
    return nil unless users.length > 0

    users.map { |datum| QuestionFollow.new(datum) }
  end

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @follower_id = options['follower_id']
    @author_id = options['author_id']
  end


end
