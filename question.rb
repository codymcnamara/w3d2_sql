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

  def followers
    QuestionFollowers.followers_for_question_id(@id)
  end

  def self.most_followed(n)
    QuestionFollowers.most_followed_questions(n)
  end

  def likers
    QuestionLike.likers_for_question_id(@id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(@id)
  end

  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
  end

end
