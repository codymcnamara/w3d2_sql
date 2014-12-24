require 'singleton'
require 'sqlite3'

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

class User

  def self.all
    # execute a SELECT; result in an `Array` of `Hash`es, each
    # represents a single row.
    results = QuestionsDatabase.instance.execute('SELECT * FROM users')
    results.map { |result| User.new(result) }
  end

  attr_accessor :id, :fname, :lname

  def initialize(options={})
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def authored_questions
    asked_questions = []
    found = QuestionsDatabase.instance.execute(<<-SQL, @user_id)
    SELECT * FROM questions WHERE questions.users_id = ?
    SQL
    found.each {|question| asked_questions << Question.new(question)}

    asked_questions
  end

  def authored_replies
    Reply.find_by_user(@id)
  end

  def self.find_by_id(user_id)
    found = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT * FROM users WHERE id = ?
      SQL
      User.new(found.first)
    # should return an instance of our User class!
    # NOT the data hash returned by the QuestionsDatabase!

  end

  def self.find_by_name(fname, lname)
    found = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
    SELECT * FROM users WHERE fname = ? AND lname = ?
    SQL
    User.new(found.first)
  end

end

class Question
  attr_accessor :id, :title, :body, :users_id

  def initialize(options={})
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @users_id = options['users_id']
  end

  def self.find_by_id(question_id)
    found = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT * FROM questions WHERE id = ?
    SQL
    Question.new(found.first)
  end

  def self.find_by_author_id(author_id)
    user = User.find_by_id(author_id)
    user.authored_questions
  end

  def author
    User.find_by_id(@users_id)
  end

  def replies
    Reply.find_by_question_id(@id)
  end

end

class QuestionFollowers
  attr_accessor :id, :question_id, :follower_id

  def initialize(options ={})
    @id = options['id']
    @question_id = options['question_id']
    @follower_id = options['follower_id']
  end

  def self.find_by_id(id)
    found = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT * FROM question_followers WHERE id = ?
    SQL
    QuestionFollowers.new(found.first)
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


class QuestionLikes
  attr_accessor :question_like, :liked_question, :user_who_liked

  def initialize(options ={})
    @question_like = options['question_like']
    @liked_question = options['liked_question']
    @user_who_liked = options['user_who_liked']
  end

  def self.find_by_id(question_like)
    found = QuestionsDatabase.instance.execute(<<-SQL, question_like)
    SELECT * FROM question_likes WHERE question_like = ?
    SQL
    QuestionLikes.new(found.first)
  end
end

#bob = User.find_by_id(3)
parent_reply = Reply.find_by_id(1)
#child_reply = Reply.find_by_id(2)
#q = Question.find_by_id(1)
p parent_reply.child_replies
