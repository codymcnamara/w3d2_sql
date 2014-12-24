DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);

DROP TABLE IF EXISTS questions;
CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body VARCHAR(1000) NOT NULL,
  users_id INTEGER NOT NULL,

  FOREIGN KEY(users_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_followers;
CREATE TABLE question_followers (

  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  follower_id INTEGER NOT NULL,

  FOREIGN KEY(follower_id) REFERENCES users(id),

  FOREIGN KEY(question_id) REFERENCES questions(id)
);

DROP TABLE IF EXISTS replies;
CREATE TABLE replies (
  reply_id INTEGER PRIMARY KEY,
  subject INTEGER NOT NULL,
  reply_parent INTEGER,
  reply_user INTEGER NOT NULL,
  reply_body VARCHAR(1000) NOT NULL,

  FOREIGN KEY(subject) REFERENCES questions(id),
  FOREIGN KEY(reply_parent) REFERENCES replies(reply_id),
  FOREIGN KEY(reply_user) REFERENCES users(id)

);

DROP TABLE IF EXISTS question_likes;
CREATE TABLE question_likes (
  question_like INTEGER PRIMARY KEY,
  liked_question INTEGER NOT NULL,
  user_who_liked INTEGER NOT NULL,

  FOREIGN KEY(liked_question) REFERENCES questions(id),
  FOREIGN KEY(user_who_liked) REFERENCES users(id)
);



INSERT INTO
  users (fname, lname)
VALUES
  ("John", "Smith"),
  ("Angelina", "Jolie"),
  ("Bob", "Barker");

INSERT INTO
  questions (title, body, users_id)
VALUES
  ('How do I use sqlite3?', 'Im confused', 2),
  ('Best place to retire to?', 'Im really old', 3);

INSERT INTO
  question_followers (question_id, follower_id)
VALUES
  (1, 3),
  (2, 1),
  (2, 3);

INSERT INTO
  replies(subject, reply_parent, reply_user, reply_body)
VALUES
  (1, NULL, 3, "Do what the github stuff says"),
  (1, 1, 1, "Yeah also google stuff"),
  (2, NULL, 2, "Florida. Lots of old people there");

INSERT INTO
  question_likes(liked_question, user_who_liked)
VALUES
  (2, 1),
  (1, 3),
  (2, 3);
