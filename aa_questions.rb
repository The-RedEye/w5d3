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
    attr_accessor :fname, :lname

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
        data.map{|datum| User.new(datum)}
    end

    def self.find_by_name(fname, lname)
        data = QuestionsDatabase.instance.execute("SELECT * FROM users WHERE fname = #{fname} AND lname = #{lname} ")
        data.map { |datum| User.new(datum) }
    end
end # End User Class

class Question 
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
        data.map{|datum| Question.new(datum)}
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
        data.map{|datum| QuestionFollow.new(datum)}
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
        data.map{|datum| QuestionLike.new(datum)}
    end

end #end QuestionLike