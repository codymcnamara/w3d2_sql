require 'singleton'
require 'sqlite3'
require_relative 'question_followers'
require_relative 'user'
require_relative 'question'
require_relative 'question_like'

class QuestionsDatabase < SQLite3::Database
  include Singleton
  def initialize
    # Tell the SQLite3::Database the db file to read/write.
    super('questions.db')

    # Typically each row is returned as an array of values; it's more
    # convenient for us if we receive hashes indexed by column name.
    self.results_as_hash = true

    # Typically all the data is returned as strings and not parsed
    # into the appropriate type.
    self.type_translation = true
  end
end


class Reply
  attr_accessor :reply_id, :subject, :reply_parent, :reply_user, :reply_body

  def initialize(options ={})
    @reply_id = options['reply_id']
    @subject = options['subject']
    @reply_parent = options['reply_parent']
    @reply_user = options['reply_user']
    @reply_body = options['reply_body']
  end

  def self.find_by_id(reply_id)
    found = QuestionsDatabase.instance.execute(<<-SQL, reply_id)
    SELECT * FROM replies WHERE reply_id = ?
    SQL
    Reply.new(found.first)
  end

  def self.find_by_question_id(question_id)
    question_replies = []
    found = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT * FROM replies WHERE subject = ?
    SQL
    found.each {|reply| question_replies << Reply.new(reply)}

    question_replies
  end

  def self.find_by_user(user_id)
    authored_replies = []
    found = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT * FROM replies WHERE replies.reply_user = ?
    SQL
    found.each {|reply| authored_replies << Reply.new(reply)}

    authored_replies
  end

  def author
    User.find_by_id(@reply_user)
  end

  def question
    Question.find_by_id(@subject)
  end

  def parent_reply
    Reply.find_by_id(@reply_parent)
  end

  def child_replies
    raw_data = []
    found = QuestionsDatabase.instance.execute(<<-SQL, @reply_id)
    SELECT * FROM replies WHERE replies.reply_parent = ?
    SQL
    found.each {|reply| raw_data << Reply.new(reply)}

    raw_data
  end

end

bob = User.find_by_id(3)
# p QuestionFollowers.most_followed_questions(2)
# question = Question.find_by_id(1)
# p question.num_likes
p bob.average_karma
