PRAGMA foreign_keys = ON;


DROP TABLE IF EXISTS question_likes;
DROP TABLE IF EXISTS replies;
DROP TABLE IF EXISTS question_follows;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);



CREATE TABLE questions(
   id INTEGER PRIMARY KEY,
   title TEXT NOT NULL,
   body TEXT NOT NULL,
   user_id INTEGER NOT NULL,

   FOREIGN KEY (user_id) REFERENCES users(id)
);


CREATE TABLE question_follows(
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
 

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
); 


CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  body TEXT NOT NULL,
  question_id INTEGER NOT NULL,
  parent_reply_id INTEGER,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_reply_id) REFERENCES replies(id),
  FOREIGN KEY (user_id) REFERENCES users(id)

);


CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO 
  users (fname, lname)
VALUES
  ('Jon', 'Angeles'),
  ('Tristan', 'Ortiz');

INSERT INTO
  questions(title, body, user_id)
VALUES
  ('Break Time?', 'How long until break?', 1),
  ('When is the weekend', 'How long until the weekend', 2);

INSERT INTO
  question_follows(question_id, user_id)
VALUES
  (1,1),
  (2,2),
  (2,1);

INSERT INTO
  replies(body, question_id, parent_reply_id, user_id)
VALUES
  ('I had the same question', 1, NULL, 2),
  ('Far too long', 1, 1, 1 );

INSERT INTO
  question_likes(user_id, question_id)
VALUES
 (2,1),
 (1,2);
