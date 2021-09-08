require 'sqlite3'
require 'singleton'

class QuestionsDatabase < SQLite3::Database
    include Singleton

    def initialize
        super('questions.db')
        self.type_translation = true
        self.results_as_hash = true
    end

end

class User
    attr_accessor :fname, :lname, :id

    def self.all
        data = QuestionsDatabase.instance.execute("SELECT * FROM users")
        data.map{|datum| User.new(datum)}
    end

    def initialize(options)
        @id = options['id']
        @fname = options['fname']
        @lname = options['lname']
    end

    def self.find_by_id(id)
        data = QuestionsDatabase.instance.execute("SELECT * FROM users WHERE id = #{id}")
        User.new(data[0])
    end

    def self.find_by_name(fname, lname)
        data = QuestionsDatabase.instance.execute(<<-SQL, fname: fname, lname: lname)
        SELECT
            *
        FROM
            users
        WHERE
            users.fname = :fname AND users.lname = :lname;
        SQL
        User.new(data[0])
    end

    def authored_questions
        Question.find_by_author_id(self.id)
    end

    def authored_replies
        Reply.find_by_user_id(self.id)
    end

    def followed_questions
        QuestionFollow.followed_questions_for_user_id(self.id)
    end

    def liked_questions
        QuestionLike.liked_questions_for_user_id(self.id)
    end

    def average_karma
        data = QuestionsDatabase.instance.execute(<<-SQL, id: self.id)
        SELECT
        CAST(COUNT(question_likes.id) AS FLOAT)  / COUNT(DISTINCT(questions.id))
        FROM
            questions
        LEFT OUTER JOIN
            question_likes
            ON questions.id = question_likes.question_id
       JOIN
            users
            ON users.id = questions.user_id
        WHERE
            users.id = :id
        SQL
        data[0]["CAST(COUNT(question_likes.id) AS FLOAT)  / COUNT(DISTINCT(questions.id))"]
    end
end # End User Class

class Question

    attr_accessor :id
    def self.all
        data = QuestionsDatabase.instance.execute("SELECT * FROM questions")
        data.map{|datum| Question.new(datum)}
    end

    def initialize(options)
        @id = options['id']
        @title = options['title']
        @body = options['body']
        @user_id = options['user_id']
    end

    def self.find_by_id(id)
        data = QuestionsDatabase.instance.execute("SELECT * FROM questions WHERE id = #{id}")
        Question.new(data[0])
    end

    def self.find_by_author_id(author_id)
        data = QuestionsDatabase.instance.execute("SELECT * FROM questions WHERE user_id = #{author_id}")
        data.map{|datum| Question.new(datum)}
    end

    def author
        User.find_by_id(@user_id)
    end

    def replies
        Reply.find_by_question_id(@id)
    end

    def followers
        QuestionFollow.followers_for_question_id(self.id)
    end

    def self.most_followed(n)
        QuestionFollow.most_followed_questions(n)
    end

    def likers
        QuestionLike.likers_for_question_id(self.id)
    end

    def num_likes
        QuestionLike.num_likes_for_question_id(self.id)
    end

    def self.most_liked(n)
        QuestionLike.most_liked_questions(n)
    end
end #end questions

class Reply
     def self.all
        data = QuestionsDatabase.instance.execute("SELECT * FROM replies")
        data.map{|datum| Reply.new(datum)}
    end

    def initialize(options)
        @id = options['id']
        @question_id = options['question_id']
        @body = options['body']
        @user_id = options['user_id']
        @parent_reply_id = options['parent_reply_id']
    end

    def self.find_by_id(id)
        data = QuestionsDatabase.instance.execute("SELECT * FROM replies WHERE id = #{id}")
        Reply.new(data[0])
    end

    def self.find_by_user_id(user_id)
        data = QuestionsDatabase.instance.execute("SELECT * FROM replies WHERE user_id = #{user_id}")
        data.map{|datum| Reply.new(datum)}
    end

    def self.find_by_question_id(question_id)
        data = QuestionsDatabase.instance.execute("SELECT * FROM replies WHERE question_id = #{question_id}")
        data.map{|datum| Reply.new(datum)}
    end

    def author
        User.find_by_id(@user_id)
    end

    def question
        Question.find_by_id(@question_id)
    end

    def parent_reply
        raise "no parent replies" if @parent_reply_id == nil
        Reply.find_by_id(@parent_reply_id)
    end

    def child_replies
        data = QuestionsDatabase.instance.execute(<<-SQL, id: @id)
        SELECT
            *
        FROM
            replies
        WHERE
            parent_reply_id = :id;
        SQL
        data.map{|datum| Reply.new(datum)}
    end

