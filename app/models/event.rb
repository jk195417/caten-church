# == Schema Information
#
# Table name: events
#
#  id                 :integer          not null, primary key
#  name               :string
#  nature             :string
#  description        :text
#  max_sign_up_number :integer
#  min_sign_up_number :integer
#  sign_up_begin      :datetime
#  sign_up_end        :datetime
#  start              :datetime
#  over               :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  user_id            :integer
#  participants_count :integer          default(0)
#

class Event < ApplicationRecord
  resourcify
	# 活動發起者
	belongs_to :organizer, class_name: "User", foreign_key: :user_id

	# event has many event_users
	# event has many participants from user, and save in event_users
	# 刪除 event 會清空報名event的人的資料(participants)
	has_many :event_users
  has_many :participants, through: :event_users, source: :user, dependent: :destroy

	# 驗證
	# 必填欄位
  validates_presence_of  :name, :max_sign_up_number, :sign_up_begin, :sign_up_end, :start, :over
  validate :myValid


	# 修改權限 哪些role有權限(目前使用cancancan)
	def manage_by?(user)
     user && user.has_any_role?(:admin, :manager)
  end

  def can_join_event?
  	(self.participants_count < self.max_sign_up_number) && (self.sign_up_end.to_i >= DateTime.now.to_i) && (self.sign_up_begin.to_i <= DateTime.now.to_i)
  end

  def is_expired?
    self.sign_up_end.to_i < DateTime.now.to_i
  end

  private

  def myValid
  	if max_sign_up_number.to_i < min_sign_up_number.to_i
  		errors[:max_sign_up_number] << "報名活動的人數上限要比活動成立的人數高吧!"
  	end
  	if sign_up_begin.to_i >= sign_up_end.to_i
  		errors[:sign_up_end] << "結束報名的時間要比開始報名的時間後面喔!"
  	end
  	if start.to_i >=  over.to_i
  		errors[:start] << "活動開始的時間要比活動結束的時間還前面吧!"
  	end
  	if sign_up_end.to_i >= over.to_i
  		errors[:over] << "報名截止的時間要在活動結束的時間之前喔!"
  	end
  end

end
