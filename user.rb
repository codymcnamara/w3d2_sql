class User
  attr_accessor :id, :fname, :lname

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

  def followed_questions
    QuestionFollowers.followed_questions_for_user_id(@id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(@id)
  end

  def average_karma
    found = QuestionsDatabase.instance.execute(<<-SQL, @id)
    SELECT CAST( COUNT(question_likes.user_who_liked) AS FLOAT) likes_per_question, COUNT(DISTINCT(questions.id)) num_of_questions
    FROM questions
    LEFT OUTER JOIN question_likes
    ON questions.id = question_likes.liked_question
    WHERE questions.users_id = ?

    SQL
    #found
    found.first['likes_per_question'] / (found.first['num_of_questions'])
  end

  def save
    raise 'already saved!' unless self.id.nil?

    params = [self.fname, self.lname]
    SchoolDatabase.instance.execute(<<-SQL, *params)
    INSERT INTO
      users (fname, lname)
    VALUES
      (?, ?)
    SQL

    @id = SchoolDatabase.instance.last_insert_row_id

  end

end
