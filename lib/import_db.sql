DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(100) NOT NULL,
  lname VARCHAR(100) NOT NULL
);

DROP TABLE IF EXISTS questions;
CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  author_id INTEGER NOT NULL,

  FOREIGN KEY(author_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_follows;
CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  author_id INTEGER NOT NULL,
  follower_id INTEGER NOT NULL,

  FOREIGN KEY(author_id) REFERENCES users(id),
  FOREIGN KEY(follower_id) REFERENCES users(id),
  FOREIGN KEY(question_id) REFERENCES questions(id)
);

DROP TABLE IF EXISTS replies;
CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  parent_id INTEGER,
  question_id INTEGER NOT NULL,
  reply_author_id INTEGER NOT NULL,
  body TEXT NOT NULL,

  FOREIGN KEY(parent_id) REFERENCES replies(id),
  FOREIGN KEY(question_id) REFERENCES questions(id),
  FOREIGN KEY(reply_author_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_likes;
CREATE TABLE question_likes(
  id INTEGER PRIMARY KEY,
  liker_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,
  author_id INTEGER NOT NULL,

  FOREIGN KEY (liker_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (author_id) REFERENCES users(id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ('Mike', 'Barile'),
  ('Peik', 'Sia'),
  ('Donald', 'Trump'),
  ('Peter', 'Thiel');

INSERT INTO
  questions (title, body, author_id)
VALUES
  ('How to code', 'How do you code?', 1),
  ('How do you node', 'How do you node?', 2);

INSERT INTO
  question_follows (question_id, author_id, follower_id)
VALUES
  (1, 1, 3),
  (2, 2, 4);

INSERT INTO
  replies (parent_id, question_id, reply_author_id, body)
VALUES
  (null, 1, 3, 'Lets make America great again!'),
  (1, 1, 1, 'OK!!!!');

INSERT INTO
  question_likes (liker_id, question_id, author_id)
VALUES
  (3, 1, 1),
  (4, 2, 2);
