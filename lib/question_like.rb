require 'sqlite3'
require 'singleton'

class QuestionLikeDBConnection < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class QuestionLike
  attr_accessor :liker_id, :question_id, :author_id
  attr_reader :id

  def self.all
    data = QuestionLikeDBConnection.instance.execute("SELECT * FROM questions")
    data.map { |datum| QuestionLike.new(datum) }
  end

  def self.likers_for_question_id(question_id)
    likers = QuestionLikeDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        u.id, u.fname, u.lname
      FROM question_likes ql
      JOIN users u on u.id = ql.liker_id
      WHERE
        ql.question_id = ?
    SQL
    return nil unless likers.length > 0

    likers.map { |datum| User.new(datum) }
  end

  def self.num_likes_for_question_id(question_id)
    likes = QuestionLikeDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        COUNT(ql.liker_id)
      FROM question_likes ql
      WHERE ql.question_id = ?
      GROUP BY ql.question_id
    SQL
    return nil unless likes.length > 0

    likes[0].values[0]
  end

  def self.liked_questions_for_user_id(user_id)
    questions = QuestionLikeDBConnection.instance.execute(<<-SQL, user_id)
    SELECT
      q.id, q.title, q.body, q.author_id
    FROM question_likes ql
    JOIN questions q on ql.question_id = q.id
    WHERE
      ql.liker_id = ?
  SQL
  return nil unless questions.length > 0

  questions.map { |datum| Question.new(datum) }
  end

  def self.most_liked_questions(n)
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
    @liker_id = options['liker_id']
    @question_id = options['question_id']
    @author_id = options['author_id']
  end






end
