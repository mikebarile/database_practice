require 'sqlite3'
require 'singleton'

class QuestionDBConnection < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class Question
  attr_accessor :title, :body, :author_id
  attr_reader :id

  def self.all
    data = QuestionDBConnection.instance.execute("SELECT * FROM questions")
    data.map { |datum| Question.new(datum) }
  end

  def self.find_by_id(id)
    question = QuestionDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
      SQL
      return nil unless question.length > 0

      Question.new(question.first)
  end

  def self.find_by_author_id(author_id)
    question = QuestionDBConnection.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        author_id = ?
      SQL
      return nil unless question.length > 0

      Question.new(question.first)
  end

  def self.most_followed(n)
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

  def self.most_liked(n)
    questions = QuestionLikeDBConnection.instance.execute(<<-SQL, n)
      WITH great_questions as (
        SELECT qf.question_id, count(qf.question_id)
        FROM  question_likes qf
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

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end

  def followers
    QuestionFollow.followers_for_question_id(@id)
  end

  def author
    author = User.find_by_id(@author_id)
    "#{author.fname} #{author.lname}"
  end

  def replies
    Reply.find_by_question_id(@id)
  end

  def likers
    QuestionLike.likers_for_question_id(@id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(@id)
  end
end
