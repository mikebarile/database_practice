require 'sqlite3'
require 'singleton'

class QuestionsDBConnection < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class Questions
  attr_accessor :title, :body, :author_id
  attr_reader :id

  def self.all
    data = QuestionsDBConnection.instance.execute("SELECT * FROM questions")
    data.map { |datum| Questions.new(datum) }
  end

  def self.find_by_id(id)
    question = QuestionsDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
      SQL
      return nil unless question.length > 0

      Questions.new(question.first)
  end

  def initialize(options)
    @id = options[id]
    @title = options[title]
    @body = options[body]
    @author_id = options[author_id]
  end

end
