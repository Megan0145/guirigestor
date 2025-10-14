class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable
  has_secure_token :auth_token
  attr_accessor :validation_set
  
  validates_presence_of :first_name, if: proc { |order| order.validation_set == "step1" }
  validates :email, presence: true, uniqueness: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP, message: 'must be a valid email address' }
  validate :email_validity

  has_many :fiscal_quarters, dependent: :destroy
  has_many :autonomo_payments, dependent: :destroy
  has_many :outgoing_receipts, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :services, dependent: :destroy
  
  def name 
    "#{first_name} #{last_name}"
  end

  def email_validity
    return if email =~ URI::MailTo::EMAIL_REGEXP

    errors.add(:email, 'must be a valid email address')
  end

end