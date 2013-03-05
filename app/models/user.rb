class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  devise :omniauthable, omniauth_providers: [:google_oauth2]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
                  :provider, :uid

  has_many :book_ownerships
  has_many :books, through: :book_ownerships

  def self.find_for_google_oauth(auth)
    user = User.where(provider: auth.provider, uid: auth.uid).first

    unless user
      user = User.create!(
        provider: auth.provider,
        uid: auth.uid,
        email: auth.info.email,
        access_token: auth.credentials.token,
        password: Devise.friendly_token[0,20]
      )
    end

    user
  end

  def add_book(file)
    new_book = Book.generate(file)

    books << new_book unless books.index { |book| book.title == new_book.title }

    new_book
  end

end
