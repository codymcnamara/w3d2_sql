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

  def self.followers_for_question_id(question_id)
    followers = []
    found = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT users.id, users.fname, users.lname
    FROM question_followers
    INNER JOIN users
    on question_followers.follower_id = users.id
    WHERE question_followers.question_id = ?
    SQL

    found.each {|follower| followers << User.new(follower)}

    followers
  end

  def self.followed_questions_for_user_id(user_id)
    followed_questions = []
    found = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT questions.id, questions.title, questions.body, questions.users_id
    FROM question_followers
    INNER JOIN questions
    on question_followers.question_id = questions.id
    WHERE question_followers.follower_id = ?
    SQL

    found.each {|question| followed_questions << Question.new(question)}

    followed_questions
  end

  def self.most_followed_questions(n)
    followed_questions = []

    found = QuestionsDatabase.instance.execute(<<-SQL, n)
    SELECT questions.id, questions.title, questions.body, questions.users_id
    FROM question_followers
    INNER JOIN questions
    on question_followers.question_id = questions.id
    GROUP BY questions.id
    ORDER BY COUNT(question_followers.question_id) DESC
    LIMIT ?;
    SQL

    found.each {|question| followed_questions << Question.new(question)}

    followed_questions
  end

end
