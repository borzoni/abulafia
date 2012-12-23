class Comment < ActiveRecord::Base

  include ActsAsCommentable::Comment

  attr_accessible :comment, :user_id

  belongs_to :commentable, :polymorphic => true

  default_scope :order => 'created_at DESC'

  validates_length_of :comment, :minimum => 2

  include PublicActivity::Model
  tracked

  # NOTE: install the acts_as_votable plugin if you
  # want user to vote on the quality of comments.
  #acts_as_voteable

  # NOTE: Comments belong to a user
  belongs_to :user
end
