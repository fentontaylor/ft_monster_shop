class Review <ApplicationRecord
  validates_presence_of :title
  validates_presence_of :content
  validates :rating, numericality:
    { only_integer: true,
      greater_than_or_equal_to: 1,
      less_than_or_equal_to: 5}

  belongs_to :item
  belongs_to :user

  def written_by?(user)
    self.user_id == user.id
  end
end
