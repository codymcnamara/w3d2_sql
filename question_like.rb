class QuestionLike
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
    QuestionLike.new(found.first)
  end

  def self.likers_for_question_id(question_id)
    likers = []

    found = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT users.id, users.fname, users.lname
    FROM question_likes
    INNER JOIN users
    on users.id = question_likes.user_who_liked
    WHERE question_likes.liked_question = ?
    SQL

    found.each {|liker| likers << User.new(liker)}

    likers
  end

  def self.num_likes_for_question_id(question_id)
    found = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT COUNT(user_who_liked)
    FROM question_likes
    WHERE liked_question = ?
    SQL

    found.pop["COUNT(user_who_liked)"]
  end

  def self.liked_questions_for_user_id(user_id)
    liked_questions = []

    found = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT questions.id, questions.title, questions.body, questions.users_id
    FROM question_likes
    INNER JOIN questions
    on questions.id = question_likes.liked_question
    WHERE question_likes.user_who_liked = ?
    SQL

    found.each {|question| liked_questions << Question.new(question)}

    liked_questions
  end

  def self.most_liked_questions(n)
    most_liked = []

    found = QuestionsDatabase.instance.execute(<<-SQL, n)
    SELECT questions.id, questions.title, questions.body, questions.users_id
    FROM question_likes
    INNER JOIN questions
    on question_likes.liked_question = questions.id
    GROUP BY questions.id
    ORDER BY COUNT(question_likes.user_who_liked) DESC
    LIMIT ?;
    SQL

    found.each {|question| most_liked << Question.new(question)}

    most_liked
  end
end
