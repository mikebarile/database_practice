require 'sqlite3'
require 'singleton'

class ReplyDBConnection < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class Reply
  attr_accessor :parent_id, :reply_author_id, :question_id, :body
  attr_reader :id

  def self.all
    data = ReplyDBConnection.instance.execute("SELECT * FROM replies")
    data.map { |datum| Reply.new(datum) }
  end

  def self.find_by_question_id(question_id)
    reply = ReplyDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
      SQL
      return nil unless reply.length > 0

      reply.map { |datum| Reply.new(datum) }
  end

  def self.find_by_id(id)
    reply = ReplyDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
      SQL
      return nil unless reply.length > 0

      reply.map { |datum| Reply.new(datum) }
  end


  def self.find_by_author(reply_author_id)
    reply = ReplyDBConnection.instance.execute(<<-SQL, reply_author_id)
      SELECT
        *
      FROM
        replies
      WHERE
        reply_author_id = ?
      SQL
      return nil unless reply.length > 0

      reply.map { |datum| Reply.new(datum) }
  end

  def initialize(options)
    @id = options['id']
    @parent_id = options['parent_id']
    @reply_author_id = options['reply_author_id']
    @question_id = options['question_id']
    @body = options['body']
  end

  def author
    author = User.find_by_id(@reply_author_id)
    "#{author.fname} #{author.lname}"
  end

  def question
    Question.find_by_id(@question_id)
  end

  def parent_reply
    Reply.find_by_id(@parent_id)
  end

  def child_replies
    Reply.all.select{|reply| reply.parent_id == @id}
  end

end