end # end Reply Class

class QuestionFollow
    def self.all
        data = QuestionsDatabase.instance.execute("SELECT * FROM question_follows")
        data.map{|datum| QuestionFollow.new(datum)}
    end

    def initialize(options)
        @id = options['id']
        @question_id = options['question_id']
        @user_id = options['user_id']
    end

    def self.find_by_id(id)
        data = QuestionsDatabase.instance.execute("SELECT * FROM question_follows WHERE id = #{id}")
        QuestionFollow.new(data[0])
    end

    def self.followers_for_question_id(question_id)
        data = QuestionsDatabase.instance.execute(<<-SQL, question_id: question_id)
        SELECT
            users.id,
            users.fname,
            users.lname
        FROM
            question_follows
        JOIN
            users
            ON users.id = question_follows.user_id
        JOIN
            questions
            ON questions.id = question_follows.question_id
        WHERE
            questions.id = :question_id;
        SQL
        data.map{|datum| User.new(datum)}
    end

    def self.followed_questions_for_user_id(user_id)
        data = QuestionsDatabase.instance.execute(<<-SQL, user_id: user_id)
        SELECT
            questions.id,
            questions.title,
            questions.body,
            questions.user_id
        FROM
            questions
        JOIN
            question_follows
            ON questions.id = question_follows.question_id
        JOIN
            users
            ON users.id = question_follows.user_id
        WHERE
            users.id = :user_id;
        SQL
        data.map{|datum| Question.new(datum)}
    end

    def self.most_followed_questions(n)
        data = QuestionsDatabase.instance.execute(<<-SQL, n: n)
        SELECT
            questions.id,
            questions.title,
            questions.body,
            questions.user_id
        FROM
            question_follows
        JOIN
            users
            ON users.id = question_follows.user_id
        JOIN
            questions
            ON questions.id = question_follows.question_id
        GROUP BY
            users.id
        ORDER BY
            COUNT(users.id) ASC
        LIMIT
            :n
        SQL
        data.map{|datum| Question.new(datum)}
    end

end #end QuestionFollows.class

class QuestionLike
    def self.all
        data = QuestionsDatabase.instance.execute("SELECT * FROM question_likes")
        data.map{|datum| QuestionLike.new(datum)}
    end

    def initialize(options)
        @id = options['id']
        @question_id = options['question_id']
        @user_id = options['user_id']
    end

    def self.find_by_id(id)
        data = QuestionsDatabase.instance.execute("SELECT * FROM question_likes WHERE id = #{id}")
        QuestionLike.new(data[0])
    end

    def self.likers_for_question_id(question_id)
        data = QuestionsDatabase.instance.execute(<<-SQL, question_id: question_id)
        SELECT
            users.id,
            users.fname,
            users.lname
        FROM
            users
        JOIN
            question_likes
            ON users.id = question_likes.user_id
        JOIN
            questions
            ON question_likes.question_id = questions.id
        WHERE
            questions.id = :question_id
        SQL
        data.map{|datum| User.new(datum)}
    end

    def self.num_likes_for_question_id(question_id)
        data = QuestionsDatabase.instance.execute(<<-SQL, question_id: question_id)
        SELECT
            COUNT(users.id)
        FROM
            users
        JOIN
            question_likes
            ON users.id = question_likes.user_id
        JOIN
            questions
            ON question_likes.question_id = questions.id
        WHERE
            questions.id = :question_id
        SQL
        data[0]["COUNT(users.id)"]
    end

    def self.liked_questions_for_user_id(user_id)
        data = QuestionsDatabase.instance.execute(<<-SQL, user_id: user_id)
        SELECT
            questions.id,
            questions.title,
            questions.body,
            questions.user_id
        FROM
            questions
        JOIN
            users
            ON users.id = questions.user_id 
        JOIN
            question_likes
            ON  question_likes.question_id = questions.id
        WHERE
            users.id = :user_id
        SQL
        data.map{|datum| Question.new(datum)}
    end

    def self.most_liked_questions(n)
        data = QuestionsDatabase.instance.execute(<<-SQL, n: n)
        SELECT
            questions.id,
            questions.title,
            questions.body,
            questions.user_id
        FROM
            questions
        JOIN
            question_likes
            ON questions.id = question_likes.question_id
        JOIN
            users
            ON users.id = question_likes.user_id
        GROUP BY
            users.id
        ORDER BY
            COUNT(users.id)
        LIMIT
            :n
        SQL
        data.map{|datum| Question.new(datum)}
    end
end #end QuestionLike